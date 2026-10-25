/**
 * DigiBoard Backend - Teachers API Tests
 * Full CRUD testing for teacher management
 */

const request = require('supertest');
const { authed } = require('./authed');
const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');

const Teacher = require('../models/Teacher');

let mongoServer;
let app;

// Test data
const validTeacher = {
    name: 'Dr. Priya Sharma',
    email: 'priya.sharma@school.edu',
    department: 'Computer Science',
    phone: '+91-9876543210',
    office: 'Block A, Room 205',
    subjects: ['Data Structures', 'Algorithms', 'Python'],
    experience: 12,
    qualifications: ['Ph.D. Computer Science', 'M.Tech', 'B.Tech']
};

describe('Teachers API Tests', () => {
    
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
        await Teacher.deleteMany({});
    });

    // ==========================================
    // TC-API-006: Create Teacher - Valid Data
    // ==========================================
    describe('POST /api/teachers', () => {
        
        test('TC-API-006: Creates teacher with valid data', async () => {
            const res = await authed(app)
                .post('/api/teachers')
                .send(validTeacher);
            
            expect(res.statusCode).toBe(201);
            expect(res.body).toHaveProperty('_id');
            expect(res.body.name).toBe(validTeacher.name);
            expect(res.body.email).toBe(validTeacher.email);
            expect(res.body.subjects).toEqual(validTeacher.subjects);
        });

        test('Creates teacher with minimum required fields', async () => {
            const minTeacher = {
                name: 'John Doe',
                email: 'john@school.edu',
                department: 'Mathematics'
            };

            const res = await authed(app)
                .post('/api/teachers')
                .send(minTeacher);
            
            expect(res.statusCode).toBe(201);
            expect(res.body.experience).toBe(0); // Default
            expect(res.body.subjects).toEqual([]); // Default
        });

        // ==========================================
        // TC-API-007: Create Teacher - Duplicate Email
        // ==========================================
        test('TC-API-007: Rejects duplicate email', async () => {
            // Create first teacher
            await Teacher.create(validTeacher);
            
            // Try to create another with same email
            const duplicate = {
                name: 'Another Person',
                email: validTeacher.email, // Same email
                department: 'Physics'
            };

            const res = await authed(app)
                .post('/api/teachers')
                .send(duplicate);
            
            expect(res.statusCode).toBe(400);
            // MongoDB duplicate key error
        });

        test('Rejects missing required name', async () => {
            const invalidTeacher = {
                email: 'test@school.edu',
                department: 'Science'
            };

            const res = await authed(app)
                .post('/api/teachers')
                .send(invalidTeacher);
            
            expect(res.statusCode).toBe(400);
        });

        test('Rejects missing required email', async () => {
            const invalidTeacher = {
                name: 'Test Teacher',
                department: 'Science'
            };

            const res = await authed(app)
                .post('/api/teachers')
                .send(invalidTeacher);
            
            expect(res.statusCode).toBe(400);
        });
    });

    // ==========================================
    // GET Teachers Tests
    // ==========================================
    describe('GET /api/teachers', () => {
        
        test('Returns empty array when no teachers', async () => {
            const res = await authed(app).get('/api/teachers');
            
            expect(res.statusCode).toBe(200);
            expect(res.body).toEqual([]);
        });

        test('Returns all teachers', async () => {
            await Teacher.create(validTeacher);
            await Teacher.create({
                name: 'Prof. Smith',
                email: 'smith@school.edu',
                department: 'Physics'
            });

            const res = await authed(app).get('/api/teachers');
            
            expect(res.statusCode).toBe(200);
            expect(res.body).toHaveLength(2);
        });
    });

    describe('GET /api/teachers/:id', () => {
        
        test('Returns teacher by ID', async () => {
            const teacher = await Teacher.create(validTeacher);

            const res = await authed(app).get(`/api/teachers/${teacher._id}`);
            
            expect(res.statusCode).toBe(200);
            expect(res.body.name).toBe(validTeacher.name);
        });

        // ==========================================
        // TC-API-012: Get Non-Existent Teacher
        // ==========================================
        test('TC-API-012: Returns 404 for non-existent ID', async () => {
            const fakeId = new mongoose.Types.ObjectId();
            
            const res = await authed(app).get(`/api/teachers/${fakeId}`);
            
            expect(res.statusCode).toBe(404);
            expect(res.body).toHaveProperty('message', 'Teacher not found');
        });

        test('Handles invalid ObjectId format', async () => {
            const res = await authed(app).get('/api/teachers/invalid-id');
            
            expect(res.statusCode).toBe(500);
        });
    });

    // ==========================================
    // TC-API-010: Update Teacher
    // ==========================================
    describe('PUT /api/teachers/:id', () => {
        
        test('TC-API-010: Updates teacher successfully', async () => {
            const teacher = await Teacher.create(validTeacher);

            const updates = {
                name: 'Dr. Priya Sharma-Updated',
                experience: 15
            };

            const res = await authed(app)
                .put(`/api/teachers/${teacher._id}`)
                .send(updates);
            
            expect(res.statusCode).toBe(200);
            expect(res.body.name).toBe(updates.name);
            expect(res.body.experience).toBe(15);
            // Other fields unchanged
            expect(res.body.department).toBe(validTeacher.department);
        });

        test('Updates subjects array', async () => {
            const teacher = await Teacher.create(validTeacher);

            const res = await authed(app)
                .put(`/api/teachers/${teacher._id}`)
                .send({ subjects: ['Machine Learning', 'AI'] });
            
            expect(res.statusCode).toBe(200);
            expect(res.body.subjects).toEqual(['Machine Learning', 'AI']);
        });

        test('Returns 404 for non-existent teacher', async () => {
            const fakeId = new mongoose.Types.ObjectId();
            
            const res = await authed(app)
                .put(`/api/teachers/${fakeId}`)
                .send({ name: 'Updated' });
            
            expect(res.statusCode).toBe(404);
        });
    });

    // ==========================================
    // TC-API-011: Delete Teacher
    // ==========================================
    describe('DELETE /api/teachers/:id', () => {
        
        test('TC-API-011: Deletes teacher successfully', async () => {
            const teacher = await Teacher.create(validTeacher);

            const res = await authed(app).delete(`/api/teachers/${teacher._id}`);
            
            expect(res.statusCode).toBe(200);
            expect(res.body).toHaveProperty('message', 'Teacher deleted successfully');

            // Verify deletion
            const found = await Teacher.findById(teacher._id);
            expect(found).toBeNull();
        });

        test('Returns 404 for non-existent teacher', async () => {
            const fakeId = new mongoose.Types.ObjectId();
            
            const res = await authed(app).delete(`/api/teachers/${fakeId}`);
            
            expect(res.statusCode).toBe(404);
        });
    });

    // ==========================================
    // Edge Cases
    // ==========================================
    describe('Edge Cases', () => {
        
        test('EC-DATA-004: Handles very long teacher name', async () => {
            const longName = 'Dr. ' + 'A'.repeat(200);
            
            const res = await authed(app)
                .post('/api/teachers')
                .send({
                    name: longName,
                    email: 'long@school.edu',
                    department: 'Science'
                });
            
            expect(res.statusCode).toBe(201);
            expect(res.body.name).toBe(longName);
        });

        test('EC-DATA-005: Handles special characters in name', async () => {
            const specialNames = [
                { name: 'José García', email: 'jose@school.edu', department: 'Spanish' },
                { name: '田中太郎', email: 'tanaka@school.edu', department: 'Japanese' },
                { name: "O'Brien", email: 'obrien@school.edu', department: 'English' }
            ];

            for (const teacher of specialNames) {
                const res = await authed(app)
                    .post('/api/teachers')
                    .send(teacher);
                
                expect(res.statusCode).toBe(201);
                expect(res.body.name).toBe(teacher.name);
            }
        });

        test('Trims whitespace from fields', async () => {
            const res = await authed(app)
                .post('/api/teachers')
                .send({
                    name: '  Dr. Whitespace  ',
                    email: '  white@school.edu  ',
                    department: '  Science  '
                });
            
            expect(res.statusCode).toBe(201);
            expect(res.body.name).toBe('Dr. Whitespace');
        });
    });
});
