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
    const today = new Date().toLocaleDateString('en-US', { weekday: 'long' });
    
    const todayLectures = await Lecture.find({
      dayOfWeek: today,
      isActive: true
    })
    .populate('teacher', 'name email department office profileImage')
    .sort({ startTime: 1 });

    res.json(todayLectures);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get weekly schedule
router.get('/week', async (req, res) => {
  try {
    const weeklySchedule = await Lecture.find({ isActive: true })
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
