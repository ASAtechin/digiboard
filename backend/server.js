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

// Swagger Documentation
const swaggerUi = require('swagger-ui-express');
const swaggerSpecs = require('./swagger');
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpecs));

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

// CORS configuration - LOCAL DEVELOPMENT ONLY
const corsOptions = {
  origin: '*', // Allow all origins for development
  credentials: true,
  optionsSuccessStatus: 200,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
};

app.use(cors(corsOptions));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Mock Data Import
const mockData = require('./mockData');
let isOffline = false;

// MongoDB connection - WITH FALLBACK
const connectDB = async () => {
  try {
    const mongoUri = process.env.MONGODB_URI;

    if (!mongoUri) {
      console.warn('⚠️ MONGODB_URI environment variable is not defined');
      throw new Error('Missing MONGODB_URI');
    }

    console.log('🔌 Connecting to MongoDB...');

    const options = {
      serverSelectionTimeoutMS: 5000, // 5 second timeout for faster fallback
      maxPoolSize: 10,
      minPoolSize: 2,
      maxIdleTimeMS: 30000,
      bufferCommands: false,
      connectTimeoutMS: 5000,
      socketTimeoutMS: 45000
    };

    await mongoose.connect(mongoUri, options);
    console.log('✅ MongoDB connected successfully');

    // Check if database needs seeding
    const collections = await mongoose.connection.db.listCollections().toArray();
    const hasData = collections.some(col => col.name === 'teachers' || col.name === 'lectures');

    if (!hasData) {
      console.log('📊 Database appears empty, will need seeding...');
    }

  } catch (error) {
    console.error('❌ MongoDB connection failed!');
    console.error('Error:', error.message);
    console.log('⚠️ SWITCHING TO OFFLINE MODE (Mock Data)');
    isOffline = true;
  }
};

// Initialize DB connection
connectDB().then(() => {
  // Routes Configuration
  if (isOffline) {
    console.log('⚠️  Using Offline Routes (Mock Data)');
    
    // Offline Routes
    app.get('/api/schedule/next', (req, res) => {
      const next = mockData.getNextLecture();
      res.json(next || { message: 'No upcoming lectures' });
    });

    app.get('/api/schedule/today', (req, res) => {
      res.json(mockData.getTodayLectures());
    });

    app.get('/api/schedule/week', (req, res) => {
      res.json(mockData.getWeeklySchedule());
    });

    app.get('/api/teachers', (req, res) => {
      res.json(mockData.mockTeachers);
    });

    app.get('/api/lectures', (req, res) => {
      res.json(mockData.mockLectures);
    });
    
    // Basic placeholders for other routes to prevent 404s
    app.get('/api/classes', (req, res) => res.json([]));
    app.get('/api/subjects', (req, res) => res.json([]));
    app.get('/api/syllabus', (req, res) => res.json([]));
    app.get('/api/timetables', (req, res) => res.json([]));
    app.get('/api/analytics', (req, res) => res.json({}));

  } else {
    console.log('✅ Using Online Routes (MongoDB)');
    app.use('/api/lectures', require('./routes/lectures'));
    app.use('/api/teachers', require('./routes/teachers'));
    app.use('/api/schedule', require('./routes/schedule'));
    app.use('/api/classes', require('./routes/classes'));
    app.use('/api/subjects', require('./routes/subjects'));
    app.use('/api/syllabus', require('./routes/syllabus'));
    app.use('/api/timetables', require('./routes/timetables'));
    app.use('/api/analytics', require('./routes/analytics'));
  }

  // --- Global Routes (Must be after API routes but before Error Handlers) ---

  // Seed endpoint for populating database
  app.post('/api/seed', async (req, res) => {
    try {
      const { seedDatabase } = require('./seedReal');
      await seedDatabase();
      res.json({ message: 'Database seeded successfully', timestamp: new Date().toISOString() });
    } catch (error) {
      console.error('Seeding error:', error);
      res.status(500).json({ message: 'Error seeding database', error: error.message });
    }
  });

  // Serve analytics dashboard
  app.get('/analytics', (req, res) => {
    res.sendFile(path.join(__dirname, '..', 'analytics-dashboard.html'));
  });

  // Health check
  app.get('/health', async (req, res) => {
    try {
      const dbState = mongoose.connection.readyState;
      const dbStatus = dbState === 1 ? 'connected' : 'disconnected';
      res.json({ status: 'Server is running', database: dbStatus, timestamp: new Date().toISOString() });
    } catch (error) {
      res.status(500).json({ status: 'Error', error: error.message });
    }
  });

  app.get('/api/health', async (req, res) => {
    try {
      const dbState = mongoose.connection.readyState;
      const dbStatus = dbState === 1 ? 'connected' : 'disconnected';
      res.json({ status: 'Server is running', database: dbStatus, timestamp: new Date().toISOString() });
    } catch (error) {
      res.status(500).json({ status: 'Error', error: error.message });
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

  // --- Error Handling (Must be LAST) ---

  // Error handling middleware
  app.use((err, req, res, next) => {
    console.error('Error:', err);
    let error = { message: 'Internal Server Error', status: 500 };

    if (err.name === 'ValidationError') {
      error.message = Object.values(err.errors).map(e => e.message).join(', ');
      error.status = 400;
    }
    if (err.code === 11000) {
      error.message = 'Duplicate field value entered';
      error.status = 400;
    }
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

  // Start Server
  app.listen(PORT, () => {
    console.log(`
    ################################################
    🛡️  Server listening on port: ${PORT} 🛡️
    ------------------------------------------------
    Mode: ${isOffline ? 'OFFLINE (Mock Data)' : 'ONLINE (MongoDB)'}
    Env:  ${NODE_ENV}
    ################################################
    `);
  });
});


module.exports = { app, connectDB };

