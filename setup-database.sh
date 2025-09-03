#!/bin/bash

# Database Setup Script for Production
# Run this AFTER successful deployment to populate the database

echo "🗄️ Setting up DigiBoard Database..."

# Check if MONGODB_URI is set
if [ -z "$MONGODB_URI" ]; then
    echo "❌ Error: MONGODB_URI environment variable not set"
    echo "Please set your MongoDB connection string in Railway environment variables"
    exit 1
fi

echo "📡 Testing database connection..."
node -e "
const mongoose = require('mongoose');
mongoose.connect(process.env.MONGODB_URI)
  .then(() => {
    console.log('✅ Database connection successful');
    process.exit(0);
  })
  .catch(err => {
    console.error('❌ Database connection failed:', err.message);
    process.exit(1);
  });
"

if [ $? -eq 0 ]; then
    echo "🌱 Seeding database with sample data..."
    npm run seed
    echo "✅ Database setup complete!"
else
    echo "❌ Database setup failed. Check your MONGODB_URI."
    exit 1
fi
