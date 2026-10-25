const express = require('express');
const router = express.Router();
const Subject = require('../models/Subject');

// Get all subjects
router.get('/', async (req, res) => {
  try {
    const { board, category, className } = req.query;
    let filter = {};
    
    if (board) filter.board = board;
    if (category) filter.category = category;
    
    let subjects = await Subject.find(filter).sort({ name: 1 });
    
    // Filter by className if provided
    if (className) {
      subjects = subjects.filter(subject => 
        subject.classes.some(c => c.className === className)
      );
    }
    
    res.json(subjects);
  } catch (error) {
    console.error('Error fetching subjects:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Get subject by ID
router.get('/:id', async (req, res) => {
  try {
    const subject = await Subject.findById(req.params.id);
    
    if (!subject) {
      return res.status(404).json({ message: 'Subject not found' });
    }
    
    res.json(subject);
  } catch (error) {
    console.error('Error fetching subject:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Get subjects by board
router.get('/board/:board', async (req, res) => {
  try {
    const { board } = req.params;
    const { className } = req.query;
    
    let subjects = await Subject.find({ board: board.toUpperCase() })
      .sort({ category: 1, name: 1 });
    
    // Filter by className if provided
    if (className) {
      subjects = subjects.filter(subject => 
        subject.classes.some(c => c.className === className)
      );
    }
    
    res.json(subjects);
  } catch (error) {
    console.error('Error fetching subjects by board:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Get subjects by category
router.get('/category/:category', async (req, res) => {
  try {
    const { category } = req.params;
    const { board, className } = req.query;
    
    let filter = { category };
    if (board) filter.board = board;
    
    let subjects = await Subject.find(filter).sort({ name: 1 });
    
    // Filter by className if provided
    if (className) {
      subjects = subjects.filter(subject => 
        subject.classes.some(c => c.className === className)
      );
    }
    
    res.json(subjects);
  } catch (error) {
    console.error('Error fetching subjects by category:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Get subjects for specific class
router.get('/class/:className', async (req, res) => {
  try {
    const { className } = req.params;
    const { board } = req.query;
    
    let filter = {};
    if (board) filter.board = board;
    
    const subjects = await Subject.find(filter);
    
    // Filter subjects that are offered for the specific class
    const classSubjects = subjects.filter(subject => 
      subject.classes.some(c => c.className === className)
    ).map(subject => {
      const classData = subject.classes.find(c => c.className === className);
      return {
        ...subject.toObject(),
        classSpecificData: classData
      };
    });
    
    res.json(classSubjects);
  } catch (error) {
    console.error('Error fetching subjects for class:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Get subject statistics
router.get('/stats/overview', async (req, res) => {
  try {
    const totalSubjects = await Subject.countDocuments();
    const cbseSubjects = await Subject.countDocuments({ board: 'CBSE' });
    const icseSubjects = await Subject.countDocuments({ board: 'ICSE' });
    
    const subjectsByCategory = await Subject.aggregate([
      {
        $group: {
          _id: '$category',
          count: { $sum: 1 }
        }
      },
      { $sort: { _id: 1 } }
    ]);
    
    const subjectsByBoard = await Subject.aggregate([
      {
        $group: {
          _id: '$board',
          count: { $sum: 1 }
        }
      }
    ]);
    
    res.json({
      totalSubjects,
      cbseSubjects,
      icseSubjects,
      subjectsByCategory,
      subjectsByBoard
    });
  } catch (error) {
    console.error('Error fetching subject statistics:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Create new subject
router.post('/', async (req, res) => {
  try {
    const subject = new Subject(req.body);
    const savedSubject = await subject.save();
    res.status(201).json(savedSubject);
  } catch (error) {
    console.error('Error creating subject:', error);
    
    if (error.name === 'ValidationError') {
      const errors = Object.values(error.errors).map(err => err.message);
      return res.status(400).json({ message: 'Validation error', errors });
    }
    
    if (error.code === 11000) {
      return res.status(400).json({ 
        message: 'Subject with this code and board already exists' 
      });
    }
    
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Update subject
router.put('/:id', async (req, res) => {
  try {
    const updatedSubject = await Subject.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    );
    
    if (!updatedSubject) {
      return res.status(404).json({ message: 'Subject not found' });
    }
    
    res.json(updatedSubject);
  } catch (error) {
    console.error('Error updating subject:', error);
    
    if (error.name === 'ValidationError') {
      const errors = Object.values(error.errors).map(err => err.message);
      return res.status(400).json({ message: 'Validation error', errors });
    }
    
    if (error.code === 11000) {
      return res.status(400).json({ 
        message: 'Subject with this code and board already exists' 
      });
    }
    
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Delete subject
router.delete('/:id', async (req, res) => {
  try {
    const deletedSubject = await Subject.findByIdAndDelete(req.params.id);
    
    if (!deletedSubject) {
      return res.status(404).json({ message: 'Subject not found' });
    }
    
    res.json({ message: 'Subject deleted successfully' });
  } catch (error) {
    console.error('Error deleting subject:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Add class to subject
router.post('/:id/classes', async (req, res) => {
  try {
    const { id } = req.params;
    const classData = req.body;
    
    const subject = await Subject.findById(id);
    if (!subject) {
      return res.status(404).json({ message: 'Subject not found' });
    }
    
    // Check if class already exists for this subject
    const existingClass = subject.classes.find(
      c => c.className === classData.className
    );
    
    if (existingClass) {
      return res.status(400).json({ 
        message: 'This class is already associated with this subject' 
      });
    }
    
    subject.classes.push(classData);
    await subject.save();
    
    res.json(subject);
  } catch (error) {
    console.error('Error adding class to subject:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Remove class from subject
router.delete('/:id/classes/:className', async (req, res) => {
  try {
    const { id, className } = req.params;
    
    const subject = await Subject.findById(id);
    if (!subject) {
      return res.status(404).json({ message: 'Subject not found' });
    }
    
    subject.classes = subject.classes.filter(c => c.className !== className);
    await subject.save();
    
    res.json(subject);
  } catch (error) {
    console.error('Error removing class from subject:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

module.exports = router;
