const express = require('express');
const router = express.Router();
const Timetable = require('../models/Timetable');
const Class = require('../models/Class');
const Subject = require('../models/Subject');
const Teacher = require('../models/Teacher');

// Get all timetables
router.get('/', async (req, res) => {
  try {
    const { academicYear, className, board } = req.query;
    let filter = {};
    
    if (academicYear) filter.academicYear = academicYear;
    
    const timetables = await Timetable.find(filter)
      .populate({
        path: 'class',
        select: 'className section board academicYear totalStudents',
        populate: {
          path: 'classTeacher',
          select: 'name email department'
        }
      })
      .populate({
        path: 'weeklySchedule.periods.subject',
        select: 'name code category'
      })
      .populate({
        path: 'weeklySchedule.periods.teacher',
        select: 'name department email'
      })
      .sort({ 'class.className': 1, 'class.section': 1 });
    
    // Filter by className and board if provided
    let filteredTimetables = timetables;
    if (className) {
      filteredTimetables = filteredTimetables.filter(t => 
        t.class && t.class.className === className
      );
    }
    if (board) {
      filteredTimetables = filteredTimetables.filter(t => 
        t.class && t.class.board === board.toUpperCase()
      );
    }
    
    res.json(filteredTimetables);
  } catch (error) {
    console.error('Error fetching timetables:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Get timetable by ID
router.get('/:id', async (req, res) => {
  try {
    const timetable = await Timetable.findById(req.params.id)
      .populate({
        path: 'class',
        select: 'className section board academicYear totalStudents',
        populate: {
          path: 'classTeacher',
          select: 'name email department phone office'
        }
      })
      .populate({
        path: 'weeklySchedule.periods.subject',
        select: 'name code category'
      })
      .populate({
        path: 'weeklySchedule.periods.teacher',
        select: 'name department email phone office'
      });
    
    if (!timetable) {
      return res.status(404).json({ message: 'Timetable not found' });
    }
    
    res.json(timetable);
  } catch (error) {
    console.error('Error fetching timetable:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Get timetable by class ID
router.get('/class/:classId', async (req, res) => {
  try {
    const { classId } = req.params;
    const { academicYear } = req.query;
    
    let filter = { class: classId };
    if (academicYear) filter.academicYear = academicYear;
    
    const timetable = await Timetable.findOne(filter)
      .populate({
        path: 'class',
        select: 'className section board academicYear totalStudents',
        populate: {
          path: 'classTeacher',
          select: 'name email department phone office'
        }
      })
      .populate({
        path: 'weeklySchedule.periods.subject',
        select: 'name code category'
      })
      .populate({
        path: 'weeklySchedule.periods.teacher',
        select: 'name department email phone office'
      });
    
    if (!timetable) {
      return res.status(404).json({ message: 'Timetable not found for this class' });
    }
    
    res.json(timetable);
  } catch (error) {
    console.error('Error fetching timetable by class:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Get today's schedule for a class
router.get('/class/:classId/today', async (req, res) => {
  try {
    const { classId } = req.params;
    const today = new Date();
    const dayName = today.toLocaleDateString('en-US', { weekday: 'long' });
    
    const timetable = await Timetable.findOne({ 
      class: classId,
      effectiveFrom: { $lte: today },
      effectiveTo: { $gte: today }
    })
      .populate({
        path: 'class',
        select: 'className section board academicYear'
      })
      .populate({
        path: 'weeklySchedule.periods.subject',
        select: 'name code category'
      })
      .populate({
        path: 'weeklySchedule.periods.teacher',
        select: 'name department email phone'
      });
    
    if (!timetable) {
      return res.status(404).json({ message: 'No active timetable found for this class' });
    }
    
    const todaySchedule = timetable.weeklySchedule.find(
      schedule => schedule.dayOfWeek === dayName
    );
    
    if (!todaySchedule) {
      return res.json({
        class: timetable.class,
        dayOfWeek: dayName,
        periods: [],
        breakTimings: timetable.breakTimings,
        message: 'No schedule found for today'
      });
    }
    
    res.json({
      class: timetable.class,
      dayOfWeek: dayName,
      periods: todaySchedule.periods,
      breakTimings: timetable.breakTimings,
      specialSchedules: timetable.specialSchedules?.filter(special => {
        const specialDate = new Date(special.date);
        return specialDate.toDateString() === today.toDateString();
      }) || []
    });
  } catch (error) {
    console.error('Error fetching today\'s schedule:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Get current period for a class
router.get('/class/:classId/current', async (req, res) => {
  try {
    const { classId } = req.params;
    const now = new Date();
    const dayName = now.toLocaleDateString('en-US', { weekday: 'long' });
    const currentTime = now.toTimeString().slice(0, 5); // HH:MM format
    
    const timetable = await Timetable.findOne({ 
      class: classId,
      effectiveFrom: { $lte: now },
      effectiveTo: { $gte: now }
    })
      .populate({
        path: 'class',
        select: 'className section board academicYear'
      })
      .populate({
        path: 'weeklySchedule.periods.subject',
        select: 'name code category'
      })
      .populate({
        path: 'weeklySchedule.periods.teacher',
        select: 'name department email phone office'
      });
    
    if (!timetable) {
      return res.status(404).json({ message: 'No active timetable found for this class' });
    }
    
    const todaySchedule = timetable.weeklySchedule.find(
      schedule => schedule.dayOfWeek === dayName
    );
    
    if (!todaySchedule) {
      return res.json({
        class: timetable.class,
        dayOfWeek: dayName,
        currentPeriod: null,
        nextPeriod: null,
        message: 'No schedule found for today'
      });
    }
    
    // Find current and next period
    let currentPeriod = null;
    let nextPeriod = null;
    
    for (let i = 0; i < todaySchedule.periods.length; i++) {
      const period = todaySchedule.periods[i];
      
      if (currentTime >= period.startTime && currentTime <= period.endTime) {
        currentPeriod = period;
        nextPeriod = todaySchedule.periods[i + 1] || null;
        break;
      } else if (currentTime < period.startTime) {
        nextPeriod = period;
        break;
      }
    }
    
    res.json({
      class: timetable.class,
      dayOfWeek: dayName,
      currentTime,
      currentPeriod,
      nextPeriod,
      allPeriodsToday: todaySchedule.periods
    });
  } catch (error) {
    console.error('Error fetching current period:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Get weekly schedule for a class
router.get('/class/:classId/week', async (req, res) => {
  try {
    const { classId } = req.params;
    const { academicYear } = req.query;
    
    let filter = { class: classId };
    if (academicYear) filter.academicYear = academicYear;
    
    const timetable = await Timetable.findOne(filter)
      .populate({
        path: 'class',
        select: 'className section board academicYear'
      })
      .populate({
        path: 'weeklySchedule.periods.subject',
        select: 'name code category'
      })
      .populate({
        path: 'weeklySchedule.periods.teacher',
        select: 'name department email'
      });
    
    if (!timetable) {
      return res.status(404).json({ message: 'Timetable not found for this class' });
    }
    
    res.json({
      class: timetable.class,
      academicYear: timetable.academicYear,
      weeklySchedule: timetable.weeklySchedule,
      breakTimings: timetable.breakTimings
    });
  } catch (error) {
    console.error('Error fetching weekly schedule:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Get timetable statistics
router.get('/stats/overview', async (req, res) => {
  try {
    const { academicYear, board } = req.query;
    
    let classFilter = {};
    if (board) classFilter.board = board;
    
    let timetableFilter = {};
    if (academicYear) timetableFilter.academicYear = academicYear;
    
    const totalTimetables = await Timetable.countDocuments(timetableFilter);
    
    const timetablesByClass = await Timetable.aggregate([
      { $match: timetableFilter },
      {
        $lookup: {
          from: 'classes',
          localField: 'class',
          foreignField: '_id',
          as: 'classInfo'
        }
      },
      { $unwind: '$classInfo' },
      { $match: { 'classInfo.board': { $exists: true, ...classFilter } } },
      {
        $group: {
          _id: '$classInfo.className',
          count: { $sum: 1 }
        }
      },
      { $sort: { _id: 1 } }
    ]);
    
    const avgPeriodsPerDay = await Timetable.aggregate([
      { $match: timetableFilter },
      { $unwind: '$weeklySchedule' },
      {
        $group: {
          _id: null,
          avgPeriods: { $avg: { $size: '$weeklySchedule.periods' } },
          totalPeriods: { $sum: { $size: '$weeklySchedule.periods' } },
          totalDays: { $sum: 1 }
        }
      }
    ]);
    
    res.json({
      totalTimetables,
      timetablesByClass,
      avgPeriodsPerDay: avgPeriodsPerDay[0] || { avgPeriods: 0, totalPeriods: 0, totalDays: 0 }
    });
  } catch (error) {
    console.error('Error fetching timetable statistics:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Create new timetable
router.post('/', async (req, res) => {
  try {
    // Validate if class exists
    const classData = await Class.findById(req.body.class);
    if (!classData) {
      return res.status(400).json({ message: 'Class not found' });
    }
    
    // Check if timetable already exists for this class and academic year
    const existingTimetable = await Timetable.findOne({
      class: req.body.class,
      academicYear: req.body.academicYear
    });
    
    if (existingTimetable) {
      return res.status(400).json({ 
        message: 'Timetable already exists for this class and academic year' 
      });
    }
    
    const timetable = new Timetable(req.body);
    const savedTimetable = await timetable.save();
    
    const populatedTimetable = await Timetable.findById(savedTimetable._id)
      .populate({
        path: 'class',
        select: 'className section board academicYear'
      })
      .populate({
        path: 'weeklySchedule.periods.subject',
        select: 'name code category'
      })
      .populate({
        path: 'weeklySchedule.periods.teacher',
        select: 'name department email'
      });
    
    res.status(201).json(populatedTimetable);
  } catch (error) {
    console.error('Error creating timetable:', error);
    
    if (error.name === 'ValidationError') {
      const errors = Object.values(error.errors).map(err => err.message);
      return res.status(400).json({ message: 'Validation error', errors });
    }
    
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Update timetable
router.put('/:id', async (req, res) => {
  try {
    // If class is being updated, validate it exists
    if (req.body.class) {
      const classData = await Class.findById(req.body.class);
      if (!classData) {
        return res.status(400).json({ message: 'Class not found' });
      }
    }
    
    const updatedTimetable = await Timetable.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    )
      .populate({
        path: 'class',
        select: 'className section board academicYear'
      })
      .populate({
        path: 'weeklySchedule.periods.subject',
        select: 'name code category'
      })
      .populate({
        path: 'weeklySchedule.periods.teacher',
        select: 'name department email'
      });
    
    if (!updatedTimetable) {
      return res.status(404).json({ message: 'Timetable not found' });
    }
    
    res.json(updatedTimetable);
  } catch (error) {
    console.error('Error updating timetable:', error);
    
    if (error.name === 'ValidationError') {
      const errors = Object.values(error.errors).map(err => err.message);
      return res.status(400).json({ message: 'Validation error', errors });
    }
    
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Delete timetable
router.delete('/:id', async (req, res) => {
  try {
    const deletedTimetable = await Timetable.findByIdAndDelete(req.params.id);
    
    if (!deletedTimetable) {
      return res.status(404).json({ message: 'Timetable not found' });
    }
    
    res.json({ message: 'Timetable deleted successfully' });
  } catch (error) {
    console.error('Error deleting timetable:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Add special schedule (for events, holidays, etc.)
router.post('/:id/special', async (req, res) => {
  try {
    const { id } = req.params;
    const specialSchedule = req.body;
    
    const timetable = await Timetable.findById(id);
    if (!timetable) {
      return res.status(404).json({ message: 'Timetable not found' });
    }
    
    if (!timetable.specialSchedules) {
      timetable.specialSchedules = [];
    }
    
    timetable.specialSchedules.push(specialSchedule);
    await timetable.save();
    
    const updatedTimetable = await Timetable.findById(id)
      .populate({
        path: 'class',
        select: 'className section board academicYear'
      });
    
    res.json(updatedTimetable);
  } catch (error) {
    console.error('Error adding special schedule:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

module.exports = router;
