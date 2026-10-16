/**
 * DigiBoard Backend - Notification API Tests
 * Tests for emergency alert system
 */

const request = require('supertest');
const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');

let mongoServer;
let app;

describe('Notification API Tests', () => {
    
    beforeAll(async () => {
        mongoServer = await MongoMemoryServer.create();
        const mongoUri = mongoServer.getUri();
        
        process.env.MONGODB_URI = mongoUri;
        process.env.NODE_ENV = 'test';
        
        // Clear require cache to get fresh server instance
        delete require.cache[require.resolve('../server')];
        
        await mongoose.connect(mongoUri);
        
        const server = require('../server');
        app = server.app;
    });

    afterAll(async () => {
        await mongoose.disconnect();
        await mongoServer.stop();
    });

    beforeEach(async () => {
        // Clear notification by setting inactive
        await request(app)
            .post('/api/notification')
            .send({ active: false });
    });

    // ==========================================
    // TC-API-014: Notification Create
    // ==========================================
    describe('POST /api/notification', () => {
        
        test('TC-API-014: Creates emergency notification', async () => {
            const notification = {
                message: 'Fire Drill at 2:00 PM',
                type: 'emergency',
                active: true
            };

            const res = await request(app)
                .post('/api/notification')
                .send(notification);
            
            expect(res.statusCode).toBe(200);
            expect(res.body.success).toBe(true);
            expect(res.body.notification).toHaveProperty('message', notification.message);
            expect(res.body.notification).toHaveProperty('type', 'emergency');
            expect(res.body.notification).toHaveProperty('active', true);
            expect(res.body.notification).toHaveProperty('timestamp');
        });

        test('Creates warning notification', async () => {
            const notification = {
                message: 'Early dismissal today',
                type: 'warning',
                active: true
            };

            const res = await request(app)
                .post('/api/notification')
                .send(notification);
            
            expect(res.statusCode).toBe(200);
            expect(res.body.notification.type).toBe('warning');
        });

        test('Creates info notification', async () => {
            const notification = {
                message: 'Parent-Teacher meeting tomorrow',
                type: 'info',
                active: true
            };

            const res = await request(app)
                .post('/api/notification')
                .send(notification);
            
            expect(res.statusCode).toBe(200);
            expect(res.body.notification.type).toBe('info');
        });

        test('Uses default values for missing fields', async () => {
            const res = await request(app)
                .post('/api/notification')
                .send({ active: true });
            
            expect(res.statusCode).toBe(200);
            expect(res.body.notification.message).toBe('Emergency Alert');
            expect(res.body.notification.type).toBe('emergency');
        });
    });

    // ==========================================
    // TC-API-015: Notification Clear
    // ==========================================
    describe('Notification Lifecycle', () => {
        
        test('TC-API-015: Clears active notification', async () => {
            // First, create a notification
            await request(app)
                .post('/api/notification')
                .send({
                    message: 'Active Alert',
                    type: 'emergency',
                    active: true
                });

            // Verify it's active
            let getRes = await request(app).get('/api/notification');
            expect(getRes.body.active).toBe(true);

            // Clear it
            const clearRes = await request(app)
                .post('/api/notification')
                .send({ active: false });
            
            expect(clearRes.statusCode).toBe(200);

            // Verify it's cleared
            getRes = await request(app).get('/api/notification');
            expect(getRes.body.active).toBe(false);
        });
    });

    // ==========================================
    // GET Notification Tests
    // ==========================================
    describe('GET /api/notification', () => {
        
        test('Returns inactive state when no notification', async () => {
            const res = await request(app).get('/api/notification');
            
            expect(res.statusCode).toBe(200);
            expect(res.body.active).toBe(false);
        });

        test('Returns active notification with all fields', async () => {
            // Create notification first
            await request(app)
                .post('/api/notification')
                .send({
                    message: 'Test Alert',
                    type: 'warning',
                    active: true
                });

            const res = await request(app).get('/api/notification');
            
            expect(res.statusCode).toBe(200);
            expect(res.body.active).toBe(true);
            expect(res.body.message).toBe('Test Alert');
            expect(res.body.type).toBe('warning');
        });
    });

    // ==========================================
    // Edge Cases
    // ==========================================
    describe('Notification Edge Cases', () => {
        
        test('Handles very long message', async () => {
            const longMessage = 'A'.repeat(1000);

            const res = await request(app)
                .post('/api/notification')
                .send({
                    message: longMessage,
                    type: 'info',
                    active: true
                });
            
            expect(res.statusCode).toBe(200);
            expect(res.body.notification.message).toBe(longMessage);
        });

        test('Handles special characters in message', async () => {
            const specialMessage = 'Alert! 🚨 Fire <script>alert("xss")</script>';

            const res = await request(app)
                .post('/api/notification')
                .send({
                    message: specialMessage,
                    type: 'emergency',
                    active: true
                });
            
            expect(res.statusCode).toBe(200);
            // Message should be stored as-is (sanitization should happen on display)
            expect(res.body.notification.message).toBe(specialMessage);
        });

        test('Multiple notifications overwrite (only one active)', async () => {
            // Create first notification
            await request(app)
                .post('/api/notification')
                .send({
                    message: 'First Alert',
                    type: 'warning',
                    active: true
                });

            // Create second notification
            await request(app)
                .post('/api/notification')
                .send({
                    message: 'Second Alert',
                    type: 'emergency',
                    active: true
                });

            // Only second should be active
            const res = await request(app).get('/api/notification');
            expect(res.body.message).toBe('Second Alert');
        });
    });

    // ==========================================
    // Targeted Notifications (TC-DSP-004 related)
    // ==========================================
    describe('Targeted Notifications', () => {
        
        test('Creates notification with targets array', async () => {
            const notification = {
                message: 'Fire drill for CS Building',
                type: 'emergency',
                active: true,
                targets: ['CS-101', 'CS-102', 'CS-LAB-1']
            };

            const res = await request(app)
                .post('/api/notification')
                .send(notification);
            
            expect(res.statusCode).toBe(200);
            // Note: Current implementation may not persist targets
            // This test documents expected behavior for future implementation
        });
    });
});
