# 🔗 Essential Steps to Connect Frontend with Railway Backend

**Date**: November 9, 2025  
**Status**: ✅ Ready for Implementation  
**Target**: Production Deployment

---

## 🎯 Quick Overview

The frontend-backend connection requires these **5 essential steps**:

1. ✅ Update API service configuration
2. ✅ Inject API URL during build
3. ✅ Configure CORS on backend
4. ✅ Verify MongoDB connection
5. ✅ Deploy and test

---

## 📋 Step-by-Step Guide

### Step 1: Update Frontend API Service Configuration

**File**: `frontend/lib/services/api_service.dart`

```dart
class ApiService {
  // ✅ Use new Railway backend URL
  static const String baseUrl = 'https://web-production-58f13.up.railway.app/api';
  
  // All API methods will use this base URL
  static Future<Lecture?> getNextLecture() async {
    final response = await http.get(
      Uri.parse('$baseUrl/schedule/next'),
      headers: {'Content-Type': 'application/json'},
    );
    // ... rest of implementation
  }
}
```

**Key Point**: This URL tells the Flutter app where to find the backend API.

**Current Value**: `https://web-production-58f13.up.railway.app/api`

---

### Step 2: Inject API URL During Build

**File**: `deploy-production.sh` or use enhanced version

```bash
# Build Flutter web with API URL injection
flutter build web \
  --release \
  --web-renderer html \
  --dart-define=API_URL=https://web-production-58f13.up.railway.app/api
```

**Why This Matters**: 
- Ensures API URL is compiled into the app
- Allows dynamic configuration without code changes
- Prevents hardcoded URLs from being outdated

**How to Use**:
```bash
./deploy-production-enhanced.sh
```

---

### Step 3: Configure CORS on Backend

**File**: `backend/server.js`

```javascript
const corsOptions = {
  origin: [
    'https://web-production-58f13.up.railway.app',      // Backend (for internal)
    'https://digiboard.netlify.app',                    // Frontend URL
    'https://digiboard-app.netlify.app',               // Alt frontend URL
    'http://localhost:8080',                            // Local development
    'http://localhost:3000',                            // Local development
    'file://',                                          // Flutter desktop/mobile
    process.env.FRONTEND_URL                           // Environment variable
  ].filter(Boolean),
  credentials: true,
  optionsSuccessStatus: 200
};

app.use(cors(corsOptions));
```

**What CORS Does**: Allows frontend to make requests to backend without browser blocking.

**Verify it's set**:
- Backend allows requests from frontend URL ✅
- `credentials: true` enables authentication ✅
- All development/production URLs are listed ✅

---

### Step 4: Verify MongoDB Connection

**File**: `backend/.env` (on Railway)

```bash
# Railway Environment Variables
NODE_ENV=production
PORT=5000
MONGODB_URI=mongodb+srv://username:password@cluster0.nxz9wpg.mongodb.net/digiboard?retryWrites=true&w=majority&appName=Cluster0
FRONTEND_URL=https://digiboard.netlify.app
```

**Test MongoDB Connection**:
```bash
# Check backend health
curl https://web-production-58f13.up.railway.app/health

# Expected response
{
  "status": "Server is running",
  "database": "connected",
  "timestamp": "2025-11-09T..."
}
```

---

### Step 5: Deploy and Test

#### 5a. Deploy Backend to Railway

```bash
# Push code to GitHub
git push origin feature/educational-management-system

# Railway automatically deploys from Git
# Check status at Railway Dashboard
```

**Verify**:
```bash
curl https://web-production-58f13.up.railway.app/health
```

#### 5b. Deploy Frontend to Netlify

```bash
# Netlify auto-builds and deploys on push
# Check build logs in Netlify dashboard
```

**Verify**:
```bash
# Open in browser
https://digiboard.netlify.app

# Should display lecture schedule ✅
```

#### 5c. Test API Connection

