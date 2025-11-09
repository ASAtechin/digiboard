# Railway Account Migration - Setup Guide

## Issue
Backend connection broken because:
- ❌ Old Railway account (`web-production-58f13`) no longer exists
- ✅ New Railway account created but not configured in code
- Frontend trying to reach dead backend URL

---

## REQUIRED INFORMATION

**Please provide the following from your NEW Railway account:**

### 1. New Railway Backend URL
Go to: https://railway.app
1. Click on your project (DigiBoard Backend)
2. Click "Settings"
3. Look for "Railway Domain" or "Service URL"
4. Copy the full domain (example: `https://xxx-production-yyy.up.railway.app`)

**Provide**: `https://____-production-____.up.railway.app`

### 2. Environment Variables Configured in New Railway Account
On Railway Dashboard:
1. Go to Variables tab
2. List all configured variables (we need to verify):
   - `NODE_ENV` 
   - `PORT`
   - `MONGODB_URI`
   - Any other variables

**Provide**: List of variables with their values (hide sensitive data like passwords)

---

## What Needs to Be Updated

Once you provide the new Railway URL, I will update:

### File 1: netlify.toml (Frontend build config)
```toml
[build.environment]
  API_URL = "https://NEW_RAILWAY_URL/api"
```

### File 2: backend/server.js (Backend CORS)
```javascript
const corsOptions = {
  origin: [
    'https://NEW_RAILWAY_URL',      // ← UPDATE THIS
    'https://digiboard.netlify.app',
    ...
  ]
}
```

### File 3: frontend/lib/services/api_service.dart (Frontend API client)
```dart
static const String baseUrl = 'https://NEW_RAILWAY_URL/api';
```

### Files 4-5: Deployment scripts
- `build-netlify.sh`
- `deploy-production-enhanced.sh`

---

## Step-by-Step Configuration for New Railway Account

### Step 1: Get Your New Railway Backend URL
1. Log in to https://railway.app with new account
2. Go to your DigiBoard Backend service
3. Click "Settings" tab
4. Find and copy the Railway Domain (ends in .up.railway.app)

### Step 2: Configure Environment Variables in Railway
1. Go to "Variables" tab in Railway
2. Make sure these are set:
   ```
   NODE_ENV = production
   PORT = 5000
   MONGODB_URI = mongodb+srv://...your connection string...
   ```

### Step 3: Deploy Backend
1. In Railway, connect your GitHub repository
2. Select this branch: `feature/educational-management-system`
3. Click Deploy
4. Wait for deployment to complete

### Step 4: Verify Backend is Running
```bash
curl https://YOUR_NEW_RAILWAY_URL/health
# Should return: {"status":"Server is running","database":"connected"}
```

### Step 5: I'll Update All Configuration Files
Once you provide the new URL, I will:
- Update all 5+ files with new URL
- Push to GitHub
- Trigger Netlify rebuild
- Verify CORS working

---

## Quick Checklist for New Railway Account

- [ ] New Railway account created
- [ ] DigiBoard Backend service deployed
- [ ] GitHub repository connected to Railway
- [ ] Environment variables configured (NODE_ENV, MONGODB_URI, etc)
- [ ] Backend service running (check Railway Dashboard)
- [ ] Railway domain/URL obtained
- [ ] Ready to share the NEW Railway URL

---

## Connection Flow (How It Should Work)

```
User's Browser
    ↓
https://digiboard.netlify.app (Frontend)
    ↓
Makes API call to: https://NEW_RAILWAY_URL/api/schedule/next
    ↓
Railway Backend (New Account) at NEW_RAILWAY_URL
    ↓
Connects to MongoDB Atlas
    ↓
Returns data (teachers, schedule, etc)
    ↓
Frontend displays in app ✅
```

---

## Action Required from You

1. **Get the new Railway backend URL** from your new account
2. **Verify environment variables are set** in Railway dashboard
3. **Share the URL** so I can update all configuration files
4. **I'll handle the rest**: Update code, commit, push, and trigger deployments

**What is your NEW Railway backend URL?**

Example format: `https://xxx-production-yyy.up.railway.app`
