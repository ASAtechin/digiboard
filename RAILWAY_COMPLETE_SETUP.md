# Railway New Account - Complete Configuration Guide

## Your New Railway Setup

**Public URL**: `web-production-9eeb.up.railway.app`  
**TCP Proxy**: `metro.proxy.rlwy.net:53954` (for database/internal connections)  
**Status**: ⏳ Backend needs to be deployed

---

## Step-by-Step Railway Configuration

### STEP 1: Environment Variables in Railway Dashboard

Go to Railway → Your Backend Service → Variables tab

Add these variables:

```
NODE_ENV = production
PORT = 5000
MONGODB_URI = mongodb+srv://[username]:[password]@[cluster].mongodb.net/digiboard?retryWrites=true&w=majority
```

**For MONGODB_URI**, options:
- Option A: Use your existing MongoDB Atlas connection string
- Option B: Use TCP proxy format (if MongoDB on Railway):
  ```
  mongodb://[username]:[password]@metro.proxy.rlwy.net:53954/digiboard
  ```

### STEP 2: Connect GitHub Repository

In Railway Dashboard:
1. Go to your project
2. Click "Connect GitHub" or "Add Service"
3. Select repository: `ASAtechin/digiboard`
4. Branch: `feature/educational-management-system`
5. Root directory: `backend/` (if needed)
6. Click Deploy

### STEP 3: Wait for Deployment

- Status should progress: Building → Deploying → Running
- Check logs for: "Server is running on port 5000"

### STEP 4: Verify Deployment

Once green "Running" status appears, test:

```bash
curl https://web-production-9eeb.up.railway.app/health
```

Should return:
```json
{
  "status": "Server is running",
  "database": "connected",
  "timestamp": "2025-11-09T12:00:00.000Z"
}
```

---

## Backend Environment Variables Explained

| Variable | Value | Purpose |
|----------|-------|---------|
| `NODE_ENV` | `production` | Tells server to run in production mode |
| `PORT` | `5000` | Port the backend runs on |
| `MONGODB_URI` | `mongodb+srv://...` | Database connection string |

---

## Where TCP Proxy is Used

The TCP proxy `metro.proxy.rlwy.net:53954` is used by:
- Backend → MongoDB (internal connection)
- NOT for frontend → backend API calls

Frontend uses public URL: `https://web-production-9eeb.up.railway.app`

---

## Current Code Status

✅ **Already Updated with New URL**:
- `netlify.toml` → `API_URL = https://web-production-9eeb.up.railway.app/api`
- `backend/server.js` → CORS allows `web-production-9eeb.up.railway.app`
- `frontend/lib/services/api_service.dart` → `baseUrl = https://web-production-9eeb.up.railway.app/api`
- All deployment scripts updated

✅ **Code Pushed to GitHub**:
- Branch: `feature/educational-management-system`
- Commit: `chore: Update Railway backend URL to web-production-9eeb.up.railway.app`

---

## Expected Flow After Setup

```
1. User visits https://digiboard.netlify.app
   ↓
2. Frontend loads and calls:
   GET https://web-production-9eeb.up.railway.app/api/schedule/next
   ↓
3. Backend receives request at https://web-production-9eeb.up.railway.app
   ↓
4. Backend connects to MongoDB via metro.proxy.rlwy.net:53954
   ↓
5. Backend returns data
   ↓
6. Frontend displays schedule/teachers ✅
```

---

## Troubleshooting

### If Backend Returns 404
**Cause**: Backend service not deployed yet  
**Fix**: Deploy backend service in Railway dashboard (Step 2)

### If Backend Returns 502 Bad Gateway
**Cause**: Backend service crashed or environment variables wrong  
**Fix**: Check Railway logs for errors, verify MONGODB_URI

### If Frontend Can't Reach Backend
**Cause**: CORS issue or wrong URL in frontend  
**Fix**: 
- Verify CORS headers: `curl -X OPTIONS https://web-production-9eeb.up.railway.app/...`
- Check browser DevTools → Network tab for actual error

### If Database Connection Fails
**Cause**: MONGODB_URI incorrect or database offline  
**Fix**:
- Test MongoDB connection string locally
- Verify MongoDB Atlas cluster is running
- Check if need to use TCP proxy instead

---

## Quick Reference

| Component | URL | Status |
|-----------|-----|--------|
| Frontend | https://digiboard.netlify.app | ✅ Deployed |
| Backend | https://web-production-9eeb.up.railway.app | ⏳ Needs deploy |
| Backend API | https://web-production-9eeb.up.railway.app/api | ⏳ Needs deploy |
| Database | MongoDB Atlas or Railway | ⏳ Needs config |
| TCP Proxy | metro.proxy.rlwy.net:53954 | For internal use |

---

## What I've Done ✅

1. ✅ Updated all code files with new Railway URL
2. ✅ Configured CORS for new URL
3. ✅ Pushed changes to GitHub
4. ✅ Ready for backend deployment

## What You Need to Do ⏳

1. ⏳ Deploy backend service to new Railway account
2. ⏳ Configure environment variables (MONGODB_URI, etc)
3. ⏳ Verify backend health endpoint working
4. ⏳ Tell me when deployed and running

---

## Next: Tell Me When Backend is Deployed

Once you've completed the Railway setup:

Run this command and share the output:
```bash
curl https://web-production-9eeb.up.railway.app/health
```

Once it returns success JSON, I'll verify everything is connected and working!
