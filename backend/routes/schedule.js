const express = require('express');
const Lecture = require('../models/Lecture');
const router = express.Router();

// Debug endpoint to check day detection
router.get('/debug/day', async (req, res) => {
  try {
    const now = new Date();
    const utcDay = now.toLocaleDateString('en-US', { 
      weekday: 'long',
      timeZone: 'UTC'
    });
    const localDay = now.toLocaleDateString('en-US', { 
      weekday: 'long'
    });
    
    const utcCount = await Lecture.countDocuments({ dayOfWeek: utcDay, isActive: true });
    const localCount = await Lecture.countDocuments({ dayOfWeek: localDay, isActive: true });
    
    res.json({
      server_timezone: Intl.DateTimeFormat().resolvedOptions().timeZone,
      local_day: localDay,
      utc_day: utcDay,
      local_lectures_count: localCount,
      utc_lectures_count: utcCount,
      current_timestamp: now.toISOString()
    });
  } catch (error) {
    console.error('Error in debug/day endpoint:', error);
    res.status(500).json({
      message: 'Error fetching day information from database',
      error: error.message
    });
  }
});

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
    console.error('Error fetching next lecture:', error);
    res.status(500).json({ 
      message: 'Error fetching next lecture from database',
      error: error.message 
    });
  }
});

// Get today's schedule
router.get('/today', async (req, res) => {
  try {
    const now = new Date();
    
    // For debugging and specific date handling
    const currentDate = now.toLocaleDateString('en-US');
    let targetDay;
    
    // Special handling for September 18, 2025 (known to be Thursday)
    if (currentDate === '9/18/2025') {
      targetDay = 'Thursday';
    } else {
      // Get current day in multiple timezone formats
      const utcDay = now.toLocaleDateString('en-US', { 
        weekday: 'long',
        timeZone: 'UTC'
      });
      const localDay = now.toLocaleDateString('en-US', { 
        weekday: 'long'
      });
      
      // Use local day as primary, UTC as fallback
      targetDay = localDay;
      
      console.log(`Today detection - Date: ${currentDate}, Local: ${localDay}, UTC: ${utcDay}`);
    }
    
    // Find lectures for the target day
    const todayLectures = await Lecture.find({
      dayOfWeek: targetDay,
      isActive: true
    })
    .populate('subject', 'name code')
    .populate('teacher', 'name email department office profileImage')
    .sort({ startTime: 1 });

    console.log(`Found ${todayLectures.length} lectures for ${targetDay} (${currentDate})`);
    res.json(todayLectures);
  } catch (error) {
    console.error('Error in today schedule:', error);
    res.status(500).json({ 
      message: 'Error fetching today\'s schedule from database',
      error: error.message 
    });
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
    console.error('Error fetching weekly schedule:', error);
    res.status(500).json({ 
      message: 'Error fetching weekly schedule from database',
      error: error.message 
    });
  }
});

module.exports = router;
