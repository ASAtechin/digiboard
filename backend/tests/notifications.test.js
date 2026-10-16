/**
 * DigiBoard Backend - Notification API Tests
 * Display alerts are durable, explicitly scoped, never overwrite each other,
 * and can only be changed with the admin API key.
 */

const request = require('supertest');
const { authed } = require('./authed');
const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');

let mongoServer;
let app;
let Alert;

describe('Notification API Tests', () => {

    beforeAll(async () => {
        mongoServer = await MongoMemoryServer.create();
        const mongoUri = mongoServer.getUri();

        process.env.MONGODB_URI = mongoUri;
        process.env.NODE_ENV = 'test';

        delete require.cache[require.resolve('../server')];

        await mongoose.connect(mongoUri);

        const server = require('../server');
        app = server.app;
        Alert = require('../models/Alert');
    });

    afterAll(async () => {
        await mongoose.disconnect();
        await mongoServer.stop();
    });

    beforeEach(async () => {
        await Alert.deleteMany({});
    });

    describe('POST /api/notification (create)', () => {

        test('TC-API-014: Creates a school-wide emergency alert', async () => {
            const res = await authed(app)
                .post('/api/notification')
                .send({ message: 'Fire Drill at 2:00 PM', type: 'emergency', scope: 'all' });

            expect(res.statusCode).toBe(201);
            expect(res.body.success).toBe(true);
            expect(res.body.notification).toMatchObject({
                message: 'Fire Drill at 2:00 PM',
                type: 'emergency',
                scope: 'all',
                active: true,
            });
            expect(res.body.notification).toHaveProperty('id');
            expect(res.body.notification).toHaveProperty('timestamp');
        });

        test('Creates warning and info alerts', async () => {
            for (const type of ['warning', 'info']) {
                const res = await authed(app)
                    .post('/api/notification')
                    .send({ message: `A ${type}`, type, scope: 'all' });
                expect(res.statusCode).toBe(201);
                expect(res.body.notification.type).toBe(type);
            }
        });

        test('Rejects a missing message or unknown type instead of defaulting to an emergency', async () => {
            let res = await authed(app).post('/api/notification').send({ type: 'emergency', scope: 'all' });
            expect(res.statusCode).toBe(400);

            res = await authed(app).post('/api/notification').send({ message: 'x', type: 'panic', scope: 'all' });
            expect(res.statusCode).toBe(400);

            res = await authed(app).post('/api/notification').send({ active: true });
            expect(res.statusCode).toBe(400);
            expect(await Alert.countDocuments()).toBe(0);
        });

        test('Rejects an alert with neither targets nor an explicit school-wide scope', async () => {
            const res = await authed(app)
                .post('/api/notification')
                .send({ message: 'Ambiguous', type: 'info' });
            expect(res.statusCode).toBe(400);

            const empty = await authed(app)
                .post('/api/notification')
                .send({ message: 'Ambiguous', type: 'info', targets: [] });
            expect(empty.statusCode).toBe(400);
            expect(await Alert.countDocuments()).toBe(0);
        });

        test('Stores very long messages and special characters as given', async () => {
            const message = 'A'.repeat(1000) + ' 🚨 <script>alert("xss")</script>';
            const res = await authed(app)
                .post('/api/notification')
                .send({ message, type: 'info', scope: 'all' });
            expect(res.statusCode).toBe(201);
            expect(res.body.notification.message).toBe(message);
        });
    });

    describe('Targeted alerts', () => {

        test('Persists targets and returns them to displays', async () => {
            await authed(app)
                .post('/api/notification')
                .send({ message: 'Fire drill for CS Building', type: 'emergency', targets: ['CS-101', 'CS-LAB-1'] });

            const res = await request(app).get('/api/notification');
            expect(res.statusCode).toBe(200);
            expect(res.body.active).toBe(true);
            expect(res.body.scope).toBe('selected');
            expect(res.body.targets).toEqual(['CS-101', 'CS-LAB-1']);
        });
    });

    describe('Several active alerts', () => {

        test('An info alert never replaces an active emergency', async () => {
            await authed(app)
                .post('/api/notification')
                .send({ message: 'Evacuate now', type: 'emergency', scope: 'all' });
            await authed(app)
                .post('/api/notification')
                .send({ message: 'Library closes early', type: 'info', scope: 'all' });

            const res = await request(app).get('/api/notification');
            expect(res.body.message).toBe('Evacuate now');
            expect(res.body.type).toBe('emergency');
            expect(res.body.alerts.map((a) => a.message)).toEqual(['Evacuate now', 'Library closes early']);
        });

        test('Expired alerts are not shown', async () => {
            await Alert.create({
                message: 'Old', type: 'warning', scope: 'all', expiresAt: new Date(Date.now() - 1000),
            });
            const res = await request(app).get('/api/notification');
            expect(res.body.active).toBe(false);
        });
    });

    describe('Clearing', () => {

        test('TC-API-015: Clears all current alerts and keeps the records', async () => {
            await authed(app)
                .post('/api/notification')
                .send({ message: 'Active Alert', type: 'emergency', scope: 'all' });

            let getRes = await request(app).get('/api/notification');
            expect(getRes.body.active).toBe(true);

            const clearRes = await authed(app).post('/api/notification').send({ active: false });
            expect(clearRes.statusCode).toBe(200);
            expect(clearRes.body.cleared).toBe(1);

            getRes = await request(app).get('/api/notification');
            expect(getRes.body.active).toBe(false);

            const stored = await Alert.findOne({ message: 'Active Alert' });
            expect(stored.active).toBe(false);
            expect(stored.clearedAt).toBeInstanceOf(Date);
        });

        test('Clears one alert by id and leaves the others', async () => {
            const first = await authed(app)
                .post('/api/notification')
                .send({ message: 'First', type: 'warning', scope: 'all' });
            await authed(app)
                .post('/api/notification')
                .send({ message: 'Second', type: 'info', scope: 'all' });

            await authed(app)
                .post('/api/notification')
                .send({ active: false, id: first.body.notification.id });

            const res = await request(app).get('/api/notification');
            expect(res.body.alerts.map((a) => a.message)).toEqual(['Second']);
        });
    });

    describe('GET /api/notification', () => {

        test('Returns inactive state when there are no alerts', async () => {
            const res = await request(app).get('/api/notification');
            expect(res.statusCode).toBe(200);
            expect(res.body).toEqual({ active: false, alerts: [] });
        });
    });

    describe('Authorization', () => {

        test('Anonymous callers cannot create or clear alerts', async () => {
            const create = await request(app)
                .post('/api/notification')
                .send({ message: 'Fake alarm', type: 'emergency', scope: 'all' });
            expect(create.statusCode).toBe(401);

            await Alert.create({ message: 'Real', type: 'emergency', scope: 'all' });
            const clear = await request(app).post('/api/notification').send({ active: false });
            expect(clear.statusCode).toBe(401);

            expect(await Alert.countDocuments({ active: true })).toBe(1);
        });

        test('A wrong key is rejected', async () => {
            const res = await request(app)
                .post('/api/notification')
                .set('Authorization', 'Bearer wrong-key-wrong-key-wrong-key-wrong')
                .send({ message: 'x', type: 'info', scope: 'all' });
            expect(res.statusCode).toBe(401);
        });
    });
});
