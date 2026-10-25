/**
 * DigiBoard Test Helper
 * Shared setup for all test files - manages MongoDB and app instance
 */

const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');

let mongoServer;
let isInitialized = false;

// Store the app reference
let appInstance = null;

/**
 * Initialize the test environment
 * Call this in beforeAll() of each test file
 */
async function setupTestDB() {
    if (isInitialized) {
        return appInstance;
    }

    // Start in-memory MongoDB
    mongoServer = await MongoMemoryServer.create();
    const mongoUri = mongoServer.getUri();

    // Set environment variables BEFORE requiring server
    process.env.MONGODB_URI = mongoUri;
    process.env.NODE_ENV = 'test';
    process.env.PORT = '0'; // Use random available port

    // Connect mongoose
    await mongoose.connect(mongoUri);

    // Now require the app (after env vars are set)
    const server = require('../server');
    appInstance = server.app;
    
    isInitialized = true;
    return appInstance;
}

/**
 * Clean up the test environment
 * Call this in afterAll() of each test file
 */
async function teardownTestDB() {
    if (mongoose.connection.readyState !== 0) {
        await mongoose.disconnect();
    }
    if (mongoServer) {
        await mongoServer.stop();
    }
    isInitialized = false;
    appInstance = null;
}

/**
 * Clear all collections
 * Call this in beforeEach() to reset data between tests
 */
async function clearDatabase() {
    const collections = mongoose.connection.collections;
    for (const key in collections) {
        await collections[key].deleteMany({});
    }
}

/**
 * Get the app instance
 */
function getApp() {
    return appInstance;
}

// Helper functions for test data
const todayAt = (hours, minutes = 0) => {
    const date = new Date();
    date.setHours(hours, minutes, 0, 0);
    return date;
};

const getDayName = (date = new Date()) => {
    return date.toLocaleDateString('en-US', { weekday: 'long' });
};

const getTomorrow = () => {
    const date = new Date();
    date.setDate(date.getDate() + 1);
    return date;
};

module.exports = {
    setupTestDB,
    teardownTestDB,
    clearDatabase,
    getApp,
    todayAt,
    getDayName,
    getTomorrow
};
