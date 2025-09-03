const express = require('express');
const Lecture = require('../models/Lecture');
const router = express.Router();

// Get all lectures
router.get('/', async (req, res) => {
  try {
    const lectures = await Lecture.find({ isActive: true })
      .populate('teacher', 'name email department office profileImage')
      .sort({ startTime: 1 });
    res.json(lectures);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get lecture by ID
router.get('/:id', async (req, res) => {
  try {
    const lecture = await Lecture.findById(req.params.id)
      .populate('teacher', 'name email department office profileImage phone qualifications experience');
    if (!lecture) {
      return res.status(404).json({ message: 'Lecture not found' });
    }
    res.json(lecture);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Create new lecture
router.post('/', async (req, res) => {
  try {
    const lecture = new Lecture(req.body);
    const savedLecture = await lecture.save();
    res.status(201).json(savedLecture);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

// Update lecture
router.put('/:id', async (req, res) => {
  try {
    const lecture = await Lecture.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    ).populate('teacher', 'name email department office profileImage');
    if (!lecture) {
      return res.status(404).json({ message: 'Lecture not found' });
    }
    res.json(lecture);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

// Delete lecture
router.delete('/:id', async (req, res) => {
  try {
    const lecture = await Lecture.findByIdAndDelete(req.params.id);
    if (!lecture) {
      return res.status(404).json({ message: 'Lecture not found' });
    }
    res.json({ message: 'Lecture deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
