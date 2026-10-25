#!/bin/bash

# Restart Backend Only
echo "Restarting Backend..."
pkill -f "npm run dev" 2>/dev/null || true
sleep 2
cd /home/rntbci/projects/digiboard/backend
npm run dev > /tmp/digiboard_backend.log 2>&1 &
echo "Backend restarted (PID: $!)"
sleep 5
curl -s http://localhost:5000/api/schedule/today > /dev/null && echo "✓ Backend API responding"
