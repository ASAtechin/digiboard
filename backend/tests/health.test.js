const request = require('supertest');
const express = require('express');
const mongoose = require('mongoose');

// Mock mongoose connection
jest.mock('mongoose', () => ({
    connect: jest.fn(),
    connection: {
        readyState: 1,
        on: jest.fn(),
        close: jest.fn(),
    },
}));

// Import app from server.js
const { app } = require('../server');

describe('Health Check API', () => {
    it('GET /api/health should return 200 OK', async () => {
        const res = await request(app).get('/api/health');
        expect(res.statusCode).toEqual(200);
        expect(res.body).toHaveProperty('status', 'Server is running');
        // Database might be disconnected in test env without mock, but status should be there
    });
});
