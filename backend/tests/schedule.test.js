/**
 * DigiBoard Backend - Schedule API Tests
 * Tests the core "Next Lecture" algorithm and schedule endpoints
 */

const request = require('supertest');
const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');

// Models
const Lecture = require('../models/Lecture');
const Teacher = require('../models/Teacher');
const Subject = require('../models/Subject');

let mongoServer;
let app;

// Mock data
const mockTeacher = {
    name: 'Dr. Test Professor',
    email: 'test.professor@school.edu',
    department: 'Computer Science',
    phone: '+91-9876543210',
    subjects: ['Data Structures', 'Algorithms']
};

const mockSubject = {
    name: 'Data Structures',
    code: 'CS201',
    board: 'CBSE',
    category: 'Core'
};

// Helper to create a date for today at specific time
const todayAt = (hours, minutes = 0) => {
    const date = new Date();
    date.setHours(hours, minutes, 0, 0);
    return date;
};

// Helper to get day name
const getDayName = (date = new Date()) => {
    return date.toLocaleDateString('en-US', { weekday: 'long' });
};

describe('Schedule API Tests', () => {
    let teacher;
    let subject;

    beforeAll(async () => {
        // Start in-memory MongoDB
        mongoServer = await MongoMemoryServer.create();
        const mongoUri = mongoServer.getUri();
        
        process.env.MONGODB_URI = mongoUri;
        process.env.NODE_ENV = 'test';
        
        // Clear require cache to get fresh server instance
        delete require.cache[require.resolve('../server')];
        
        await mongoose.connect(mongoUri);
        
        // Import app after setting env vars
        const server = require('../server');
        app = server.app;
    });

    afterAll(async () => {
        await mongoose.disconnect();
        await mongoServer.stop();
    });

    beforeEach(async () => {
        // Clear all collections
        await Lecture.deleteMany({});
        await Teacher.deleteMany({});
        await Subject.deleteMany({});
        
        // Create base test data
        teacher = await Teacher.create(mockTeacher);
        subject = await Subject.create(mockSubject);
    });

    // ==========================================
    // TC-API-002: Get Next Lecture - Normal Flow
    // ==========================================
    describe('GET /api/schedule/next', () => {
        
        test('TC-API-002: Returns next upcoming lecture for today', async () => {
            // Create a lecture 1 hour from now
            const futureTime = new Date();
            futureTime.setHours(futureTime.getHours() + 1);
            const endTime = new Date(futureTime);
            endTime.setHours(endTime.getHours() + 1);

            await Lecture.create({
                subject: subject._id,
                teacher: teacher._id,
                classroom: 'CS-101',
                startTime: futureTime,
                endTime: endTime,
                dayOfWeek: getDayName(),
                lectureType: 'Lecture',
                semester: 'Spring 2026',
                course: 'B.Tech CSE',
                isActive: true
            });

            const res = await request(app).get('/api/schedule/next');
            
            expect(res.statusCode).toBe(200);
            expect(res.body).toHaveProperty('classroom', 'CS-101');
            expect(res.body.teacher).toHaveProperty('name', mockTeacher.name);
        });

        // ==========================================
        // TC-API-003: No More Lectures Today
        // ==========================================
        test('TC-API-003: Returns next day lecture when no more today', async () => {
            // Create a lecture that already passed (2 hours ago)
            const pastTime = new Date();
            pastTime.setHours(pastTime.getHours() - 2);
            const pastEndTime = new Date(pastTime);
            pastEndTime.setHours(pastEndTime.getHours() + 1);

            await Lecture.create({
                subject: subject._id,
                teacher: teacher._id,
                classroom: 'CS-101',
                startTime: pastTime,
                endTime: pastEndTime,
                dayOfWeek: getDayName(),
                lectureType: 'Lecture',
                semester: 'Spring 2026',
                course: 'B.Tech CSE',
                isActive: true
            });

            // Create tomorrow's lecture
            const tomorrow = new Date();
            tomorrow.setDate(tomorrow.getDate() + 1);
            tomorrow.setHours(9, 0, 0, 0);
            const tomorrowEnd = new Date(tomorrow);
            tomorrowEnd.setHours(10, 0, 0, 0);

            await Lecture.create({
                subject: subject._id,
                teacher: teacher._id,
                classroom: 'CS-102',
                startTime: tomorrow,
                endTime: tomorrowEnd,
                dayOfWeek: getDayName(tomorrow),
                lectureType: 'Lecture',
                semester: 'Spring 2026',
                course: 'B.Tech CSE',
                isActive: true
            });

            const res = await request(app).get('/api/schedule/next');
            
            // Should return tomorrow's lecture
            expect(res.statusCode).toBe(200);
            expect(res.body).toHaveProperty('classroom', 'CS-102');
        });

        test('Returns 404 when no lectures exist', async () => {
            const res = await request(app).get('/api/schedule/next');
            expect(res.statusCode).toBe(404);
            expect(res.body).toHaveProperty('message', 'No upcoming lectures found');
        });

        test('Ignores inactive lectures', async () => {
            const futureTime = new Date();
            futureTime.setHours(futureTime.getHours() + 1);
            const endTime = new Date(futureTime);
            endTime.setHours(endTime.getHours() + 1);

            // Create inactive lecture
            await Lecture.create({
                subject: subject._id,
                teacher: teacher._id,
                classroom: 'CS-101',
                startTime: futureTime,
                endTime: endTime,
                dayOfWeek: getDayName(),
                lectureType: 'Lecture',
                semester: 'Spring 2026',
                course: 'B.Tech CSE',
                isActive: false // CANCELLED
            });

            const res = await request(app).get('/api/schedule/next');
            expect(res.statusCode).toBe(404);
        });
    });

    // ==========================================
    // TC-API-005: Get Today's Schedule
    // ==========================================
    describe('GET /api/schedule/today', () => {
        
        test('TC-API-005: Returns only today\'s lectures sorted by time', async () => {
            const today = getDayName();
            const tomorrow = getDayName(new Date(Date.now() + 86400000));

            // Create 3 lectures for today (out of order)
            await Lecture.create({
                subject: subject._id,
                teacher: teacher._id,
                classroom: 'Room-C',
                startTime: todayAt(14, 0),
                endTime: todayAt(15, 0),
                dayOfWeek: today,
                semester: 'Spring 2026',
                course: 'B.Tech',
                isActive: true
            });

            await Lecture.create({
                subject: subject._id,
                teacher: teacher._id,
                classroom: 'Room-A',
                startTime: todayAt(9, 0),
                endTime: todayAt(10, 0),
                dayOfWeek: today,
                semester: 'Spring 2026',
                course: 'B.Tech',
                isActive: true
            });

            await Lecture.create({
                subject: subject._id,
                teacher: teacher._id,
                classroom: 'Room-B',
                startTime: todayAt(11, 0),
                endTime: todayAt(12, 0),
                dayOfWeek: today,
                semester: 'Spring 2026',
                course: 'B.Tech',
                isActive: true
            });

            // Create lecture for tomorrow (should NOT appear)
            await Lecture.create({
                subject: subject._id,
                teacher: teacher._id,
                classroom: 'Room-Tomorrow',
                startTime: todayAt(9, 0),
                endTime: todayAt(10, 0),
                dayOfWeek: tomorrow,
                semester: 'Spring 2026',
                course: 'B.Tech',
                isActive: true
            });

            const res = await request(app).get('/api/schedule/today');
            
            expect(res.statusCode).toBe(200);
            expect(res.body).toHaveLength(3); // Only today's
            
            // Verify sorted order
            expect(res.body[0].classroom).toBe('Room-A');
            expect(res.body[1].classroom).toBe('Room-B');
            expect(res.body[2].classroom).toBe('Room-C');
        });

        test('Returns empty array when no lectures today', async () => {
            const res = await request(app).get('/api/schedule/today');
            expect(res.statusCode).toBe(200);
            expect(res.body).toEqual([]);
        });
    });

    // ==========================================
    // Weekly Schedule Tests
    // ==========================================
    describe('GET /api/schedule/week', () => {
        
        test('Returns lectures grouped by day', async () => {
            // Create lectures for Monday and Wednesday
            await Lecture.create({
                subject: subject._id,
                teacher: teacher._id,
                classroom: 'CS-101',
                startTime: todayAt(9, 0),
                endTime: todayAt(10, 0),
                dayOfWeek: 'Monday',
                semester: 'Spring 2026',
                course: 'B.Tech',
                isActive: true
            });

            await Lecture.create({
                subject: subject._id,
                teacher: teacher._id,
                classroom: 'CS-102',
                startTime: todayAt(11, 0),
                endTime: todayAt(12, 0),
                dayOfWeek: 'Wednesday',
                semester: 'Spring 2026',
                course: 'B.Tech',
                isActive: true
            });

            const res = await request(app).get('/api/schedule/week');
            
            expect(res.statusCode).toBe(200);
            expect(res.body).toHaveProperty('Monday');
            expect(res.body).toHaveProperty('Wednesday');
            expect(res.body.Monday).toHaveLength(1);
            expect(res.body.Wednesday).toHaveLength(1);
        });
    });
});
