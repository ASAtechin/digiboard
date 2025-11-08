# 🔗 Frontend-Backend Connection - Quick Start

## ✅ What Was Fixed

| Issue | Fix | File |
|-------|-----|------|
| Frontend using old Railway URL | Updated to `web-production-58f13` | `frontend/lib/services/api_service.dart` |
| MongoDB SRV connection issues | Changed to TCP proxy via Railway | `backend/server.js`, `backend/seedDatabase.js` |
| CORS configuration outdated | Updated with new backend URL | `backend/server.js` |

---

## 🚀 Quick Test (30 seconds)

### Step 1: Verify Backend is Running
```bash
curl http://localhost:5000/health
```

### Step 2: Check Frontend Can Reach Backend
```bash
# From another terminal
curl http://localhost:5000/api/teachers
```

### Step 3: Build & Run Frontend
```bash
cd frontend
flutter run -d chrome
```

---

## 📍 API Service Configuration

**File**: `frontend/lib/services/api_service.dart`

```dart
class ApiService {
  // Production (Railway)
  static const String baseUrl = 'https://web-production-58f13.up.railway.app/api';
  
  // OR Local Development (change this for testing locally)
  // static const String baseUrl = 'http://localhost:5000/api';
}
```

---

## 🔄 Development vs Production

### For Local Development:
```dart
// frontend/lib/services/api_service.dart
static const String baseUrl = 'http://localhost:5000/api';
```

**Then start backend:**
```bash
cd backend && npm run dev
```

### For Production:
```dart
// frontend/lib/services/api_service.dart
static const String baseUrl = 'https://web-production-58f13.up.railway.app/api';
```

**No need to start backend locally - it's on Railway**

---

## 🧪 Testing Each Endpoint

```bash
# Next lecture
curl https://web-production-58f13.up.railway.app/api/schedule/next

# Today's schedule
curl https://web-production-58f13.up.railway.app/api/schedule/today

# All teachers
curl https://web-production-58f13.up.railway.app/api/teachers

# All lectures
curl https://web-production-58f13.up.railway.app/api/lectures
```

---

## ⚠️ Common Issues & Fixes

| Issue | Fix |
|-------|-----|
| "Network error" in app | Check `baseUrl` in `api_service.dart` |
| 404 Not Found | Backend might be down - check `/health` |
| CORS error | Make sure you're using correct URL |
| "Connection refused" | Backend not running on `localhost:5000` |
| Empty data | Database might not be seeded |

---

## 📞 Get Help

1. **Check logs**: `flutter run -d chrome --verbose`
2. **Test endpoint**: `curl https://web-production-58f13.up.railway.app/health`
3. **Read full guide**: `FRONTEND_BACKEND_CONNECTION.md`

