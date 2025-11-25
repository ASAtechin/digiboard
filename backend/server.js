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

// CORS configuration - LOCAL DEVELOPMENT ONLY
const corsOptions = {
  origin: [
    'http://localhost:8080',
    'http://localhost:3000',
    'http://localhost:3333',
    'http://127.0.0.1:8080',
    'http://127.0.0.1:3000',
    'http://127.0.0.1:3333',
    'http://127.0.0.1:5000',
    'http://localhost:5000'
  ],
  credentials: true,
  optionsSuccessStatus: 200,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
};

app.use(cors(corsOptions));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// MongoDB connection - REQUIRED, NO FALLBACK
const connectDB = async () => {
  try {
    // Try MongoDB Atlas first
    const mongoUri = process.env.MONGODB_URI || 'mongodb+srv://asatechin_db_user_digi_board:QzqmoV4B8R6qnRjE@cluster0.nxz9wpg.mongodb.net/digiboard?retryWrites=true&w=majority&appName=Cluster0';
    
    console.log('🔌 Connecting to MongoDB Atlas...');
    
    const options = {
      serverSelectionTimeoutMS: 10000, // 10 second timeout
      maxPoolSize: 10,
      minPoolSize: 2,
      maxIdleTimeMS: 30000,
      bufferCommands: false,
      connectTimeoutMS: 10000,
      socketTimeoutMS: 45000
    };
    
    await mongoose.connect(mongoUri, options);
    console.log('✅ MongoDB Atlas connected successfully');
    
    // Check if database needs seeding
    const collections = await mongoose.connection.db.listCollections().toArray();
    const hasData = collections.some(col => col.name === 'teachers' || col.name === 'lectures');
    
    if (!hasData) {
      console.log('📊 Database appears empty, will need seeding...');
    }
    
  } catch (atlasError) {
    console.log('⚠️ MongoDB Atlas connection failed:', atlasError.message);
    
    try {
      // Fallback to local MongoDB with auth
      console.log('🔌 Trying local MongoDB connection...');
      await mongoose.connect('mongodb://admin:admin123@localhost:27017/digiboard?authSource=admin', {
        serverSelectionTimeoutMS: 5000,
        bufferCommands: false
      });
      console.log('✅ Local MongoDB connected successfully');
      
      // Check if local database needs seeding
      const collections = await mongoose.connection.db.listCollections().toArray();
      if (collections.length === 0) {
        console.log('📊 Local database empty, will need seeding...');
      }
      
    } catch (localError) {
      console.error('❌ CRITICAL: Both MongoDB Atlas and Local MongoDB failed!');
      console.error('Atlas Error:', atlasError.message);
      console.error('Local Error:', localError.message);
      console.error('� Please ensure:');
      console.error('   1. MongoDB Atlas credentials are correct');
      console.error('   2. Network connection is stable');
      console.error('   3. Local MongoDB is installed and running');
      console.error('   4. Run: brew services start mongodb-community (macOS) or systemctl start mongod (Linux)');
      process.exit(1); // Exit if no database connection
    }
  }
  
  // Handle connection events
  mongoose.connection.on('error', (err) => {
    console.error('MongoDB connection error:', err);
  });
  
  mongoose.connection.on('disconnected', () => {
    console.warn('MongoDB disconnected');
  });
  
  // Graceful shutdown
  process.on('SIGINT', async () => {
    if (mongoose.connection.readyState === 1) {
      await mongoose.connection.close();
    }
    console.log('MongoDB connection closed through app termination');
    process.exit(0);
  });
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
    const { seedDatabase } = require('./seedReal');
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
