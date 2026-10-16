const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const morgan = require('morgan');
const { RateLimiterMemory } = require('rate-limiter-flexible');
const path = require('path');
require('dotenv').config();
const Settings = require('./models/Settings');

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
    // Skip rate limiting for OPTIONS requests (CORS preflight)
    if (req.method === 'OPTIONS') {
      return next();
    }

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
  origin: function (origin, callback) {
    // Allow requests with no origin (like mobile apps or curl requests)
    if (!origin) return callback(null, true);

    console.log('Request Origin:', origin); // Debugging log

    const allowedOrigins = [
      'http://localhost:3000', // Admin Panel
      'http://localhost:8081', // Frontend Web Build
      'http://localhost:5000', // Self
      'http://127.0.0.1:8081'  // Frontend Web Build (IP)
    ];

    if (allowedOrigins.indexOf(origin) !== -1 || origin.startsWith('http://localhost:')) {
      callback(null, true);
    } else {
      console.log('Blocked Origin:', origin);
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true,
  optionsSuccessStatus: 200,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
};

app.use(cors(corsOptions));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

const {
  requireWriteKey,
  stripContactFields,
  requireDatabase,
  configuredApiKey,
  MIN_KEY_LENGTH,
} = require('./middleware/security');

// Demo mode serves built-in sample data. It must be switched on explicitly and is
// refused in production, so a database failure never shows invented schedules.
const DEMO_MODE = process.env.DEMO_MODE === 'true';
if (DEMO_MODE && NODE_ENV === 'production') {
  console.error('❌ DEMO_MODE cannot be enabled in production. Refusing to start.');
  process.exit(1);
}
if (!configuredApiKey()) {
  console.warn(`⚠️ ADMIN_API_KEY is not set (minimum ${MIN_KEY_LENGTH} characters): all API writes are disabled.`);
}

// MongoDB connection. There is no fallback: until connected, data routes return 503.
const connectDB = async () => {
  const mongoUri = process.env.MONGODB_URI;
  if (!mongoUri) {
    throw new Error('Missing MONGODB_URI');
  }

  console.log('🔌 Connecting to MongoDB...');
  await mongoose.connect(mongoUri, {
    serverSelectionTimeoutMS: 5000,
    maxPoolSize: 10,
    minPoolSize: 2,
    maxIdleTimeMS: 30000,
    bufferCommands: false,
    connectTimeoutMS: 5000,
    socketTimeoutMS: 45000
  });
  console.log('✅ MongoDB connected successfully');

  // Seed School Location if not exists
  try {
    const location = await Settings.findOne({ key: 'school_location' });
    if (!location) {
      await Settings.create({
        key: 'school_location',
        value: {
          latitude: 13.0827,
          longitude: 80.2707,
          address: 'Chennai, India'
        },
        description: 'School Location for Weather'
      });
      console.log('📍 Seeded default school location');
    }
  } catch (err) {
    console.error('Error seeding settings:', err);
  }
};

const RETRY_DELAY_MS = 10000;

const connectWithRetry = async () => {
  while (mongoose.connection.readyState !== 1) {
    try {
      await connectDB();
    } catch (error) {
      console.error('❌ MongoDB connection failed:', error.message);
      console.error(`Retrying in ${RETRY_DELAY_MS / 1000}s. Data routes return 503 until connected.`);
      await new Promise((resolve) => setTimeout(resolve, RETRY_DELAY_MS));
    }
  }
};

// --- Health checks (public, no data) ---

const healthHandler = (req, res) => {
  const dbStatus = mongoose.connection.readyState === 1 ? 'connected' : 'disconnected';
  res.json({ status: 'Server is running', database: dbStatus, timestamp: new Date().toISOString() });
};
app.get('/health', healthHandler);
app.get('/api/health', healthHandler);

// --- API routes ---
// Routes are registered synchronously so no request can arrive before they exist.

app.use('/api', requireWriteKey);
app.use('/api', stripContactFields);

if (DEMO_MODE) {
  console.log('⚠️  DEMO_MODE: serving built-in sample data, not school records');
  const mockData = require('./mockData');

  app.get('/api/schedule/next', (req, res) => {
    const next = mockData.getNextLecture();
    res.json(next || { message: 'No upcoming lectures' });
  });
  app.get('/api/schedule/today', (req, res) => res.json(mockData.getTodayLectures()));
  app.get('/api/schedule/week', (req, res) => res.json(mockData.getWeeklySchedule()));
  app.get('/api/teachers', (req, res) => res.json(mockData.mockTeachers));
  app.get('/api/lectures', (req, res) => res.json(mockData.mockLectures));
  app.get('/api/notification', (req, res) => res.json({ active: false, alerts: [], demo: true }));
} else {
  app.use('/api', requireDatabase);
  app.use('/api/lectures', require('./routes/lectures'));
  app.use('/api/teachers', require('./routes/teachers'));
  app.use('/api/schedule', require('./routes/schedule'));
  app.use('/api/classes', require('./routes/classes'));
  app.use('/api/subjects', require('./routes/subjects'));
  app.use('/api/syllabus', require('./routes/syllabus'));
  app.use('/api/timetables', require('./routes/timetables'));
  app.use('/api/analytics', require('./routes/analytics'));
  app.use('/api/settings', require('./routes/settings'));
  app.use('/api/notification', require('./routes/notification'));

  // Reseeding wipes teachers, subjects and lectures. Development only, and still
  // behind the admin API key like every other write.
  if (NODE_ENV !== 'production') {
    app.post('/api/seed', async (req, res, next) => {
      try {
        const { seedDatabase } = require('./scripts/seedReal');
        await seedDatabase();
        res.json({ message: 'Database seeded successfully', timestamp: new Date().toISOString() });
      } catch (error) {
        next(error);
      }
    });
  }
}

// Serve analytics dashboard
app.get('/analytics', (req, res) => {
  res.sendFile(path.join(__dirname, '..', 'analytics-dashboard.html'));
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
      notification: '/api/notification',
      dashboard: '/analytics'
    }
  });
});

// --- Error Handling (Must be LAST) ---

app.use((err, req, res, next) => {
  console.error('Error:', err);
  let error = { message: 'Internal Server Error', status: 500 };

  if (err.name === 'ValidationError') {
    error.message = Object.values(err.errors).map(e => e.message).join(', ');
    error.status = 400;
  }
  if (err.name === 'CastError') {
    error.message = `Invalid ${err.path}`;
    error.status = 400;
  }
  if (err.code === 11000) {
    error.message = 'Duplicate field value entered';
    error.status = 400;
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

if (!DEMO_MODE) {
  connectWithRetry();
}

// Start Server (only if not in test environment)
if (NODE_ENV !== 'test') {
  app.listen(PORT, () => {
    console.log(`
    ################################################
    🛡️  Server listening on port: ${PORT} 🛡️
    ------------------------------------------------
    Mode: ${DEMO_MODE ? 'DEMO (sample data)' : 'LIVE (MongoDB)'}
    Env:  ${NODE_ENV}
    ################################################
    `);
  });
}

module.exports = { app, connectDB };
