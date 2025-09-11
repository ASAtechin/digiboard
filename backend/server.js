const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const path = require('path');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 5000;

// Debug environment variables in production
if (process.env.NODE_ENV === 'production') {
  console.log('Environment check:');
  console.log('NODE_ENV:', process.env.NODE_ENV);
  console.log('PORT:', PORT);
  console.log('MONGODB_URI exists:', !!process.env.MONGODB_URI);
  if (process.env.MONGODB_URI) {
    // Log just the host part for debugging (not credentials)
    const uriParts = process.env.MONGODB_URI.split('@');
    if (uriParts.length > 1) {
      console.log('MongoDB host:', uriParts[1].split('/')[0]);
    }
  }
}

// Middleware
app.use(cors());
app.use(express.json());

// MongoDB connection
const connectDB = async () => {
  try {
    const mongoUri = process.env.MONGODB_URI || 'mongodb://localhost:27017/digiboard';
    
    // Log the connection attempt (without exposing credentials)
    if (process.env.NODE_ENV === 'production') {
      console.log('Connecting to MongoDB Atlas...');
    } else {
      console.log('Connecting to local MongoDB...');
    }
    
    await mongoose.connect(mongoUri, {
      serverSelectionTimeoutMS: 10000, // Timeout after 10s instead of 30s
    });
    console.log('MongoDB connected successfully');
  } catch (error) {
    console.error('MongoDB connection error:', error.message);
    // Don't exit in production, let health checks handle it
    if (process.env.NODE_ENV !== 'production') {
      process.exit(1);
    } else {
      console.log('Continuing without database connection in production...');
    }
  }
};

// Routes
app.use('/api/lectures', require('./routes/lectures'));
app.use('/api/teachers', require('./routes/teachers'));
app.use('/api/schedule', require('./routes/schedule'));
app.use('/api/classes', require('./routes/classes'));
app.use('/api/subjects', require('./routes/subjects'));
app.use('/api/syllabus', require('./routes/syllabus'));
app.use('/api/timetables', require('./routes/timetables'));
app.use('/api/analytics', require('./routes/analytics'));

// Seed endpoint for populating database
app.post('/api/seed', async (req, res) => {
  try {
    // Import seed function
    const { seedDatabase } = require('./seedDatabase');
    await seedDatabase();
    res.json({ 
      message: 'Database seeded successfully',
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('Seeding error:', error);
    res.status(500).json({ 
      message: 'Error seeding database', 
      error: error.message,
      timestamp: new Date().toISOString()
    });
  }
});

// Serve analytics dashboard
app.get('/analytics', (req, res) => {
  res.sendFile(path.join(__dirname, '..', 'analytics-dashboard.html'));
});

// Health check
app.get('/health', async (req, res) => {
  try {
    // Check if database is connected
    const dbState = mongoose.connection.readyState;
    const dbStatus = dbState === 1 ? 'connected' : 'disconnected';
    
    res.json({ 
      status: 'Server is running',
      database: dbStatus,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({ 
      status: 'Error',
      error: error.message,
      timestamp: new Date().toISOString()
    });
  }
});

app.get('/api/health', async (req, res) => {
  try {
    const dbState = mongoose.connection.readyState;
    const dbStatus = dbState === 1 ? 'connected' : 'disconnected';
    
    res.json({ 
      status: 'Server is running',
      database: dbStatus,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({ 
      status: 'Error',
      error: error.message,
      timestamp: new Date().toISOString()
    });
  }
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({ 
    message: 'DigiBoard API Server', 
    status: 'running',
    timestamp: new Date().toISOString(),
    endpoints: {
      health: '/health',
      api: '/api/health',
      lectures: '/api/lectures',
      teachers: '/api/teachers',
      schedule: '/api/schedule',
      classes: '/api/classes',
      subjects: '/api/subjects',
      syllabus: '/api/syllabus',
      timetables: '/api/timetables',
      analytics: '/api/analytics',
      dashboard: '/analytics',
      seed: '/api/seed (POST)'
    }
  });
});

// Start server
const startServer = async () => {
  await connectDB();
  app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server running on port ${PORT}`);
  });
};

startServer();
