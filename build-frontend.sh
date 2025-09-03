#!/bin/bash

# Build Flutter web for production
echo "Building DigiBoard Frontend for production..."

cd frontend

# Install dependencies
flutter pub get

# Build for web with production API URL
if [ -z "$API_URL" ]; then
    echo "Warning: API_URL not set, using localhost"
    flutter build web --release
else
    echo "Building with API_URL: $API_URL"
    flutter build web --release --dart-define=API_URL=$API_URL
fi

echo "Frontend build complete!"
echo "Built files are in frontend/build/web/"
