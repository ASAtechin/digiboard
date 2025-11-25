#!/bin/bash

# DigiBoard - Complete Startup Script
# Launches Backend (Node.js), Frontend (Flutter Web), and opens Dashboard

set -e

PROJECT_ROOT="/home/rntbci/projects/digiboard"
BACKEND_DIR="$PROJECT_ROOT"
FRONTEND_DIR="$PROJECT_ROOT/frontend"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  DigiBoard - System Launcher${NC}"
echo -e "${BLUE}========================================${NC}"

# Kill any existing processes
echo -e "${YELLOW}Cleaning up existing processes...${NC}"
pkill -f "npm run dev" 2>/dev/null || true
pkill -f "flutter run" 2>/dev/null || true
pkill -9 chrome 2>/dev/null || true
sleep 2

# Start Backend
echo -e "${YELLOW}[1/3] Starting Backend Server (Port 5000)...${NC}"
cd "$BACKEND_DIR/backend"
npm run dev > /tmp/digiboard_backend.log 2>&1 &
BACKEND_PID=$!
echo -e "${GREEN}✓ Backend started (PID: $BACKEND_PID)${NC}"
sleep 5

# Verify Backend
if curl -s http://localhost:5000/api/schedule/today > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Backend API responding${NC}"
else
    echo -e "${YELLOW}⚠ Backend still starting, waiting...${NC}"
    sleep 5
fi

# Start Frontend
echo -e "${YELLOW}[2/3] Starting Frontend (Flutter Web)...${NC}"
cd "$FRONTEND_DIR"
flutter run -d chrome > /tmp/digiboard_frontend.log 2>&1 &
FRONTEND_PID=$!
echo -e "${GREEN}✓ Frontend started (PID: $FRONTEND_PID)${NC}"
sleep 15

# Find Chrome port
CHROME_PORT=$(netstat -tuln 2>/dev/null | grep "127.0.0.1" | awk '{print $4}' | grep -oP ':\K[0-9]+' | sort -n | tail -1)
if [ -z "$CHROME_PORT" ]; then
    CHROME_PORT="40051"
fi

echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✓ DigiBoard System Started Successfully${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${BLUE}Services Running:${NC}"
echo -e "  ${GREEN}Backend API${NC}   : http://localhost:5000"
echo -e "  ${GREEN}Frontend UI${NC}   : http://localhost:$CHROME_PORT"
echo ""
echo -e "${BLUE}Logs:${NC}"
echo -e "  Backend   : tail -f /tmp/digiboard_backend.log"
echo -e "  Frontend  : tail -f /tmp/digiboard_frontend.log"
echo ""
echo -e "${YELLOW}To stop all services, run:${NC}"
echo -e "  pkill -f 'npm run dev'; pkill -f 'flutter run'; pkill -9 chrome"
echo ""
echo -e "${BLUE}========================================${NC}"

# Open Dashboard in browser
echo -e "${YELLOW}[3/3] Opening Dashboard...${NC}"
sleep 2
xdg-open "http://localhost:$CHROME_PORT" 2>/dev/null || open "http://localhost:$CHROME_PORT" 2>/dev/null || echo "Please open http://localhost:$CHROME_PORT in your browser"

# Keep script running
echo -e "${GREEN}System is running. Press Ctrl+C to stop.${NC}"
wait
