#!/bin/bash

# Netlify Flutter Build Script

echo "Installing Flutter for Netlify build..."

# Download and install Flutter
cd /opt/build
wget -q https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.3-stable.tar.xz
tar xf flutter_linux_3.24.3-stable.tar.xz
export PATH="/opt/build/flutter/bin:$PATH"

# Verify Flutter installation
flutter --version
flutter doctor

# Build the web app
cd /opt/build/repo/frontend
flutter pub get
flutter build web --release --dart-define=API_URL=https://web-production-58f13.up.railway.app/api

echo "Flutter build complete!"
