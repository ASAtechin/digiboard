const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = 5000;

// Middleware
app.use(cors());
app.use(express.json());

// Simple connection test
const connectDB = async () => {
  try {
    const mongoUri = process.env.MONGODB_URI || 'mongodb://localhost:27017/digiboard';
    console.log('Attempting to connect to MongoDB Atlas...');
    
    await mongoose.connect(mongoUri, {
      serverSelectionTimeoutMS: 5000,
    });
    console.log('✅ MongoDB connected successfully');
    return true;
  } catch (error) {
    console.error('❌ MongoDB connection error:', error.message);
    return false;
  }
};

// Simple health check
app.get('/health', (req, res) => {
  const dbState = mongoose.connection.readyState;
  const dbStatus = dbState === 1 ? 'connected' : 'disconnected';
  
  res.json({ 
    status: 'Server is running',
    database: dbStatus,
    timestamp: new Date().toISOString()
  });
});

// Import models
const Lecture = require('./backend/models/Lecture');
const Subject = require('./backend/models/Subject');

// Test lectures endpoint
app.get('/api/lectures', async (req, res) => {
  try {
    const lectures = await Lecture.find({})
      .populate('subject', 'name')
      .populate('teacher', 'name')
      .limit(5);
    
    res.json(lectures);
  } catch (error) {
    console.error('Lectures error:', error);
    res.status(500).json({ message: 'Error fetching lectures', error: error.message });
  }
});

// Test analytics dashboard
app.get('/api/analytics/dashboard', async (req, res) => {
  try {
    // Get today's lectures
    const todayLectures = await Lecture.find({
      startTime: {
        $gte: new Date(new Date().setHours(0, 0, 0, 0)),
        $lte: new Date(new Date().setHours(23, 59, 59, 999))
      }
    })
    .populate('subject', 'name')
    .populate('teacher', 'name')
    .limit(10);

    const response = {
      overview: {
        currentTime: new Date().toTimeString().slice(0, 5),
        currentDay: new Date().toLocaleDateString('en-US', { weekday: 'long' }),
        academicYear: '2024-25'
      },
      currentData: {
        todayLectures: todayLectures.map(lecture => ({
          id: lecture._id,
          subject: lecture.subject?.name || 'Unknown Subject',
          teacher: lecture.teacher?.name || 'Unknown Teacher',
          classroom: lecture.classroom,
          startTime: lecture.startTime.toTimeString().slice(0, 5),
          endTime: lecture.endTime.toTimeString().slice(0, 5),
          course: lecture.course
        }))
      }
    };

    res.json(response);
  } catch (error) {
    console.error('Dashboard error:', error);
    res.status(500).json({ message: 'Error fetching dashboard data', error: error.message });
  }
});

// Start server
const startServer = async () => {
  const connected = await connectDB();
  if (connected) {
    app.listen(PORT, '0.0.0.0', () => {
      console.log(`🚀 Server running on http://localhost:${PORT}`);
    });
  } else {
    console.log('❌ Failed to connect to database. Exiting...');
    process.exit(1);
  }
};

startServer();
