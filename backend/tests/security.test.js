/**
 * DigiBoard Backend - Security Tests
 * Writes need the admin API key, public reads carry no staff contact details,
 * and a missing database is reported as unavailable rather than hidden.
 */

const request = require('supertest');
const { authed } = require('./authed');
const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');

let mongoServer;
let app;
let Teacher;

const teacherData = {
    name: 'Dr. Asha Rao',
    email: 'asha.rao@example.edu',
    phone: '+91 98450 00000',
    department: 'Mathematics',
    designation: 'Professor',
    subjects: ['Algebra'],
};

describe('Security', () => {

    beforeAll(async () => {
        mongoServer = await MongoMemoryServer.create();
        const mongoUri = mongoServer.getUri();
        process.env.MONGODB_URI = mongoUri;
        process.env.NODE_ENV = 'test';
        delete require.cache[require.resolve('../server')];
        await mongoose.connect(mongoUri);
        app = require('../server').app;
        Teacher = require('../models/Teacher');
    });

    afterAll(async () => {
        await mongoose.disconnect();
        await mongoServer.stop();
    });

    beforeEach(async () => {
        await Teacher.deleteMany({});
    });

    describe('Writes require the admin API key', () => {

        test.each([
            ['post', '/api/teachers'],
            ['post', '/api/lectures'],
            ['post', '/api/classes'],
            ['post', '/api/subjects'],
            ['post', '/api/timetables'],
            ['post', '/api/notification'],
            ['post', '/api/seed'],
        ])('anonymous %s %s returns 401', async (method, url) => {
            const res = await request(app)[method](url).send({});
            expect(res.statusCode).toBe(401);
        });

        test('anonymous update and delete cannot change a teacher', async () => {
            const teacher = await Teacher.create(teacherData);

            const put = await request(app).put(`/api/teachers/${teacher._id}`).send({ name: 'Changed' });
            expect(put.statusCode).toBe(401);

            const del = await request(app).delete(`/api/teachers/${teacher._id}`);
            expect(del.statusCode).toBe(401);

            const stored = await Teacher.findById(teacher._id);
            expect(stored.name).toBe(teacherData.name);
        });

        test('writes are refused when no key is configured', async () => {
            const saved = process.env.ADMIN_API_KEY;
            delete process.env.ADMIN_API_KEY;
            try {
                const res = await request(app)
                    .post('/api/teachers')
                    .set('Authorization', `Bearer ${saved}`)
                    .send(teacherData);
                expect(res.statusCode).toBe(503);
            } finally {
                process.env.ADMIN_API_KEY = saved;
            }
        });

        test('a key shorter than the minimum is treated as not configured', async () => {
            const saved = process.env.ADMIN_API_KEY;
            process.env.ADMIN_API_KEY = 'short-key';
            try {
                const res = await request(app)
                    .post('/api/teachers')
                    .set('Authorization', 'Bearer short-key')
                    .send(teacherData);
                expect(res.statusCode).toBe(503);
            } finally {
                process.env.ADMIN_API_KEY = saved;
            }
        });
    });

    describe('Public reads carry no staff contact details', () => {

        test('anonymous teacher list omits email and phone', async () => {
            await Teacher.create(teacherData);
            const res = await request(app).get('/api/teachers');
            expect(res.statusCode).toBe(200);
            const body = JSON.stringify(res.body);
            expect(body).toContain('Dr. Asha Rao');
            expect(body).not.toContain('asha.rao@example.edu');
            expect(body).not.toContain('98450');
        });

        test('an authorized caller still receives contact details', async () => {
            await Teacher.create(teacherData);
            const res = await authed(app).get('/api/teachers');
            expect(JSON.stringify(res.body)).toContain('asha.rao@example.edu');
        });
    });

    describe('Database unavailable', () => {

        test('data routes return 503, never sample data', async () => {
            await mongoose.disconnect();
            try {
                for (const url of ['/api/teachers', '/api/schedule/today', '/api/notification']) {
                    const res = await request(app).get(url);
                    expect(res.statusCode).toBe(503);
                }
                const health = await request(app).get('/api/health');
                expect(health.statusCode).toBe(200);
                expect(health.body.database).toBe('disconnected');
            } finally {
                await mongoose.connect(mongoServer.getUri());
            }
        });
    });
});
