#!/bin/bash

# Restart Frontend Only
echo "Restarting Frontend..."
pkill -f "flutter run" 2>/dev/null || true
sleep 2
cd /home/rntbci/projects/digiboard/frontend
flutter run -d chrome > /tmp/digiboard_frontend.log 2>&1 &
echo "Frontend restarted (PID: $!)"
echo "Wait 15-20 seconds for compilation to complete..."