```bash
# Test API endpoints from frontend
curl https://web-production-58f13.up.railway.app/api/teachers
curl https://web-production-58f13.up.railway.app/api/schedule/today
curl https://web-production-58f13.up.railway.app/api/schedule/next
```

**Expected**: Returns data from MongoDB ✅

---

## 🔄 Complete Connection Flow

```
┌─────────────────────────────────────────────────────────┐
│ USER OPENS: https://digiboard.netlify.app              │
└────────────────┬────────────────────────────────────────┘
                 │
                 ↓
┌─────────────────────────────────────────────────────────┐
│ Frontend (Flutter Web) loads                            │
│ API_URL = https://web-production-58f13.up.railway.app/api│
└────────────────┬────────────────────────────────────────┘
                 │
                 ↓
┌─────────────────────────────────────────────────────────┐
│ ApiService.getTodaySchedule()                           │
│ → GET /api/schedule/today                              │
└────────────────┬────────────────────────────────────────┘
                 │
                 ↓ (HTTP Request over internet)
                 │
┌─────────────────────────────────────────────────────────┐
│ Railway Backend receives request                        │
│ https://web-production-58f13.up.railway.app            │
└────────────────┬────────────────────────────────────────┘
                 │
                 ↓
┌─────────────────────────────────────────────────────────┐
│ CORS Check: Request from digiboard.netlify.app ✅      │
│ (Allowed in corsOptions)                               │
└────────────────┬────────────────────────────────────────┘
                 │
                 ↓
┌─────────────────────────────────────────────────────────┐
│ Query MongoDB:                                          │
│ - Connect to MongoDB Atlas                             │
│ - Find lectures for today                              │
└────────────────┬────────────────────────────────────────┘
                 │
                 ↓
┌─────────────────────────────────────────────────────────┐
│ Return JSON response:                                   │
│ [{                                                      │
│   "subject": "Mathematics",                             │
│   "teacher": "Dr. Smith",                               │
│   "startTime": "09:00",                                 │
│   "endTime": "10:00"                                    │
│ }]                                                      │
└────────────────┬────────────────────────────────────────┘
                 │
                 ↓ (HTTP Response)
                 │
┌─────────────────────────────────────────────────────────┐
│ Frontend receives and displays:                         │
│ "Today's Lectures"                                      │
│ - Math: 09:00-10:00 (Dr. Smith)                         │
│ - Physics: 11:00-12:00 (Dr. Jones)                      │
└─────────────────────────────────────────────────────────┘
```

---

## ✅ Connection Checklist

Use this checklist to verify everything is connected:

```
FRONTEND CONFIGURATION:
  ☐ api_service.dart has correct base URL
  ☐ ApiService.baseUrl = 'https://web-production-58f13.up.railway.app/api'
  ☐ All API methods use ApiService.baseUrl

BACKEND CONFIGURATION:
  ☐ CORS allows 'https://digiboard.netlify.app'
  ☐ CORS allows 'http://localhost:3000' (for local dev)
  ☐ CORS allows 'file://' (for Flutter mobile)

BUILD PROCESS:
  ☐ Flutter build includes --dart-define=API_URL=...
  ☐ API URL injected at compile time
  ☐ No hardcoded old URLs in build output

ENVIRONMENT:
  ☐ Railway backend URL: web-production-58f13.up.railway.app
  ☐ MongoDB connected via MONGODB_URI
  ☐ Database has test data (lectures, teachers)

DEPLOYMENT:
  ☐ Backend deployed to Railway
  ☐ Frontend deployed to Netlify
  ☐ Both using new URLs

VERIFICATION:
  ☐ curl backend health check returns 200
  ☐ curl API endpoint returns data
  ☐ Frontend app loads in browser
  ☐ Lecture schedule displays correctly
  ☐ No console errors in browser dev tools
```

---

## 🧪 Testing Commands

### Test 1: Backend Health
```bash
curl https://web-production-58f13.up.railway.app/health
```
✅ Should return: `{"status":"Server is running","database":"connected"}`

