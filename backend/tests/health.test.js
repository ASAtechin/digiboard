const request = require('supertest');
const { authed } = require('./authed');
const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');

let mongoServer;
let app;

describe('Health Check API', () => {
    beforeAll(async () => {
        // Start in-memory MongoDB
        mongoServer = await MongoMemoryServer.create();
        const mongoUri = mongoServer.getUri();
        
        // Clear require cache to get fresh server instance
        delete require.cache[require.resolve('../server')];
        
        // Connect to test database
        await mongoose.connect(mongoUri);
        
        // Import app after mongoose is connected
        const server = require('../server');
        app = server.app;
    });
    
    afterAll(async () => {
        if (mongoose.connection.readyState !== 0) {
            await mongoose.connection.dropDatabase();
            await mongoose.disconnect();
        }
        if (mongoServer) {
            await mongoServer.stop();
        }
    });
    
    it('GET /api/health should return 200 OK', async () => {
        const res = await authed(app).get('/api/health');
        expect(res.statusCode).toEqual(200);
        expect(res.body).toHaveProperty('status', 'Server is running');
    });
    
    it('GET /api/health includes database status', async () => {
        const res = await authed(app).get('/api/health');
        expect(res.statusCode).toEqual(200);
        expect(res.body).toHaveProperty('database');
    });
});
