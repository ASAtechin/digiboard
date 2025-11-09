# Complete Railway Account Migration - Full Setup Instructions

## Current Status
❌ **OLD Railway URL**: `web-production-58f13.up.railway.app` - **DEAD** (returning 404)  
⏳ **NEW Railway Account**: Needs configuration

---

## Files That Need to be Updated with NEW URL

Total: **8 files** need the new Railway URL

### 1. **netlify.toml** (Frontend build environment)
```
Current: API_URL = "https://web-production-58f13.up.railway.app/api"
Update to: API_URL = "https://[NEW_URL]/api"
```

### 2. **backend/server.js** (CORS configuration)
```javascript
// Line ~79: Add new Railway URL to CORS origins
const corsOptions = {
  origin: [
    'https://[NEW_URL]',  // ← ADD THIS LINE
    'https://digiboard.netlify.app',
    ...
  ]
}
```

### 3. **frontend/lib/services/api_service.dart** (Frontend API client)
```dart
Current: static const String baseUrl = 'https://web-production-58f13.up.railway.app/api';
Update to: static const String baseUrl = 'https://[NEW_URL]/api';
```

### 4. **build-netlify.sh** (Netlify build script)
```bash
Current: flutter build web --release --dart-define=API_URL=https://web-production-58f13.up.railway.app/api
Update to: --dart-define=API_URL=https://[NEW_URL]/api
```

### 5. **deploy-production-enhanced.sh** (Production deployment script)
```bash
Current: --dart-define=API_URL=https://web-production-58f13.up.railway.app/api
Update to: --dart-define=API_URL=https://[NEW_URL]/api
```

### 6. **deploy-production.sh** (Main deployment script)
```bash
Current: --dart-define=API_URL=https://web-production-58f13.up.railway.app/api
Update to: --dart-define=API_URL=https://[NEW_URL]/api
```

### 7. **CORS_FIX_APPLIED.md** (Documentation)
Updates for reference only

### 8. **DEPLOYMENT_SUCCESS.md** (Documentation)
Updates for reference only

---

## What You Need to Do FIRST

### Step 1: Get Your New Railway Backend URL

**Access Your New Railway Account**:
1. Go to https://railway.app
2. Log in with your new account credentials
3. Select your DigiBoard Backend project/service

**Get the URL**:
1. Click on the Backend service
2. Go to "Settings" tab (or "Deployments")
3. Look for one of these:
   - "Railway Domain"
   - "Public URL"
   - "Service URL"
   - It will look like: `https://xxx-production-yyy.up.railway.app`

**Important**: Copy the full URL including `https://` prefix

### Step 2: Verify Environment Variables in New Railway

In Railway Dashboard → Your Backend Service → Variables:

Make sure these are configured:
```
NODE_ENV = production
PORT = 5000
MONGODB_URI = mongodb+srv://[your-mongodb-connection-string]
```

**For MONGODB_URI**, use your existing MongoDB Atlas cluster or configure new one:
- MongoDB Atlas: https://www.mongodb.com/cloud/atlas
- Create connection string in format: `mongodb+srv://username:password@cluster.mongodb.net/database?...`

### Step 3: Test Backend Health

Once backend is deployed on new Railway, run:
```bash
curl https://[NEW_URL]/health
```

Expected response:
```json
{
  "status": "Server is running",
  "database": "connected",
  "timestamp": "2025-11-09T11:30:00.000Z"
}
```

### Step 4: Provide the New URL

**Reply with**: `https://[YOUR_NEW_RAILWAY_URL]` (example: `https://digiboard-api-prod.up.railway.app`)

Once you provide this, I will:
1. Update all 8 files automatically
2. Commit changes to GitHub
3. Push to trigger deployments
4. Verify connection working

---

## Checklist

- [ ] New Railway account created and accessible
- [ ] DigiBoard Backend service deployed on new Railway
- [ ] GitHub connected to new Railway account (for auto-deploy)
- [ ] Environment variables set (NODE_ENV, MONGODB_URI, PORT)
- [ ] Backend service status shows "Running" (green checkmark)
- [ ] Backend health check returns 200 OK
- [ ] **New Railway backend URL obtained**
- [ ] **Ready to share URL with me**

---

## Why This Happened

1. **Old Account**: Railway project at `web-production-58f13.up.railway.app` was deleted/removed
2. **New Account**: New Railway account created, but URL is different
3. **Frontend/Backend Mismatch**: All code still pointed to dead URL
4. **Result**: Frontend tried to reach non-existent backend = connection failure

---

## Once You Provide the URL

Timeline for automatic fixes:

| Time | Action |
|------|--------|
| T+0s | You provide new Railway URL |
| T+1m | I update all 8 files |
| T+2m | I commit and push to GitHub |
| T+3m | GitHub notifies Railway of new code |
| T+4m | Railway starts deploying backend |
| T+5m | Netlify detects changes and rebuilds frontend |
| T+10m | Both services deployed with new URL |
| T+10m+ | App working: Frontend → Backend → MongoDB ✅ |

---

## Support

If you need help finding the Railway URL or environment variables:

### Railway Dashboard Navigation
1. Log in: https://railway.app
2. Select project "DigiBoard" or similar
3. Click on "Backend" or "Node" service
4. Look for "Settings" or "Deployments" tab
5. Find public URL/domain name

### If Backend Not Showing
- Check "Services" section - should list your backend
- Check "Deployments" - should show successful deployment
- Check "Logs" - should show no errors

### MongoDB Connection String
If needed, can be found in:
1. MongoDB Atlas: https://www.mongodb.com/cloud/atlas
2. Your cluster → "Connect" button
3. Connection string option

---

## What I'll Do Automatically

Once you provide the URL (`https://YOUR_NEW_RAILWAY_URL`), I will:

```bash
# 1. Update all files
sed -i 's/web-production-58f13.up.railway.app/YOUR_NEW_RAILWAY_URL/g' \
  netlify.toml \
  backend/server.js \
  frontend/lib/services/api_service.dart \
  build-netlify.sh \
  deploy-production-enhanced.sh \
  deploy-production.sh

# 2. Commit with clear message
git commit -m "fix: Update Railway backend URL to new account: https://YOUR_NEW_RAILWAY_URL"

# 3. Push to trigger deployments
git push origin feature/educational-management-system

# 4. Verify
curl https://YOUR_NEW_RAILWAY_URL/health
```

---

**NEXT STEP**: Reply with your new Railway backend URL and I'll update everything!
