# DigiBoard Deployment Instructions

## 🚀 Quick Deployment Guide

### Prerequisites ✅
- [x] Git repository pushed to GitHub
- [x] Railway account connected to GitHub repository
- [x] Netlify account ready for deployment
- [x] MongoDB Atlas database configured

### Automatic Deployments

#### 1. Railway Backend (✅ ACTIVE)
- **Status**: ✅ Already deployed and running
- **URL**: https://web-production-58f13.up.railway.app
- **Health**: https://web-production-58f13.up.railway.app/health
- **Auto-Deploy**: ✅ Enabled on every Git push

#### 2. Netlify Frontend (📋 TO DEPLOY)

**Option A: Auto-Deploy from Git (Recommended)**
1. Log into Netlify Dashboard
2. Click "New site from Git"
3. Connect to GitHub repository: `ASAtechin/digiboard`
4. Branch: `feature/educational-management-system`
5. Build settings will be automatically detected from `netlify.toml`
6. Deploy!

**Option B: Manual Deploy**
```bash
# If Netlify is already configured, just push triggers deployment
git push origin feature/educational-management-system
```

### Environment Variables for Netlify
These should be set in Netlify Dashboard > Site Settings > Environment Variables:

```
FLUTTER_WEB=true
NODE_ENV=production
API_URL=https://web-production-58f13.up.railway.app/api
```

### Deployment Verification

#### Backend Verification ✅
```bash
# Health check
curl https://web-production-58f13.up.railway.app/health

# API check
curl https://web-production-58f13.up.railway.app/api/schedule/today
```

#### Frontend Verification (After Deployment)
```bash
# Check if site is live
curl -I https://your-site-name.netlify.app

# Or visit in browser
open https://your-site-name.netlify.app
```

### Post-Deployment Steps

1. **Seed Database** (if needed):
```bash
curl -X POST https://web-production-58f13.up.railway.app/api/seed
```

2. **Test All Endpoints**:
```bash
./verify-production.sh
```

3. **Monitor Health**:
- Backend: https://web-production-58f13.up.railway.app/health
- Frontend: Check Netlify deploy logs

### Troubleshooting

#### Common Issues:
1. **Build Failures**: Check Flutter version in build logs
2. **API Errors**: Verify CORS settings and environment variables
3. **Database Issues**: Check MongoDB Atlas connection string

#### Support Commands:
```bash
# Check backend logs (Railway dashboard)
# Check frontend build logs (Netlify dashboard)
# Verify production setup
./verify-production.sh
```

## 🎉 Success!
- ✅ Backend: Railway deployment active
- 📋 Frontend: Ready for Netlify deployment
- ✅ Database: MongoDB Atlas connected
- ✅ All APIs tested and working

Your DigiBoard application is ready for production use!
