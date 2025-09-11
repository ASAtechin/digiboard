const express = require('express');
const router = express.Router();
const Syllabus = require('../models/Syllabus');
const Subject = require('../models/Subject');

// Get all syllabus
router.get('/', async (req, res) => {
  try {
    const { board, className, academicYear, subject } = req.query;
    let filter = {};
    
    if (board) filter.board = board;
    if (className) filter.className = className;
    if (academicYear) filter.academicYear = academicYear;
    if (subject) filter.subject = subject;
    
    const syllabusData = await Syllabus.find(filter)
      .populate('subject', 'name code category')
      .sort({ className: 1, 'subject.name': 1 });
    
    res.json(syllabusData);
  } catch (error) {
    console.error('Error fetching syllabus:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Get syllabus by ID
router.get('/:id', async (req, res) => {
  try {
    const syllabus = await Syllabus.findById(req.params.id)
      .populate('subject', 'name code category board');
    
    if (!syllabus) {
      return res.status(404).json({ message: 'Syllabus not found' });
    }
    
    res.json(syllabus);
  } catch (error) {
    console.error('Error fetching syllabus:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Get syllabus by class and board
router.get('/class/:className/board/:board', async (req, res) => {
  try {
    const { className, board } = req.params;
    const { academicYear } = req.query;
    
    let filter = { 
      className: className,
      board: board.toUpperCase()
    };
    
    if (academicYear) filter.academicYear = academicYear;
    
    const syllabusData = await Syllabus.find(filter)
      .populate('subject', 'name code category')
      .sort({ 'subject.name': 1 });
    
    res.json(syllabusData);
  } catch (error) {
    console.error('Error fetching syllabus by class and board:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Get syllabus by subject
router.get('/subject/:subjectId', async (req, res) => {
  try {
    const { subjectId } = req.params;
    const { className, academicYear } = req.query;
    
    let filter = { subject: subjectId };
    if (className) filter.className = className;
    if (academicYear) filter.academicYear = academicYear;
    
    const syllabusData = await Syllabus.find(filter)
      .populate('subject', 'name code category board')
      .sort({ className: 1, academicYear: -1 });
    
    res.json(syllabusData);
  } catch (error) {
    console.error('Error fetching syllabus by subject:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Get syllabus units by month
router.get('/:id/month/:month', async (req, res) => {
  try {
    const { id, month } = req.params;
    
    const syllabus = await Syllabus.findById(id)
      .populate('subject', 'name code category board');
    
    if (!syllabus) {
      return res.status(404).json({ message: 'Syllabus not found' });
    }
    
    // Filter units and chapters by month
    const monthlyContent = syllabus.units.map(unit => {
      const chaptersInMonth = unit.chapters.filter(chapter => 
        chapter.month && chapter.month.toLowerCase() === month.toLowerCase()
      );
      
      if (chaptersInMonth.length > 0) {
        return {
          ...unit.toObject(),
          chapters: chaptersInMonth
        };
      }
      return null;
    }).filter(unit => unit !== null);
    
    res.json({
      subject: syllabus.subject,
      className: syllabus.className,
      board: syllabus.board,
      academicYear: syllabus.academicYear,
      month: month,
      units: monthlyContent
    });
  } catch (error) {
    console.error('Error fetching monthly syllabus:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Get curriculum overview/statistics
router.get('/stats/overview', async (req, res) => {
  try {
    const { board, academicYear } = req.query;
    let filter = {};
    
    if (board) filter.board = board;
    if (academicYear) filter.academicYear = academicYear;
    
    const totalSyllabus = await Syllabus.countDocuments(filter);
    
    const syllabusByBoard = await Syllabus.aggregate([
      { $match: filter },
      {
        $group: {
          _id: '$board',
          count: { $sum: 1 }
        }
      }
    ]);
    
    const syllabusByClass = await Syllabus.aggregate([
      { $match: filter },
      {
        $group: {
          _id: '$className',
          count: { $sum: 1 }
        }
      },
      { $sort: { _id: 1 } }
    ]);
    
    const avgUnitsPerSyllabus = await Syllabus.aggregate([
      { $match: filter },
      {
        $group: {
          _id: null,
          avgUnits: { $avg: { $size: '$units' } },
          totalUnits: { $sum: { $size: '$units' } }
        }
      }
    ]);
    
    const subjectDistribution = await Syllabus.aggregate([
      { $match: filter },
      {
        $lookup: {
          from: 'subjects',
          localField: 'subject',
          foreignField: '_id',
          as: 'subjectInfo'
        }
      },
      { $unwind: '$subjectInfo' },
      {
        $group: {
          _id: '$subjectInfo.category',
          count: { $sum: 1 }
        }
      },
      { $sort: { count: -1 } }
    ]);
    
    res.json({
      totalSyllabus,
      syllabusByBoard,
      syllabusByClass,
      avgUnitsPerSyllabus: avgUnitsPerSyllabus[0] || { avgUnits: 0, totalUnits: 0 },
      subjectDistribution
    });
  } catch (error) {
    console.error('Error fetching syllabus statistics:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Create new syllabus
router.post('/', async (req, res) => {
  try {
    // Validate if subject exists
    const subject = await Subject.findById(req.body.subject);
    if (!subject) {
      return res.status(400).json({ message: 'Subject not found' });
    }
    
    // Check if syllabus already exists for this subject and class
    const existingSyllabus = await Syllabus.findOne({
      subject: req.body.subject,
      className: req.body.className,
      board: req.body.board,
      academicYear: req.body.academicYear
    });
    
    if (existingSyllabus) {
      return res.status(400).json({ 
        message: 'Syllabus already exists for this subject, class, and academic year' 
      });
    }
    
    const syllabus = new Syllabus(req.body);
    const savedSyllabus = await syllabus.save();
    
    const populatedSyllabus = await Syllabus.findById(savedSyllabus._id)
      .populate('subject', 'name code category board');
    
    res.status(201).json(populatedSyllabus);
  } catch (error) {
    console.error('Error creating syllabus:', error);
    
    if (error.name === 'ValidationError') {
      const errors = Object.values(error.errors).map(err => err.message);
      return res.status(400).json({ message: 'Validation error', errors });
    }
    
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Update syllabus
router.put('/:id', async (req, res) => {
  try {
    // If subject is being updated, validate it exists
    if (req.body.subject) {
      const subject = await Subject.findById(req.body.subject);
      if (!subject) {
        return res.status(400).json({ message: 'Subject not found' });
      }
    }
    
    const updatedSyllabus = await Syllabus.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    ).populate('subject', 'name code category board');
    
    if (!updatedSyllabus) {
      return res.status(404).json({ message: 'Syllabus not found' });
    }
    
    res.json(updatedSyllabus);
  } catch (error) {
    console.error('Error updating syllabus:', error);
    
    if (error.name === 'ValidationError') {
      const errors = Object.values(error.errors).map(err => err.message);
      return res.status(400).json({ message: 'Validation error', errors });
    }
    
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Delete syllabus
router.delete('/:id', async (req, res) => {
  try {
    const deletedSyllabus = await Syllabus.findByIdAndDelete(req.params.id);
    
    if (!deletedSyllabus) {
      return res.status(404).json({ message: 'Syllabus not found' });
    }
    
    res.json({ message: 'Syllabus deleted successfully' });
  } catch (error) {
    console.error('Error deleting syllabus:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Add unit to syllabus
router.post('/:id/units', async (req, res) => {
  try {
    const { id } = req.params;
    const unitData = req.body;
    
    const syllabus = await Syllabus.findById(id);
    if (!syllabus) {
      return res.status(404).json({ message: 'Syllabus not found' });
    }
    
    // Check if unit number already exists
    const existingUnit = syllabus.units.find(
      unit => unit.unitNumber === unitData.unitNumber
    );
    
    if (existingUnit) {
      return res.status(400).json({ 
        message: 'Unit with this number already exists' 
      });
    }
    
    syllabus.units.push(unitData);
    await syllabus.save();
    
    const updatedSyllabus = await Syllabus.findById(id)
      .populate('subject', 'name code category board');
    
    res.json(updatedSyllabus);
  } catch (error) {
    console.error('Error adding unit:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Update unit in syllabus
router.put('/:id/units/:unitId', async (req, res) => {
  try {
    const { id, unitId } = req.params;
    const unitData = req.body;
    
    const syllabus = await Syllabus.findById(id);
    if (!syllabus) {
      return res.status(404).json({ message: 'Syllabus not found' });
    }
    
    const unitIndex = syllabus.units.findIndex(
      unit => unit._id.toString() === unitId
    );
    
    if (unitIndex === -1) {
      return res.status(404).json({ message: 'Unit not found' });
    }
    
    syllabus.units[unitIndex] = { ...syllabus.units[unitIndex].toObject(), ...unitData };
    await syllabus.save();
    
    const updatedSyllabus = await Syllabus.findById(id)
      .populate('subject', 'name code category board');
    
    res.json(updatedSyllabus);
  } catch (error) {
    console.error('Error updating unit:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Delete unit from syllabus
router.delete('/:id/units/:unitId', async (req, res) => {
  try {
    const { id, unitId } = req.params;
    
    const syllabus = await Syllabus.findById(id);
    if (!syllabus) {
      return res.status(404).json({ message: 'Syllabus not found' });
    }
    
    syllabus.units = syllabus.units.filter(
      unit => unit._id.toString() !== unitId
    );
    
    await syllabus.save();
    
    const updatedSyllabus = await Syllabus.findById(id)
      .populate('subject', 'name code category board');
    
    res.json(updatedSyllabus);
  } catch (error) {
    console.error('Error deleting unit:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

module.exports = router;
