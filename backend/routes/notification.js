const express = require('express');
const Alert = require('../models/Alert');

const router = express.Router();

const MAX_TARGETS = 100;

function currentAlertsQuery(now) {
  return {
    active: true,
    $or: [{ expiresAt: { $exists: false } }, { expiresAt: null }, { expiresAt: { $gt: now } }],
  };
}

function bySeverityThenNewest(a, b) {
  const severity = Alert.SEVERITY[b.type] - Alert.SEVERITY[a.type];
  if (severity !== 0) return severity;
  return b.issuedAt - a.issuedAt;
}

/**
 * GET /api/notification
 * Returns every current alert, highest severity first. The top-level fields
 * repeat the first alert so older display clients keep working.
 */
router.get('/', async (req, res, next) => {
  try {
    const alerts = (await Alert.find(currentAlertsQuery(new Date()))).sort(bySeverityThenNewest);
    if (alerts.length === 0) {
      return res.json({ active: false, alerts: [] });
    }
    const display = alerts.map((alert) => alert.toDisplay());
    return res.json({ ...display[0], alerts: display });
  } catch (error) {
    return next(error);
  }
});

/**
 * POST /api/notification
 * Create: { message, type, scope: "all" } or { message, type, targets: [...] }
 *         optional expiresInMinutes. A new alert never replaces an existing one.
 * Clear:  { active: false } clears all current alerts; add id or type to narrow it.
 */
router.post('/', async (req, res, next) => {
  try {
    const body = req.body || {};

    if (body.active === false) {
      const filter = { active: true };
      if (body.id) filter._id = body.id;
      if (body.type) filter.type = body.type;
      const result = await Alert.updateMany(filter, {
        $set: { active: false, clearedAt: new Date(), clearedReason: body.reason },
      });
      return res.json({ success: true, cleared: result.modifiedCount });
    }

    const { message, type, scope, targets, expiresInMinutes } = body;

    if (typeof message !== 'string' || message.trim() === '') {
      return res.status(400).json({ success: false, error: 'message is required' });
    }
    if (!Object.prototype.hasOwnProperty.call(Alert.SEVERITY, type)) {
      return res.status(400).json({ success: false, error: 'type must be emergency, warning or info' });
    }

    const hasTargets = Array.isArray(targets) && targets.length > 0;
    if (hasTargets) {
      const valid = targets.length <= MAX_TARGETS &&
        targets.every((t) => typeof t === 'string' && t.trim() !== '');
      if (!valid) {
        return res.status(400).json({
          success: false,
          error: `targets must be 1-${MAX_TARGETS} non-empty classroom names`,
        });
      }
    } else if (scope !== 'all') {
      // An alert never becomes school-wide by accident: missing targets require an explicit scope.
      return res.status(400).json({
        success: false,
        error: 'Provide targets, or set scope to "all" for a school-wide alert',
      });
    }

    let expiresAt;
    if (expiresInMinutes !== undefined) {
      const minutes = Number(expiresInMinutes);
      if (!Number.isFinite(minutes) || minutes <= 0 || minutes > 7 * 24 * 60) {
        return res.status(400).json({ success: false, error: 'expiresInMinutes must be between 1 and 10080' });
      }
      expiresAt = new Date(Date.now() + minutes * 60 * 1000);
    }

    const alert = await Alert.create({
      message: message.trim(),
      type,
      scope: hasTargets ? 'selected' : 'all',
      targets: hasTargets ? targets.map((t) => t.trim()) : [],
      expiresAt,
    });

    return res.status(201).json({ success: true, notification: alert.toDisplay() });
  } catch (error) {
    return next(error);
  }
});

module.exports = router;
