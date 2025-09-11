const express = require('express');
const router = express.Router();
const Teacher = require('../models/Teacher');
const Subject = require('../models/Subject');
const Class = require('../models/Class');
const Syllabus = require('../models/Syllabus');
const Timetable = require('../models/Timetable');
const Lecture = require('../models/Lecture');

// Get comprehensive dashboard data
router.get('/dashboard', async (req, res) => {
  try {
    const { board, academicYear } = req.query;
    
    // Basic filters
    let classFilter = {};
    let syllabusFilter = {};
    let timetableFilter = {};
    
    if (board) {
      classFilter.board = board;
      syllabusFilter.board = board;
    }
    if (academicYear) {
      classFilter.academicYear = academicYear;
      syllabusFilter.academicYear = academicYear;
      timetableFilter.academicYear = academicYear;
    }
    
    // Parallel queries for efficiency
    const [
      totalTeachers,
      totalClasses,
      totalSubjects,
      totalSyllabus,
      totalTimetables,
      todayLectures,
      classesByBoard,
      subjectsByCategory,
      teachersByDepartment,
      syllabusCompletion,
      currentPeriods
    ] = await Promise.all([
      Teacher.countDocuments(),
      Class.countDocuments(classFilter),
      Subject.countDocuments(board ? { board } : {}),
      Syllabus.countDocuments(syllabusFilter),
      Timetable.countDocuments(timetableFilter),
      Lecture.find({
        startTime: {
          $gte: new Date(new Date().setHours(0, 0, 0, 0)),
          $lte: new Date(new Date().setHours(23, 59, 59, 999))
        }
      }).populate('subject', 'name').populate('teacher', 'name').limit(10),
      Class.aggregate([
        { $match: classFilter },
        { $group: { _id: '$board', count: { $sum: 1 }, totalStudents: { $sum: '$totalStudents' } } }
      ]),
      Subject.aggregate([
        { $match: board ? { board } : {} },
        { $group: { _id: '$category', count: { $sum: 1 } } },
        { $sort: { count: -1 } }
      ]),
      Teacher.aggregate([
        { $group: { _id: '$department', count: { $sum: 1 } } },
        { $sort: { count: -1 } }
      ]),
      Syllabus.aggregate([
        { $match: syllabusFilter },
        {
          $group: {
            _id: '$className',
            totalSyllabus: { $sum: 1 },
            avgUnits: { $avg: { $size: '$units' } }
          }
        },
        { $sort: { _id: 1 } }
      ]),
      // Get current periods across all classes
      Timetable.aggregate([
        { $match: timetableFilter },
        { $unwind: '$weeklySchedule' },
        { $unwind: '$weeklySchedule.periods' },
        {
          $lookup: {
            from: 'classes',
            localField: 'class',
            foreignField: '_id',
            as: 'classInfo'
          }
        },
        { $unwind: '$classInfo' },
        {
          $lookup: {
            from: 'subjects',
            localField: 'weeklySchedule.periods.subject',
            foreignField: '_id',
            as: 'subjectInfo'
          }
        },
        { $unwind: { path: '$subjectInfo', preserveNullAndEmptyArrays: true } },
        {
          $lookup: {
            from: 'teachers',
            localField: 'weeklySchedule.periods.teacher',
            foreignField: '_id',
            as: 'teacherInfo'
          }
        },
        { $unwind: { path: '$teacherInfo', preserveNullAndEmptyArrays: true } },
        {
          $match: {
            'weeklySchedule.dayOfWeek': new Date().toLocaleDateString('en-US', { weekday: 'long' }),
            'weeklySchedule.periods.isBreak': { $ne: true }
          }
        },
        {
          $project: {
            className: '$classInfo.className',
            section: '$classInfo.section',
            subject: '$subjectInfo.name',
            teacher: '$teacherInfo.name',
            startTime: '$weeklySchedule.periods.startTime',
            endTime: '$weeklySchedule.periods.endTime',
            classroom: '$weeklySchedule.periods.classroom',
            periodNumber: '$weeklySchedule.periods.periodNumber'
          }
        },
        { $sort: { startTime: 1, className: 1 } },
        { $limit: 20 }
      ])
    ]);
    
    // Calculate total students
    const totalStudents = classesByBoard.reduce((sum, board) => sum + (board.totalStudents || 0), 0);
    
    // Get current time info
    const now = new Date();
    const currentTime = now.toTimeString().slice(0, 5);
    const currentDay = now.toLocaleDateString('en-US', { weekday: 'long' });
    
    // Response data
    const dashboardData = {
      overview: {
        totalTeachers,
        totalClasses,
        totalSubjects,
        totalSyllabus,
        totalTimetables,
        totalStudents,
        currentTime,
        currentDay,
        academicYear: academicYear || '2024-25'
      },
      statistics: {
        classesByBoard,
        subjectsByCategory,
        teachersByDepartment,
        syllabusCompletion
      },
      currentData: {
        todayLectures: todayLectures.map(lecture => ({
          id: lecture._id,
          subject: lecture.subject?.name || 'Unknown',
          teacher: lecture.teacher?.name || 'Unknown',
          classroom: lecture.classroom,
          startTime: lecture.startTime.toTimeString().slice(0, 5),
          endTime: lecture.endTime.toTimeString().slice(0, 5),
          course: lecture.course
        })),
        currentPeriods: currentPeriods.slice(0, 10)
      },
      filters: {
        appliedBoard: board || 'All',
        appliedAcademicYear: academicYear || '2024-25'
      },
      lastUpdated: new Date().toISOString()
    };
    
    res.json(dashboardData);
  } catch (error) {
    console.error('Error fetching dashboard data:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Get subject-wise curriculum progress
router.get('/curriculum-progress', async (req, res) => {
  try {
    const { board, className } = req.query;
    
    let filter = {};
    if (board) filter.board = board;
    if (className) filter.className = className;
    
    const curriculumProgress = await Syllabus.aggregate([
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
        $project: {
          subject: '$subjectInfo.name',
          className: 1,
          board: 1,
          totalUnits: { $size: '$units' },
          totalChapters: {
            $sum: {
              $map: {
                input: '$units',
                as: 'unit',
                in: { $size: '$$unit.chapters' }
              }
            }
          },
          totalHours: {
            $sum: {
              $map: {
                input: '$units',
                as: 'unit',
                in: '$$unit.totalHours'
              }
            }
          },
          evaluationScheme: 1,
          term: 1
        }
      },
      { $sort: { className: 1, subject: 1 } }
    ]);
    
    res.json({
      curriculumProgress,
      summary: {
        totalSubjects: curriculumProgress.length,
        avgUnitsPerSubject: curriculumProgress.reduce((sum, item) => sum + item.totalUnits, 0) / curriculumProgress.length || 0,
        avgChaptersPerSubject: curriculumProgress.reduce((sum, item) => sum + item.totalChapters, 0) / curriculumProgress.length || 0,
        totalEstimatedHours: curriculumProgress.reduce((sum, item) => sum + item.totalHours, 0)
      },
      filters: { board: board || 'All', className: className || 'All' }
    });
  } catch (error) {
    console.error('Error fetching curriculum progress:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Get teacher workload analysis
router.get('/teacher-workload', async (req, res) => {
  try {
    const { department } = req.query;
    
    let teacherFilter = {};
    if (department) teacherFilter.department = department;
    
    const teacherWorkload = await Teacher.aggregate([
      { $match: teacherFilter },
      {
        $lookup: {
          from: 'timetables',
          let: { teacherId: '$_id' },
          pipeline: [
            { $unwind: '$weeklySchedule' },
            { $unwind: '$weeklySchedule.periods' },
            {
              $match: {
                $expr: {
                  $and: [
                    { $eq: ['$weeklySchedule.periods.teacher', '$$teacherId'] },
                    { $ne: ['$weeklySchedule.periods.isBreak', true] }
                  ]
                }
              }
            },
            {
              $group: {
                _id: '$weeklySchedule.dayOfWeek',
                periodsCount: { $sum: 1 }
              }
            }
          ],
          as: 'schedule'
        }
      },
      {
        $project: {
          name: 1,
          email: 1,
          department: 1,
          subjects: 1,
          experience: 1,
          weeklyPeriods: {
            $sum: '$schedule.periodsCount'
          },
          dailySchedule: '$schedule'
        }
      },
      { $sort: { weeklyPeriods: -1, name: 1 } }
    ]);
    
    res.json({
      teacherWorkload,
      summary: {
        totalTeachers: teacherWorkload.length,
        avgWeeklyPeriods: teacherWorkload.reduce((sum, teacher) => sum + teacher.weeklyPeriods, 0) / teacherWorkload.length || 0,
        maxWorkload: Math.max(...teacherWorkload.map(t => t.weeklyPeriods), 0),
        minWorkload: Math.min(...teacherWorkload.map(t => t.weeklyPeriods), 0)
      },
      filters: { department: department || 'All' }
    });
  } catch (error) {
    console.error('Error fetching teacher workload:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Get classroom utilization
router.get('/classroom-utilization', async (req, res) => {
  try {
    const { day } = req.query;
    const targetDay = day || new Date().toLocaleDateString('en-US', { weekday: 'long' });
    
    const classroomUtilization = await Timetable.aggregate([
      { $unwind: '$weeklySchedule' },
      { $match: { 'weeklySchedule.dayOfWeek': targetDay } },
      { $unwind: '$weeklySchedule.periods' },
      {
        $match: {
          'weeklySchedule.periods.isBreak': { $ne: true }
        }
      },
      {
        $group: {
          _id: '$weeklySchedule.periods.classroom',
          periodsCount: { $sum: 1 },
          periods: {
            $push: {
              startTime: '$weeklySchedule.periods.startTime',
              endTime: '$weeklySchedule.periods.endTime',
              periodNumber: '$weeklySchedule.periods.periodNumber'
            }
          }
        }
      },
      {
        $project: {
          classroom: '$_id',
          periodsCount: 1,
          utilizationRate: {
            $multiply: [
              { $divide: ['$periodsCount', 8] }, // Assuming 8 periods max per day
              100
            ]
          },
          periods: 1
        }
      },
      { $sort: { utilizationRate: -1, classroom: 1 } }
    ]);
    
    res.json({
      classroomUtilization,
      summary: {
        totalClassrooms: classroomUtilization.length,
        avgUtilization: classroomUtilization.reduce((sum, room) => sum + room.utilizationRate, 0) / classroomUtilization.length || 0,
        mostUtilized: classroomUtilization[0]?.classroom || 'N/A',
        leastUtilized: classroomUtilization[classroomUtilization.length - 1]?.classroom || 'N/A'
      },
      filters: { day: targetDay }
    });
  } catch (error) {
    console.error('Error fetching classroom utilization:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

module.exports = router;
