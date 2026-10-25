/**
 * Supertest wrapper that sends the admin API key on every request.
 */
const request = require('supertest');

function authed(app) {
    const client = request(app);
    const withKey = (method) => (url) =>
        client[method](url).set('Authorization', `Bearer ${process.env.ADMIN_API_KEY}`);
    return {
        get: withKey('get'),
        post: withKey('post'),
        put: withKey('put'),
        patch: withKey('patch'),
        delete: withKey('delete'),
    };
}

module.exports = { authed };
