const express = require('express');
const router = express.Router();
const Class = require('../models/Class');
const Subject = require('../models/Subject');
const Syllabus = require('../models/Syllabus');
const Timetable = require('../models/Timetable');

// Get all classes
router.get('/', async (req, res) => {
  try {
    const { board, academicYear } = req.query;
    let filter = {};
    
    if (board) filter.board = board;
    if (academicYear) filter.academicYear = academicYear;
    
    const classes = await Class.find(filter)
      .populate('classTeacher', 'name email department')
      .sort({ className: 1, section: 1 });
    
    res.json(classes);
  } catch (error) {
    console.error('Error fetching classes:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Get class by ID
router.get('/:id', async (req, res) => {
  try {
    const classData = await Class.findById(req.params.id)
      .populate('classTeacher', 'name email department phone office');
    
    if (!classData) {
      return res.status(404).json({ message: 'Class not found' });
    }
    
    res.json(classData);
  } catch (error) {
    console.error('Error fetching class:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Get classes by board
router.get('/board/:board', async (req, res) => {
  try {
    const { board } = req.params;
    const classes = await Class.find({ board: board.toUpperCase() })
      .populate('classTeacher', 'name email department')
      .sort({ className: 1, section: 1 });
    
    res.json(classes);
  } catch (error) {
    console.error('Error fetching classes by board:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Get class statistics
router.get('/stats/overview', async (req, res) => {
  try {
    const totalClasses = await Class.countDocuments();
    const cbseClasses = await Class.countDocuments({ board: 'CBSE' });
    const icseClasses = await Class.countDocuments({ board: 'ICSE' });
    
    const totalStudents = await Class.aggregate([
      {
        $group: {
          _id: null,
          total: { $sum: '$totalStudents' }
        }
      }
    ]);
    
    const classesByLevel = await Class.aggregate([
      {
        $group: {
          _id: '$className',
          count: { $sum: 1 },
          totalStudents: { $sum: '$totalStudents' }
        }
      },
      { $sort: { _id: 1 } }
    ]);
    
    res.json({
      totalClasses,
      cbseClasses,
      icseClasses,
      totalStudents: totalStudents[0]?.total || 0,
      classesByLevel
    });
  } catch (error) {
    console.error('Error fetching class statistics:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Create new class
router.post('/', async (req, res) => {
  try {
    const classData = new Class(req.body);
    const savedClass = await classData.save();
    
    const populatedClass = await Class.findById(savedClass._id)
      .populate('classTeacher', 'name email department');
    
    res.status(201).json(populatedClass);
  } catch (error) {
    console.error('Error creating class:', error);
    
    if (error.name === 'ValidationError') {
      const errors = Object.values(error.errors).map(err => err.message);
      return res.status(400).json({ message: 'Validation error', errors });
    }
    
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Update class
router.put('/:id', async (req, res) => {
  try {
    const updatedClass = await Class.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    ).populate('classTeacher', 'name email department');
    
    if (!updatedClass) {
      return res.status(404).json({ message: 'Class not found' });
    }
    
    res.json(updatedClass);
  } catch (error) {
    console.error('Error updating class:', error);
    
    if (error.name === 'ValidationError') {
      const errors = Object.values(error.errors).map(err => err.message);
      return res.status(400).json({ message: 'Validation error', errors });
    }
    
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Delete class
router.delete('/:id', async (req, res) => {
  try {
    const deletedClass = await Class.findByIdAndDelete(req.params.id);
    
    if (!deletedClass) {
      return res.status(404).json({ message: 'Class not found' });
    }
    
    res.json({ message: 'Class deleted successfully' });
  } catch (error) {
    console.error('Error deleting class:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Add student to class
router.post('/:id/students', async (req, res) => {
  try {
    const { id } = req.params;
    const studentData = req.body;
    
    const classData = await Class.findById(id);
    if (!classData) {
      return res.status(404).json({ message: 'Class not found' });
    }
    
    // Check if student with same roll number already exists
    const existingStudent = classData.students.find(
      student => student.rollNumber === studentData.rollNumber
    );
    
    if (existingStudent) {
      return res.status(400).json({ 
        message: 'Student with this roll number already exists in the class' 
      });
    }
    
    classData.students.push(studentData);
    classData.totalStudents = classData.students.length;
    
    await classData.save();
    
    const updatedClass = await Class.findById(id)
      .populate('classTeacher', 'name email department');
    
    res.json(updatedClass);
  } catch (error) {
    console.error('Error adding student:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Remove student from class
router.delete('/:id/students/:studentId', async (req, res) => {
  try {
    const { id, studentId } = req.params;
    
    const classData = await Class.findById(id);
    if (!classData) {
      return res.status(404).json({ message: 'Class not found' });
    }
    
    classData.students = classData.students.filter(
      student => student._id.toString() !== studentId
    );
    classData.totalStudents = classData.students.length;
    
    await classData.save();
    
    const updatedClass = await Class.findById(id)
      .populate('classTeacher', 'name email department');
    
    res.json(updatedClass);
  } catch (error) {
    console.error('Error removing student:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

module.exports = router;
