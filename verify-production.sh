#!/bin/bash

# DigiBoard Production Verification Script
set -e

echo "🔍 DigiBoard Production Verification"
echo "===================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test Production Backend API
echo -e "${BLUE}📡 Testing Production Backend API...${NC}"

echo "1. Health Check:"
if curl -s "https://web-production-58f13.up.railway.app/health" | grep -q "Server is running"; then
    echo -e "${GREEN}✅ Backend health check: PASSED${NC}"
else
    echo -e "${RED}❌ Backend health check: FAILED${NC}"
    exit 1
fi

echo "2. API Health:"
if curl -s "https://web-production-58f13.up.railway.app/api/health" | grep -q "Server is running"; then
    echo -e "${GREEN}✅ API health check: PASSED${NC}"
else
    echo -e "${RED}❌ API health check: FAILED${NC}"
    exit 1
fi

echo "3. Today's Schedule:"
if curl -s "https://web-production-58f13.up.railway.app/api/schedule/today" | grep -q "classroom"; then
    echo -e "${GREEN}✅ Today's schedule endpoint: PASSED${NC}"
else
    echo -e "${RED}❌ Today's schedule endpoint: FAILED${NC}"
    exit 1
fi

echo "4. Lectures Endpoint:"
if curl -s "https://web-production-58f13.up.railway.app/api/lectures" | grep -q "subject"; then
    echo -e "${GREEN}✅ Lectures endpoint: PASSED${NC}"
else
    echo -e "${RED}❌ Lectures endpoint: FAILED${NC}"
    exit 1
fi

echo "5. Teachers Endpoint:"
if curl -s "https://web-production-58f13.up.railway.app/api/teachers" | grep -q "name"; then
    echo -e "${GREEN}✅ Teachers endpoint: PASSED${NC}"
else
    echo -e "${RED}❌ Teachers endpoint: FAILED${NC}"
    exit 1
fi

# Check Frontend Build
echo -e "${BLUE}📱 Checking Frontend Build...${NC}"

if [ -d "frontend/build/web" ] && [ -f "frontend/build/web/index.html" ]; then
    echo -e "${GREEN}✅ Frontend build exists: PASSED${NC}"
else
    echo -e "${RED}❌ Frontend build missing: FAILED${NC}"
    exit 1
fi

# Check Configuration Files
echo -e "${BLUE}⚙️  Checking Configuration Files...${NC}"

if grep -q "https://web-production-1e39.up.railway.app/api" netlify.toml; then
    echo -e "${GREEN}✅ Netlify config: PASSED${NC}"
else
    echo -e "${RED}❌ Netlify config: FAILED${NC}"
    exit 1
fi

if grep -q "production" backend/.env; then
    echo -e "${GREEN}✅ Backend environment: PASSED${NC}"
else
    echo -e "${RED}❌ Backend environment: FAILED${NC}"
    exit 1
fi

# Check for Local URLs (should not exist)
echo -e "${BLUE}🔍 Checking for Local URLs...${NC}"

LOCAL_URLS=$(grep -r "localhost\|127\.0\.0\.1" frontend/lib/ backend/server.js backend/seedDatabase.js 2>/dev/null || true)
if [ -z "$LOCAL_URLS" ]; then
    echo -e "${GREEN}✅ No local URLs found in production code: PASSED${NC}"
else
    echo -e "${YELLOW}⚠️  Local URLs found (should be reviewed):${NC}"
    echo "$LOCAL_URLS"
fi

echo ""
echo -e "${GREEN}🎉 Production Verification Complete!${NC}"
echo ""
echo -e "${BLUE}📋 Production URLs:${NC}"
echo "• Backend API: https://web-production-1e39.up.railway.app"
echo "• Frontend: https://digiboard.netlify.app (when deployed)"
echo "• Health Check: https://web-production-1e39.up.railway.app/health"
echo "• Analytics: https://web-production-1e39.up.railway.app/analytics"
echo ""
echo -e "${BLUE}📊 API Endpoints:${NC}"
echo "• Today's Schedule: https://web-production-1e39.up.railway.app/api/schedule/today"
echo "• Weekly Schedule: https://web-production-1e39.up.railway.app/api/schedule/week"
echo "• Next Lecture: https://web-production-1e39.up.railway.app/api/schedule/next"
echo "• All Lectures: https://web-production-1e39.up.railway.app/api/lectures"
echo "• All Teachers: https://web-production-1e39.up.railway.app/api/teachers"
echo ""
echo -e "${GREEN}✅ DigiBoard is ready for production deployment!${NC}"
