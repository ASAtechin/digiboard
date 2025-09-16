const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const morgan = require('morgan');
const { RateLimiterMemory } = require('rate-limiter-flexible');
const path = require('path');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 5000;
const NODE_ENV = process.env.NODE_ENV || 'development';

// Rate limiting
const rateLimiter = new RateLimiterMemory({
  keyGenerator: (req) => req.ip,
  points: NODE_ENV === 'production' ? 100 : 1000, // Number of requests
  duration: 60, // Per 60 seconds
});

const rateLimiterMiddleware = async (req, res, next) => {
  try {
    await rateLimiter.consume(req.ip);
    next();
  } catch (rejRes) {
    res.status(429).json({
      error: 'Too Many Requests',
      message: 'Rate limit exceeded. Please try again later.',
      retryAfter: Math.round(rejRes.msBeforeNext / 1000)
    });
  }
};

// Security middleware
app.use(helmet({
  contentSecurityPolicy: NODE_ENV === 'production' ? {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", "data:", "https:"],
    },
  } : false
}));

// Compression for better performance
app.use(compression());

// Logging
if (NODE_ENV === 'production') {
  app.use(morgan('combined'));
} else {
  app.use(morgan('dev'));
}

// Rate limiting for production
if (NODE_ENV === 'production') {
  app.use(rateLimiterMiddleware);
}

// Debug environment variables in production
if (NODE_ENV === 'production') {
  console.log('=== Production Environment Check ===');
  console.log('NODE_ENV:', NODE_ENV);
  console.log('PORT:', PORT);
  console.log('MONGODB_URI exists:', !!process.env.MONGODB_URI);
  if (process.env.MONGODB_URI) {
    // Log just the host part for debugging (not credentials)
    const uriParts = process.env.MONGODB_URI.split('@');
    if (uriParts.length > 1) {
      console.log('MongoDB host:', uriParts[1].split('/')[0]);
    }
  }
  console.log('===================================');
}

// CORS configuration for production
const corsOptions = {
  origin: [
    'https://web-production-1e39.up.railway.app',
    'https://digiboard.netlify.app',
    'https://digiboard-app.netlify.app',
    'http://localhost:8080',
    'http://localhost:3000',
    'file://',
    process.env.FRONTEND_URL
  ].filter(Boolean),
  credentials: true,
  optionsSuccessStatus: 200
};

app.use(cors(corsOptions));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// MongoDB connection with production optimizations
const connectDB = async () => {
  try {
    const mongoUri = process.env.MONGODB_URI || 'mongodb+srv://digiboard:digiboard123@cluster0.nxz9wpg.mongodb.net/digiboard?retryWrites=true&w=majority';
    
    // Log the connection attempt (without exposing credentials)
    if (NODE_ENV === 'production') {
      console.log('Connecting to MongoDB Atlas...');
    } else {
      console.log('Connecting to MongoDB Atlas (development)...');
    }
    
    const options = {
      serverSelectionTimeoutMS: 10000, // Timeout after 10s instead of 30s
      maxPoolSize: NODE_ENV === 'production' ? 10 : 5, // Connection pool size
      minPoolSize: NODE_ENV === 'production' ? 2 : 1,
      maxIdleTimeMS: 30000, // Close connections after 30 seconds of inactivity
      bufferCommands: false // Disable mongoose buffering
    };
    
    await mongoose.connect(mongoUri, options);
    console.log('MongoDB connected successfully');
    
    // Handle connection events
    mongoose.connection.on('error', (err) => {
      console.error('MongoDB connection error:', err);
    });
    
    mongoose.connection.on('disconnected', () => {
      console.warn('MongoDB disconnected');
    });
    
    // Graceful shutdown
    process.on('SIGINT', async () => {
      await mongoose.connection.close();
      console.log('MongoDB connection closed through app termination');
      process.exit(0);
    });
    
  } catch (error) {
    console.error('MongoDB connection error:', error.message);
    // Don't exit in production, let health checks handle it
    if (NODE_ENV !== 'production') {
      process.exit(1);
    } else {
      console.log('Continuing without database connection in production...');
      // Don't retry automatically in production - let health checks handle it
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
    version: '1.0.0',
    environment: NODE_ENV,
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

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Error:', err);
  
  // Default error
  let error = {
    message: 'Internal Server Error',
    status: 500
  };
  
  // Mongoose validation error
  if (err.name === 'ValidationError') {
    error.message = Object.values(err.errors).map(e => e.message).join(', ');
    error.status = 400;
  }
  
  // Mongoose duplicate key error
  if (err.code === 11000) {
    error.message = 'Duplicate field value entered';
    error.status = 400;
  }
  
  // JWT errors
  if (err.name === 'JsonWebTokenError') {
    error.message = 'Invalid token';
    error.status = 401;
  }
  
  if (err.name === 'TokenExpiredError') {
    error.message = 'Token expired';
    error.status = 401;
  }
  
  res.status(error.status).json({
    success: false,
    error: error.message,
    ...(NODE_ENV === 'development' && { stack: err.stack })
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    message: `Route ${req.originalUrl} not found`
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
