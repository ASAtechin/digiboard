#!/bin/bash

# Production build script for DigiBoard Frontend
set -e

echo "🚀 Building DigiBoard Frontend for Production..."

cd frontend

echo "📦 Installing dependencies..."
flutter pub get

echo "🧹 Cleaning previous builds..."
flutter clean
flutter pub get

# Build for web with production API URL
if [ -z "$API_URL" ]; then
    echo "⚙️  Using production API URL: https://web-production-1e39.up.railway.app/api"
    echo "🔧 Building for web with production settings..."
    flutter build web --release --dart-define=API_URL=https://web-production-1e39.up.railway.app/api
else
    echo "🔧 Building with custom API_URL: $API_URL"
    flutter build web --release --dart-define=API_URL=$API_URL
fi

echo "✅ Frontend web build complete!"
echo "📁 Built files are in frontend/build/web/"
echo ""
echo "🌐 Ready for deployment to:"
echo "   - Netlify: frontend/build/web/"
echo "   - Firebase Hosting"
echo "   - Railway Static Sites"
echo "   - Any static hosting service"
