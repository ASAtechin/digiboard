#!/bin/bash

# Stop All Services
echo "Stopping all services..."
pkill -f "npm run dev" 2>/dev/null && echo "✓ Backend stopped" || echo "Backend not running"
pkill -f "flutter run" 2>/dev/null && echo "✓ Frontend stopped" || echo "Frontend not running"
pkill -9 chrome 2>/dev/null && echo "✓ Chrome stopped" || echo "Chrome not running"
sleep 2
echo "All services stopped"
