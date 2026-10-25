/**
 * DigiBoard - End-to-End Integration Tests
 * Tests complete user flows across the system
 */

const request = require('supertest');
const { authed } = require('./authed');
const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');

const Lecture = require('../models/Lecture');
const Teacher = require('../models/Teacher');
const Subject = require('../models/Subject');

let mongoServer;
let app;

describe('E2E Integration Tests', () => {
    
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
        await Lecture.deleteMany({});
        await Teacher.deleteMany({});
        await Subject.deleteMany({});
    });

    // ==========================================
    // INT-001: Full Teacher Lifecycle
    // ==========================================
    describe('INT-001: Full Teacher Lifecycle', () => {
        
        test('Complete teacher CRUD flow', async () => {
            // Step 1: Create teacher
            const createRes = await authed(app)
                .post('/api/teachers')
                .send({
                    name: 'Dr. Integration Test',
                    email: 'integration@school.edu',
                    department: 'Testing',
                    subjects: ['Unit Testing', 'Integration Testing']
                });
            
            expect(createRes.statusCode).toBe(201);
            const teacherId = createRes.body._id;
            expect(teacherId).toBeDefined();

            // Step 2: Verify in database
            const dbTeacher = await Teacher.findById(teacherId);
            expect(dbTeacher).not.toBeNull();
            expect(dbTeacher.name).toBe('Dr. Integration Test');

            // Step 3: Read via API
            const readRes = await authed(app).get(`/api/teachers/${teacherId}`);
            expect(readRes.statusCode).toBe(200);
            expect(readRes.body.email).toBe('integration@school.edu');

            // Step 4: Update via API
            const updateRes = await authed(app)
                .put(`/api/teachers/${teacherId}`)
                .send({ name: 'Dr. Updated Name', experience: 10 });
            
            expect(updateRes.statusCode).toBe(200);
            expect(updateRes.body.name).toBe('Dr. Updated Name');
            expect(updateRes.body.experience).toBe(10);

            // Step 5: Verify update in list
            const listRes = await authed(app).get('/api/teachers');
            expect(listRes.body.some(t => t.name === 'Dr. Updated Name')).toBe(true);

            // Step 6: Delete
            const deleteRes = await authed(app).delete(`/api/teachers/${teacherId}`);
            expect(deleteRes.statusCode).toBe(200);

            // Step 7: Verify deletion
            const verifyRes = await authed(app).get(`/api/teachers/${teacherId}`);
            expect(verifyRes.statusCode).toBe(404);
        });
    });

    // ==========================================
    // INT-002: Lecture to Display Flow
    // ==========================================
    describe('INT-002: Lecture to Display Flow', () => {
        
        test('Lecture appears on schedule after creation', async () => {
            // Setup: Create teacher and subject
            const teacher = await Teacher.create({
                name: 'Dr. Display Test',
                email: 'display@school.edu',
                department: 'CS'
            });

            const subject = await Subject.create({
                name: 'Display Testing',
                code: 'DT101',
                board: 'CBSE'
            });

            const today = new Date().toLocaleDateString('en-US', { weekday: 'long' });
            const futureTime = new Date();
            futureTime.setHours(futureTime.getHours() + 2);
            const endTime = new Date(futureTime);
            endTime.setHours(endTime.getHours() + 1);

            // Step 1: Create lecture for today
            const createRes = await authed(app)
                .post('/api/lectures')
                .send({
                    subject: subject._id,
                    teacher: teacher._id,
                    classroom: 'TEST-ROOM',
                    startTime: futureTime,
                    endTime: endTime,
                    dayOfWeek: today,
                    semester: 'Test Semester',
                    course: 'Test Course',
                    isActive: true
                });
            
            expect(createRes.statusCode).toBe(201);

            // Step 2: Verify lecture appears in today's schedule
            const todayRes = await authed(app).get('/api/schedule/today');
            expect(todayRes.statusCode).toBe(200);
            expect(todayRes.body.some(l => l.classroom === 'TEST-ROOM')).toBe(true);

            // Step 3: Verify lecture appears as "next"
            const nextRes = await authed(app).get('/api/schedule/next');
            expect(nextRes.statusCode).toBe(200);
            expect(nextRes.body.classroom).toBe('TEST-ROOM');

            // Step 4: Cancel lecture
            await authed(app)
                .put(`/api/lectures/${createRes.body._id}`)
                .send({ isActive: false });

            // Step 5: Verify lecture no longer in today's schedule
            const todayAfterRes = await authed(app).get('/api/schedule/today');
            expect(todayAfterRes.body.some(l => l.classroom === 'TEST-ROOM')).toBe(false);
        });
    });

    // ==========================================
    // INT-003: Emergency Alert Flow
    // ==========================================
    describe('INT-003: Emergency Alert Flow', () => {
        
        test('Emergency alert lifecycle', async () => {
            // Step 1: Initial state - no notification
            let notifRes = await authed(app).get('/api/notification');
            expect(notifRes.body.active).toBe(false);

            // Step 2: Trigger emergency
            const alertRes = await authed(app)
                .post('/api/notification')
                .send({
                    message: 'FIRE DRILL - Evacuate immediately!',
                    type: 'emergency',
                    scope: 'all'
                });
            
            expect(alertRes.statusCode).toBe(201);

            // Step 3: Verify alert is active (simulating display poll)
            notifRes = await authed(app).get('/api/notification');
            expect(notifRes.body.active).toBe(true);
            expect(notifRes.body.message).toBe('FIRE DRILL - Evacuate immediately!');
            expect(notifRes.body.type).toBe('emergency');

            // Step 4: Clear alert
            const clearRes = await authed(app)
                .post('/api/notification')
                .send({ active: false });
            
            expect(clearRes.statusCode).toBe(200);

            // Step 5: Verify alert is cleared
            notifRes = await authed(app).get('/api/notification');
            expect(notifRes.body.active).toBe(false);
        });
    });

    // ==========================================
    // INT-004: Schedule with Populated Data
    // ==========================================
    describe('INT-004: Schedule with Populated Data', () => {
        
        test('Schedule returns fully populated lecture data', async () => {
            // Setup complete data chain
            const teacher = await Teacher.create({
                name: 'Prof. Populated',
                email: 'populated@school.edu',
                department: 'Full Stack',
                phone: '+91-1234567890',
                qualifications: ['Ph.D.', 'M.Tech']
            });

            const subject = await Subject.create({
                name: 'Full Integration',
                code: 'FI999',
                board: 'CBSE',
                category: 'Core'
            });

            const today = new Date().toLocaleDateString('en-US', { weekday: 'long' });
            const startTime = new Date();
            startTime.setHours(startTime.getHours() + 1);
            const endTime = new Date(startTime);
            endTime.setHours(endTime.getHours() + 1);

            await Lecture.create({
                subject: subject._id,
                teacher: teacher._id,
                classroom: 'POPULATED-ROOM',
                startTime,
                endTime,
                dayOfWeek: today,
                semester: 'Populated Semester',
                course: 'Populated Course',
                isActive: true
            });

            // Verify today's schedule has populated data
            const todayRes = await authed(app).get('/api/schedule/today');
            expect(todayRes.statusCode).toBe(200);
            
            const lecture = todayRes.body.find(l => l.classroom === 'POPULATED-ROOM');
            expect(lecture).toBeDefined();
            expect(lecture.teacher.name).toBe('Prof. Populated');
            expect(lecture.subject.name).toBe('Full Integration');
            expect(lecture.subject.code).toBe('FI999');

            // Verify next lecture has populated data
            const nextRes = await authed(app).get('/api/schedule/next');
            expect(nextRes.body.teacher).toHaveProperty('department', 'Full Stack');
        });
    });

    // ==========================================
    // INT-005: Multi-Day Schedule
    // ==========================================
    describe('INT-005: Multi-Day Schedule', () => {
        
        test('Weekly schedule contains all days with data', async () => {
            const teacher = await Teacher.create({
                name: 'Dr. Weekly',
                email: 'weekly@school.edu',
                department: 'Calendar'
            });

            const subject = await Subject.create({
                name: 'Weekly Subject',
                code: 'WEEK01',
                board: 'CBSE'
            });

            const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
            const baseTime = new Date();
            baseTime.setHours(10, 0, 0, 0);
            const endTime = new Date(baseTime);
            endTime.setHours(11, 0, 0, 0);

            // Create lecture for each weekday
            for (const day of days) {
                await Lecture.create({
                    subject: subject._id,
                    teacher: teacher._id,
                    classroom: `ROOM-${day}`,
                    startTime: baseTime,
                    endTime: endTime,
                    dayOfWeek: day,
                    semester: 'Weekly Semester',
                    course: 'Weekly Course',
                    isActive: true
                });
            }

            // Get weekly schedule
            const weekRes = await authed(app).get('/api/schedule/week');
            expect(weekRes.statusCode).toBe(200);

            // Verify all days present
            for (const day of days) {
                expect(weekRes.body).toHaveProperty(day);
                expect(weekRes.body[day]).toHaveLength(1);
                expect(weekRes.body[day][0].classroom).toBe(`ROOM-${day}`);
            }
        });
    });

    // ==========================================
    // INT-006: Concurrent Operations
    // ==========================================
    describe('INT-006: Concurrent Operations', () => {
        
        test('Handles multiple simultaneous requests', async () => {
            const teacher = await Teacher.create({
                name: 'Dr. Concurrent',
                email: 'concurrent@school.edu',
                department: 'Parallel'
            });

            const subject = await Subject.create({
                name: 'Concurrent Subject',
                code: 'CONC01',
                board: 'CBSE'
            });

            const today = new Date().toLocaleDateString('en-US', { weekday: 'long' });
            const startTime = new Date();
            startTime.setHours(startTime.getHours() + 1);
            const endTime = new Date(startTime);
            endTime.setHours(endTime.getHours() + 1);

            await Lecture.create({
                subject: subject._id,
                teacher: teacher._id,
                classroom: 'CONCURRENT-ROOM',
                startTime,
                endTime,
                dayOfWeek: today,
                semester: 'Concurrent',
                course: 'Concurrent',
                isActive: true
            });

            // Simulate 10 display clients polling simultaneously
            const requests = Array(10).fill(null).map(() => 
                authed(app).get('/api/schedule/today')
            );

            const responses = await Promise.all(requests);

            // All should succeed
            responses.forEach(res => {
                expect(res.statusCode).toBe(200);
                expect(res.body.length).toBeGreaterThan(0);
            });
        });
    });
});
