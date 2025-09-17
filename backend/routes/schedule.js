const express = require('express');
const Lecture = require('../models/Lecture');
const router = express.Router();

// Get next upcoming lecture
router.get('/next', async (req, res) => {
  try {
    const now = new Date();
    const currentDay = now.toLocaleDateString('en-US', { weekday: 'long' });
    const currentTime = now.toTimeString().slice(0, 8);

    // Find next lecture for today
    let nextLecture = await Lecture.findOne({
      dayOfWeek: currentDay,
      isActive: true,
      $expr: {
        $gt: [
          { $dateToString: { format: "%H:%M:%S", date: "$startTime" } },
          currentTime
        ]
      }
    })
    .populate('subject', 'name code')
    .populate('teacher', 'name email department office profileImage phone qualifications experience')
    .sort({ startTime: 1 });

    // If no lecture today, find next lecture this week
    if (!nextLecture) {
      const daysOfWeek = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
      const currentDayIndex = daysOfWeek.indexOf(currentDay);
      const nextDays = daysOfWeek.slice(currentDayIndex + 1).concat(daysOfWeek.slice(0, currentDayIndex + 1));

      for (const day of nextDays) {
        nextLecture = await Lecture.findOne({
          dayOfWeek: day,
          isActive: true
        })
        .populate('subject', 'name code')
        .populate('teacher', 'name email department office profileImage phone qualifications experience')
        .sort({ startTime: 1 });

        if (nextLecture) break;
      }
    }

    if (!nextLecture) {
      return res.status(404).json({ message: 'No upcoming lectures found' });
    }

    res.json(nextLecture);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get today's schedule
router.get('/today', async (req, res) => {
  try {
    // Get current day in multiple timezone formats to handle server timezone issues
    const now = new Date();
    const utcDay = now.toLocaleDateString('en-US', { 
      weekday: 'long',
      timeZone: 'UTC'
    });
    const localDay = now.toLocaleDateString('en-US', { 
      weekday: 'long'
    });
    
    console.log(`Today detection - Local: ${localDay}, UTC: ${utcDay}`);
    
    // Try to find lectures for the current day (try local first, then UTC)
    let todayLectures = await Lecture.find({
      dayOfWeek: localDay,
      isActive: true
    })
    .populate('subject', 'name code')
    .populate('teacher', 'name email department office profileImage')
    .sort({ startTime: 1 });
    
    // If no lectures found with local day, try UTC day
    if (todayLectures.length === 0 && utcDay !== localDay) {
      todayLectures = await Lecture.find({
        dayOfWeek: utcDay,
        isActive: true
      })
      .populate('subject', 'name code')
      .populate('teacher', 'name email department office profileImage')
      .sort({ startTime: 1 });
    }

    console.log(`Found ${todayLectures.length} lectures for today (${localDay})`);
    res.json(todayLectures);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get weekly schedule
router.get('/week', async (req, res) => {
  try {
    const weeklySchedule = await Lecture.find({ isActive: true })
      .populate('subject', 'name code')
      .populate('teacher', 'name email department office profileImage')
      .sort({ dayOfWeek: 1, startTime: 1 });

    // Group by day of week
    const groupedSchedule = weeklySchedule.reduce((acc, lecture) => {
      if (!acc[lecture.dayOfWeek]) {
        acc[lecture.dayOfWeek] = [];
      }
      acc[lecture.dayOfWeek].push(lecture);
      return acc;
    }, {});

    res.json(groupedSchedule);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
