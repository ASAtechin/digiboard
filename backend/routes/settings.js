const express = require('express');
const router = express.Router();
const Settings = require('../models/Settings');

// GET /api/settings/:key
router.get('/:key', async (req, res) => {
  try {
    const setting = await Settings.findOne({ key: req.params.key });
    if (!setting) {
      return res.status(404).json({ message: 'Setting not found' });
    }
    res.json(setting);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// POST /api/settings
router.post('/', async (req, res) => {
  try {
    const { key, value, description } = req.body;
    const setting = await Settings.findOneAndUpdate(
      { key },
      { value, description, updatedAt: Date.now() },
      { new: true, upsert: true }
    );
    res.json(setting);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

module.exports = router;
