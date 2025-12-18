// Set timeout to 10 seconds
jest.setTimeout(10000);

// Mock console.log to keep test output clean, but allow errors
global.console = {
    ...console,
    log: jest.fn(),
    info: jest.fn(),
    debug: jest.fn(),
};
