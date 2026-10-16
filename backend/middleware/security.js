const crypto = require('crypto');
const mongoose = require('mongoose');

const MIN_KEY_LENGTH = 32;
const READ_METHODS = new Set(['GET', 'HEAD', 'OPTIONS']);
// Fields that must never reach public displays or unauthenticated callers.
const CONTACT_FIELDS = new Set(['email', 'phone']);

function configuredApiKey() {
  const key = process.env.ADMIN_API_KEY;
  if (!key || key.length < MIN_KEY_LENGTH) return null;
  return key;
}

function hasValidApiKey(req) {
  const key = configuredApiKey();
  if (!key) return false;
  const header = req.get('authorization') || '';
  const match = /^Bearer (.+)$/.exec(header);
  if (!match) return false;
  const supplied = Buffer.from(match[1]);
  const expected = Buffer.from(key);
  return supplied.length === expected.length && crypto.timingSafeEqual(supplied, expected);
}

// Every create, update, delete and alert change requires the admin API key.
// Without a configured key, writes are refused rather than left open.
function requireWriteKey(req, res, next) {
  if (READ_METHODS.has(req.method)) return next();
  if (!configuredApiKey()) {
    return res.status(503).json({
      success: false,
      error: `Writes are disabled: ADMIN_API_KEY is not configured (minimum ${MIN_KEY_LENGTH} characters).`,
    });
  }
  if (!hasValidApiKey(req)) {
    return res.status(401).json({ success: false, error: 'Unauthorized' });
  }
  return next();
}

function stripFields(value) {
  if (Array.isArray(value)) return value.map(stripFields);
  if (value && typeof value === 'object') {
    const out = {};
    for (const [k, v] of Object.entries(value)) {
      if (!CONTACT_FIELDS.has(k)) out[k] = stripFields(v);
    }
    return out;
  }
  return value;
}

// Unauthenticated readers (the signage displays) never receive staff contact details.
function stripContactFields(req, res, next) {
  if (hasValidApiKey(req)) return next();
  const json = res.json.bind(res);
  res.json = (body) => json(stripFields(JSON.parse(JSON.stringify(body ?? null))));
  return next();
}

// Without a live database the API reports unavailable instead of serving stale or invented data.
function requireDatabase(req, res, next) {
  if (mongoose.connection.readyState === 1) return next();
  return res.status(503).json({
    success: false,
    error: 'Service unavailable: database not connected',
  });
}

module.exports = {
  MIN_KEY_LENGTH,
  configuredApiKey,
  hasValidApiKey,
  requireWriteKey,
  stripContactFields,
  requireDatabase,
};
