# Frontend-Backend Connection Guide

## 🔴 Issues Fixed

### Issue 1: Frontend API URL Mismatch
**Problem**: Frontend was pointing to old Railway URL (`web-production-1e39`)
**Solution**: Updated to new Railway URL (`web-production-58f13`)
**File**: `frontend/lib/services/api_service.dart`

### Issue 2: MongoDB Connection
**Problem**: MongoDB was using SRV protocol with potential connection issues
**Solution**: Updated to TCP proxy connection through Railway
**Files**: 
- `backend/.env`
- `backend/server.js`
- `backend/seedDatabase.js`

---

## 🚀 How to Run Frontend Locally

### Option 1: Connect to Production Backend
```bash
cd frontend

# Build and run with production API
flutter run -d chrome --dart-define=API_URL=https://web-production-58f13.up.railway.app/api

# Or for web
flutter build web --dart-define=API_URL=https://web-production-58f13.up.railway.app/api
```

### Option 2: Connect to Local Backend (Recommended for Development)

**Step 1: Update API Service for local development**

Edit `frontend/lib/services/api_service.dart`:

```dart
class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';
  // Use localhost for development
}
```

**Step 2: Start the backend**

```bash
cd backend
npm run dev
# Backend will run on http://localhost:5000
```

**Step 3: Start the frontend**

```bash
cd frontend
flutter run -d chrome  # For web
# or
flutter run -d all    # For all platforms
```

---

## 🧪 Testing the Connection

### Test 1: Backend Health Check
```bash
# Local backend
curl http://localhost:5000/health

# Production backend
curl https://web-production-58f13.up.railway.app/health
```

Expected response:
```json
{
  "status": "Server is running",
  "database": "connected",
  "timestamp": "2025-11-08T..."
}
```

### Test 2: Get Next Lecture
```bash
# Local
curl http://localhost:5000/api/schedule/next

# Production
curl https://web-production-58f13.up.railway.app/api/schedule/next
```

### Test 3: Get Today's Schedule
```bash
# Local
curl http://localhost:5000/api/schedule/today

# Production
curl https://web-production-58f13.up.railway.app/api/schedule/today
```

### Test 4: Get Teachers
```bash
# Local
curl http://localhost:5000/api/teachers

# Production
curl https://web-production-58f13.up.railway.app/api/teachers
```

---

## 📋 Current Configuration

### Backend URLs
| Environment | URL | Status |
|------------|-----|--------|
| Local | `http://localhost:5000` | ✅ Running |
| Production | `https://web-production-58f13.up.railway.app` | ✅ Active |

### Frontend API Service
| Setting | Value |
|---------|-------|
| **Production URL** | `https://web-production-58f13.up.railway.app/api` |
| **File** | `frontend/lib/services/api_service.dart` |
| **Base URL Variable** | `ApiService.baseUrl` |

### Database Connection
| Setting | Value |
|---------|-------|
| **Connection Type** | TCP Proxy |
| **Host** | `shinkansen.proxy.rlwy.net` |
| **Port** | `48422` |
| **Database** | `digiboard` |
| **Auth Source** | `admin` |

---

## 🔧 Troubleshooting

### Problem: "Network error" or "Failed to load" in Flutter

**Solution 1: Check backend is running**
```bash
curl http://localhost:5000/health
```

**Solution 2: Check API URL in ApiService**
- Edit `frontend/lib/services/api_service.dart`
- Verify `baseUrl` is correct for your environment

**Solution 3: Check CORS settings**
- The backend allows requests from:
  - `http://localhost:3000`
  - `http://localhost:8080`
  - `file://` (Flutter desktop/mobile)
  - `https://web-production-58f13.up.railway.app`

**Solution 4: Check Flutter debug logs**
```bash
flutter run -d chrome --verbose
```

### Problem: "Connection refused" to Railway

**Solution:**
1. Verify Railway backend is deployed: `https://web-production-58f13.up.railway.app/health`
2. Check if environment variables are set in Railway dashboard
3. Ensure MongoDB connection string is correct

### Problem: MongoDB connection issues

**Solution:**
1. Check MongoDB connection in Railway logs
2. Verify proxy credentials: `shinkansen.proxy.rlwy.net:48422`
3. Ensure `authSource=admin` is in connection string

---

## 📱 Development Workflow

### Local Development (Recommended)
```bash
# Terminal 1: Start Backend
cd backend
npm run dev

# Terminal 2: Start Frontend
cd frontend
flutter run -d chrome
```

Then edit `frontend/lib/services/api_service.dart` to use `http://localhost:5000/api`

### Production Testing
- Frontend: Push to GitHub → Auto-deploys to Netlify
- Backend: Already deployed to Railway
- Use production URLs in `api_service.dart`

---

## 📚 API Endpoints Reference

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/health` | GET | Backend health check |
| `/api/health` | GET | API health check |
| `/api/schedule/next` | GET | Get next upcoming lecture |
| `/api/schedule/today` | GET | Get today's lectures |
| `/api/schedule/week` | GET | Get week's schedule |
| `/api/lectures` | GET/POST | Lectures CRUD |
| `/api/teachers` | GET/POST | Teachers CRUD |
| `/api/classes` | GET/POST | Classes CRUD |
| `/api/subjects` | GET/POST | Subjects CRUD |
| `/api/seed` | POST | Populate database |

---

## ✅ Connection Checklist

- [ ] Backend is running (local or Railway)
- [ ] Frontend API URL is correct in `api_service.dart`
- [ ] CORS is configured in backend
- [ ] MongoDB is connected (check logs)
- [ ] Flutter debug console shows no network errors
- [ ] API endpoints are returning data

