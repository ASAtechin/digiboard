const express = require('express');
const cors = require('cors');
const path = require('path');
const {
  mockTeachers,
  mockLectures,
  getNextLecture,
  getTodayLectures,
  getWeeklySchedule
} = require('./mockData');

const app = express();
const PORT = process.env.PORT || 5000;

console.log('🚀 Starting DigiBoard Backend in OFFLINE MODE');
console.log('📝 Using mock data - no database connection required');
console.log('');

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Request logging
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  next();
});

// Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    mode: 'offline',
    timestamp: new Date().toISOString(),
    message: 'DigiBoard API is running in offline mode with mock data'
  });
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'DigiBoard Educational Management System API - Offline Mode',
    version: '1.0.0',
    mode: 'offline',
    endpoints: {
      health: '/health',
      schedule: {
        next: '/api/schedule/next',
        today: '/api/schedule/today',
        week: '/api/schedule/week'
      },
      lectures: '/api/lectures',
      teachers: '/api/teachers'
    }
  });
});

// API Routes

// Schedule endpoints
app.get('/api/schedule/next', (req, res) => {
  try {
    const nextLecture = getNextLecture();
    res.json({
      success: true,
      data: nextLecture,
      mode: 'offline'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

app.get('/api/schedule/today', (req, res) => {
  try {
    const todayLectures = getTodayLectures();
    res.json({
      success: true,
      data: todayLectures,
      count: todayLectures.length,
      mode: 'offline'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

app.get('/api/schedule/week', (req, res) => {
  try {
    const weeklySchedule = getWeeklySchedule();
    res.json({
      success: true,
      data: weeklySchedule,
      mode: 'offline'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Lectures endpoint
app.get('/api/lectures', (req, res) => {
  try {
    res.json({
      success: true,
      data: mockLectures,
      count: mockLectures.length,
      mode: 'offline'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Teachers endpoint
app.get('/api/teachers', (req, res) => {
  try {
    res.json({
      success: true,
      data: mockTeachers,
      count: mockTeachers.length,
      mode: 'offline'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Get specific teacher
app.get('/api/teachers/:id', (req, res) => {
  try {
    const teacher = mockTeachers.find(t => t._id === req.params.id);
    if (!teacher) {
      return res.status(404).json({
        success: false,
        error: 'Teacher not found'
      });
    }
    res.json({
      success: true,
      data: teacher,
      mode: 'offline'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Get specific lecture
app.get('/api/lectures/:id', (req, res) => {
  try {
    const lecture = mockLectures.find(l => l._id === req.params.id);
    if (!lecture) {
      return res.status(404).json({
        success: false,
        error: 'Lecture not found'
      });
    }
    res.json({
      success: true,
      data: lecture,
      mode: 'offline'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Analytics endpoint (mock data)
app.get('/api/analytics', (req, res) => {
  res.json({
    success: true,
    data: {
      totalLectures: mockLectures.length,
      totalTeachers: mockTeachers.length,
      lecturesThisWeek: mockLectures.length,
      activeStudents: 150,
      upcomingLectures: mockLectures.filter(l => {
        const { currentDay, currentTime } = require('./mockData');
        return l.dayOfWeek === currentDay && l.startTime > currentTime;
      }).length
    },
    mode: 'offline'
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    error: 'Endpoint not found',
    path: req.path
  });
});

// Error handler
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(500).json({
    success: false,
    error: 'Internal server error',
    message: err.message
  });
});

// Start server
app.listen(PORT, () => {
  console.log('');
  console.log('═══════════════════════════════════════════════════');
  console.log(`🟢 DigiBoard Backend Server (OFFLINE MODE)`);
  console.log(`📡 Server running on: http://localhost:${PORT}`);
  console.log(`🕒 Started at: ${new Date().toLocaleString()}`);
  console.log('═══════════════════════════════════════════════════');
  console.log('');
  console.log('📚 Available Endpoints:');
  console.log(`   GET  /health`);
  console.log(`   GET  /api/schedule/next`);
  console.log(`   GET  /api/schedule/today`);
  console.log(`   GET  /api/schedule/week`);
  console.log(`   GET  /api/lectures`);
  console.log(`   GET  /api/teachers`);
  console.log('');
  console.log('💡 Press Ctrl+C to stop the server');
  console.log('');
});

module.exports = app;