### Test 2: API Endpoint
```bash
curl https://web-production-58f13.up.railway.app/api/teachers
```
✅ Should return: `[{"name":"...","email":"..."}]`

### Test 3: CORS Check
```bash
curl -H "Origin: https://digiboard.netlify.app" \
  https://web-production-58f13.up.railway.app/api/teachers \
  -v 2>&1 | grep -i "access-control"
```
✅ Should show: `Access-Control-Allow-Origin: https://digiboard.netlify.app`

### Test 4: Local Development
```bash
# Edit frontend/lib/services/api_service.dart
# Change baseUrl to: 'http://localhost:5000/api'

# Run backend
cd backend && npm run dev

# Run frontend
cd frontend && flutter run -d chrome

# Should display data from local backend ✅
```

---

## 🚀 Deployment Procedure

### For Production:

```bash
# Step 1: Build with deployment script
./deploy-production-enhanced.sh

# Step 2: Commit changes
git add .
git commit -m "feat: production build with new Railway URL"

# Step 3: Push to GitHub
git push origin feature/educational-management-system

# Step 4: Wait for auto-deployment
# - Railway deploys backend automatically
# - Netlify builds and deploys frontend automatically

# Step 5: Verify
curl https://web-production-58f13.up.railway.app/health
open https://digiboard.netlify.app
```

---

## 📊 Configuration Matrix

| Component | Local Dev | Production |
|-----------|-----------|------------|
| Frontend URL | `http://localhost:3000` | `https://digiboard.netlify.app` |
| Backend URL | `http://localhost:5000` | `https://web-production-58f13.up.railway.app` |
| API Base | `http://localhost:5000/api` | `https://web-production-58f13.up.railway.app/api` |
| Database | Local/Atlas | MongoDB Atlas |
| Build Command | `flutter run -d chrome` | `./deploy-production-enhanced.sh` |
| CORS Origin | `localhost:3000`, `file://` | `digiboard.netlify.app`, `file://` |

---

## 🔐 Security Checklist

- ✅ API credentials in Railway environment variables (not in code)
- ✅ CORS restricts to specific frontend domains
- ✅ MongoDB connection uses HTTPS/TLS
- ✅ Frontend communicates with backend over HTTPS
- ✅ Rate limiting enabled on backend
- ✅ Helmet security headers enabled

---

## 📞 Troubleshooting

### Issue: "Cannot reach backend"
**Solution**:
1. Check API URL in `api_service.dart`
2. Verify Railway backend is running
3. Check CORS configuration
4. Test with curl: `curl https://web-production-58f13.up.railway.app/health`

### Issue: "CORS error"
**Solution**:
1. Check CORS allowed origins in `server.js`
2. Add frontend URL: `'https://digiboard.netlify.app'`
3. Redeploy backend

### Issue: "No data displaying"
**Solution**:
1. Check MongoDB is connected: `curl .../health`
2. Verify database has data: Check MongoDB Atlas
3. Check API endpoint: `curl .../api/teachers`
4. Check browser console for errors

### Issue: "404 Not Found"
**Solution**:
1. Verify API URL is correct
2. Check endpoint exists on backend
3. Verify request path is correct

---

## 📚 Related Documentation

- **Quick Start**: `QUICK_START_CONNECTION.md`
- **Troubleshooting**: `FRONTEND_BACKEND_CONNECTION.md`
- **Deployment**: `deploy-production-enhanced.sh`
- **Analysis**: `DEPLOYMENT_SCRIPT_ANALYSIS.md`

---

## ✨ Summary

**5 Essential Steps**:
1. ✅ Update API service with correct URL
2. ✅ Inject API URL during build
3. ✅ Configure CORS on backend
4. ✅ Verify MongoDB connection
5. ✅ Deploy and test

**Current Status**: ✅ All configured and ready

**Next Action**: Deploy using `./deploy-production-enhanced.sh`

