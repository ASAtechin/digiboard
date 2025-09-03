# 🚀 DigiBoard Live Deployment Guide

## Current Status: Ready to Deploy! ✅

Your repository is live at: https://github.com/ASAtechin/digiboard

---

## 🗄️ STEP 1: MongoDB Atlas Setup (FREE Database)

**MongoDB Atlas registration is open in your browser.**

### Follow these steps:

1. **Sign up** at https://www.mongodb.com/cloud/atlas/register
   - Use your GitHub account for faster setup
   - Or create new account with email

2. **Create Organization & Project**
   - Organization name: `DigiBoard`
   - Project name: `digiboard-production`

3. **Build Database**
   - Click "Build a Database"
   - Choose **"M0 Sandbox"** (FREE tier)
   - Provider: AWS (recommended)
   - Region: Choose closest to you
   - Cluster name: `digiboard-cluster`
   - Click "Create"

4. **Database User Setup**
   - Username: `digiboard-admin`
   - Password: Generate secure password (save it!)
   - Database User Privileges: "Read and write to any database"

5. **Network Access**
   - Add IP Address: `0.0.0.0/0` (Allow access from anywhere)
   - Comment: "Railway deployment access"

6. **Get Connection String**
   - Click "Connect" → "Connect your application"
   - Driver: Node.js
   - Copy the connection string
   - It looks like: `mongodb+srv://digiboard-admin:<password>@digiboard-cluster.xxxxx.mongodb.net/?retryWrites=true&w=majority`

---

## 🚂 STEP 2: Railway Backend Deployment

**After MongoDB setup, continue here:**

1. **Railway Setup**
   - Go to: https://railway.app
   - Sign up with GitHub account
   - Authorize Railway to access your repositories

2. **Deploy Project**
   - Click "New Project"
   - Select "Deploy from GitHub repo"
   - Choose: `ASAtechin/digiboard`
   - Railway automatically detects Node.js!

3. **Environment Variables**
   - In Railway dashboard, go to your project
   - Click "Variables" tab
   - Add these variables:
     ```
     MONGODB_URI=your_connection_string_from_step1
     NODE_ENV=production
     PORT=5000
     ```

4. **Deploy & Get URL**
   - Railway automatically deploys
   - Get your backend URL (like: `https://digiboard-production-xxxx.up.railway.app`)
   - Save this URL for frontend setup

---

## 🌐 STEP 3: Frontend Deployment (Netlify)

**After backend is live:**

1. **Build Flutter Web**
   ```bash
   cd frontend
   flutter pub get
   export API_URL=https://your-railway-url.up.railway.app/api
   flutter build web --dart-define=API_URL=$API_URL
   ```

2. **Deploy to Netlify**
   - Go to: https://netlify.com
   - Sign up with GitHub
   - Drag & drop the `frontend/build/web` folder
   - Your app will be live instantly!

---

## 🎉 Final Result

After all steps:
- **Database**: MongoDB Atlas (Free)
- **Backend**: Railway (Free)
- **Frontend**: Netlify (Free)
- **Total Cost**: $0.00/month

Your DigiBoard will be live and accessible worldwide!

---

## 📞 Need Help?

If you encounter any issues:
1. Check the deployment logs in Railway
2. Verify environment variables
3. Test API endpoints manually
4. Check this guide: [DEPLOYMENT.md](DEPLOYMENT.md)

Let's start with MongoDB Atlas! 🚀
