/**
 * DigiBoard Test Setup
 * Global configuration for Jest test environment
 */

// Set timeout to 30 seconds for MongoDB memory server startup
jest.setTimeout(30000);

// Mock console.log to keep test output clean, but allow errors and warnings
global.console = {
    ...console,
    log: jest.fn(),
    info: jest.fn(),
    debug: jest.fn(),
    // Keep these for debugging
    // warn: console.warn,
    // error: console.error,
};

// Global test utilities
global.testUtils = {
    // Helper to create a date for today at specific time
    todayAt: (hours, minutes = 0) => {
        const date = new Date();
        date.setHours(hours, minutes, 0, 0);
        return date;
    },
    
    // Helper to get day name
    getDayName: (date = new Date()) => {
        return date.toLocaleDateString('en-US', { weekday: 'long' });
    },
    
    // Helper to get tomorrow's date
    tomorrow: () => {
        const date = new Date();
        date.setDate(date.getDate() + 1);
        return date;
    }
};

// Cleanup after all tests
afterAll(async () => {
    // Give time for connections to close
    await new Promise(resolve => setTimeout(resolve, 500));
});
