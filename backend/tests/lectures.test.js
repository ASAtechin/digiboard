/**
 * DigiBoard Backend - Lectures API Tests
 * Full CRUD testing for lecture management
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
let teacher;
let subject;

describe('Lectures API Tests', () => {
    
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
        
        // Create required dependencies
        teacher = await Teacher.create({
            name: 'Dr. Test',
            email: 'test@school.edu',
            department: 'Computer Science'
        });
        
        subject = await Subject.create({
            name: 'Data Structures',
            code: 'CS201',
            board: 'CBSE',
            category: 'Core'
        });
    });

    const validLecture = () => ({
        subject: subject._id,
        teacher: teacher._id,
        classroom: 'CS-LAB-1',
        startTime: new Date('2026-01-23T09:00:00.000Z'),
        endTime: new Date('2026-01-23T10:00:00.000Z'),
        dayOfWeek: 'Thursday',
        lectureType: 'Lab',
        semester: 'Spring 2026',
        course: 'B.Tech CSE Year 2',
        isActive: true
    });

    // ==========================================
    // TC-API-008: Create Lecture - Valid Data
    // ==========================================
    describe('POST /api/lectures', () => {
        
        test('TC-API-008: Creates lecture with valid data', async () => {
            const lectureData = validLecture();

            const res = await authed(app)
                .post('/api/lectures')
                .send(lectureData);
            
            expect(res.statusCode).toBe(201);
            expect(res.body).toHaveProperty('_id');
            expect(res.body.classroom).toBe('CS-LAB-1');
            expect(res.body.dayOfWeek).toBe('Thursday');
            expect(res.body.isActive).toBe(true);
        });

        test('Creates lecture with all optional fields', async () => {
            const lectureData = {
                ...validLecture(),
                chapter: 'Chapter 5: Trees',
                description: 'Introduction to Binary Trees and BST'
            };

            const res = await authed(app)
                .post('/api/lectures')
                .send(lectureData);
            
            expect(res.statusCode).toBe(201);
            expect(res.body.chapter).toBe('Chapter 5: Trees');
            expect(res.body.description).toBe('Introduction to Binary Trees and BST');
        });

        test('Validates lectureType enum', async () => {
            const validTypes = ['Lecture', 'Lab', 'Tutorial', 'Seminar'];
            
            for (const type of validTypes) {
                const lectureData = {
                    ...validLecture(),
                    lectureType: type
                };

                const res = await authed(app)
                    .post('/api/lectures')
                    .send(lectureData);
                
                expect(res.statusCode).toBe(201);
                expect(res.body.lectureType).toBe(type);
                
                // Clean up for next iteration
                await Lecture.deleteMany({});
            }
        });

        test('Validates dayOfWeek enum', async () => {
            const validDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
            
            for (const day of validDays) {
                const lectureData = {
                    ...validLecture(),
                    dayOfWeek: day
                };

                const res = await authed(app)
                    .post('/api/lectures')
                    .send(lectureData);
                
                expect(res.statusCode).toBe(201);
                
                await Lecture.deleteMany({});
            }
        });

        // ==========================================
        // TC-API-009: Missing Required Fields
        // ==========================================
        test('TC-API-009: Rejects missing subject', async () => {
            const { subject: _, ...noSubject } = validLecture();

            const res = await authed(app)
                .post('/api/lectures')
                .send(noSubject);
            
            expect(res.statusCode).toBe(400);
        });

        test('Rejects missing teacher', async () => {
            const { teacher: _, ...noTeacher } = validLecture();

            const res = await authed(app)
                .post('/api/lectures')
                .send(noTeacher);
            
            expect(res.statusCode).toBe(400);
        });

        test('Rejects missing classroom', async () => {
            const { classroom: _, ...noClassroom } = validLecture();

            const res = await authed(app)
                .post('/api/lectures')
                .send(noClassroom);
            
            expect(res.statusCode).toBe(400);
        });

        test('Rejects invalid dayOfWeek', async () => {
            const res = await authed(app)
                .post('/api/lectures')
                .send({
                    ...validLecture(),
                    dayOfWeek: 'InvalidDay'
                });
            
            expect(res.statusCode).toBe(400);
        });
    });

    // ==========================================
    // GET Lectures Tests
    // ==========================================
    describe('GET /api/lectures', () => {
        
        test('Returns all active lectures', async () => {
            await Lecture.create(validLecture());
            await Lecture.create({
                ...validLecture(),
                classroom: 'CS-LAB-2',
                dayOfWeek: 'Friday'
            });

            const res = await authed(app).get('/api/lectures');
            
            expect(res.statusCode).toBe(200);
            expect(res.body).toHaveLength(2);
        });

        test('Excludes inactive lectures', async () => {
            await Lecture.create(validLecture());
            await Lecture.create({
                ...validLecture(),
                classroom: 'CS-LAB-2',
                isActive: false
            });

            const res = await authed(app).get('/api/lectures');
            
            expect(res.statusCode).toBe(200);
            expect(res.body).toHaveLength(1);
        });

        test('Populates teacher and subject', async () => {
            await Lecture.create(validLecture());

            const res = await authed(app).get('/api/lectures');
            
            expect(res.statusCode).toBe(200);
            expect(res.body[0].teacher).toHaveProperty('name', 'Dr. Test');
            expect(res.body[0].subject).toHaveProperty('name', 'Data Structures');
        });
    });

    describe('GET /api/lectures/:id', () => {
        
        test('Returns lecture by ID with populated fields', async () => {
            const lecture = await Lecture.create(validLecture());

            const res = await authed(app).get(`/api/lectures/${lecture._id}`);
            
            expect(res.statusCode).toBe(200);
            expect(res.body.classroom).toBe('CS-LAB-1');
            expect(res.body.teacher).toHaveProperty('name');
            expect(res.body.subject).toHaveProperty('code');
        });

        test('Returns 404 for non-existent lecture', async () => {
            const fakeId = new mongoose.Types.ObjectId();
            
            const res = await authed(app).get(`/api/lectures/${fakeId}`);
            
            expect(res.statusCode).toBe(404);
        });
    });

    // ==========================================
    // Update Lecture Tests
    // ==========================================
    describe('PUT /api/lectures/:id', () => {
        
        test('Updates lecture classroom', async () => {
            const lecture = await Lecture.create(validLecture());

            const res = await authed(app)
                .put(`/api/lectures/${lecture._id}`)
                .send({ classroom: 'NEW-ROOM-999' });
            
            expect(res.statusCode).toBe(200);
            expect(res.body.classroom).toBe('NEW-ROOM-999');
        });

        test('Updates lecture time', async () => {
            const lecture = await Lecture.create(validLecture());
            
            const newStart = new Date('2026-01-23T14:00:00.000Z');
            const newEnd = new Date('2026-01-23T15:30:00.000Z');

            const res = await authed(app)
                .put(`/api/lectures/${lecture._id}`)
                .send({ startTime: newStart, endTime: newEnd });
            
            expect(res.statusCode).toBe(200);
            expect(new Date(res.body.startTime).getHours()).toBe(newStart.getHours());
        });

        test('Cancels lecture by setting isActive to false', async () => {
            const lecture = await Lecture.create(validLecture());

            const res = await authed(app)
                .put(`/api/lectures/${lecture._id}`)
                .send({ isActive: false });
            
            expect(res.statusCode).toBe(200);
            expect(res.body.isActive).toBe(false);
        });
    });

    // ==========================================
    // Delete Lecture Tests
    // ==========================================
    describe('DELETE /api/lectures/:id', () => {
        
        test('Deletes lecture successfully', async () => {
            const lecture = await Lecture.create(validLecture());

            const res = await authed(app).delete(`/api/lectures/${lecture._id}`);
            
            expect(res.statusCode).toBe(200);
            expect(res.body).toHaveProperty('message', 'Lecture deleted successfully');

            const found = await Lecture.findById(lecture._id);
            expect(found).toBeNull();
        });

        test('Returns 404 for non-existent lecture', async () => {
            const fakeId = new mongoose.Types.ObjectId();
            
            const res = await authed(app).delete(`/api/lectures/${fakeId}`);
            
            expect(res.statusCode).toBe(404);
        });
    });
});
