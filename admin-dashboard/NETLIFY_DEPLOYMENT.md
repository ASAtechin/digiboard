# DigiBoard Admin Dashboard - Netlify Deployment Guide

## 🚀 Deploy to Netlify

### **Method 1: Netlify CLI (Recommended)**

1. **Install Netlify CLI:**
   ```bash
   npm install -g netlify-cli
   ```

2. **Login to Netlify:**
   ```bash
   netlify login
   ```

3. **Deploy from admin-dashboard directory:**
   ```bash
   cd /home/rntbci/projects/digiboard/admin-dashboard
   netlify deploy
   ```

4. **For production deployment:**
   ```bash
   netlify deploy --prod
   ```

### **Method 2: GitHub Integration (Automatic)**

1. **Push your code to GitHub** (already done)
2. **Go to [Netlify](https://app.netlify.com)**
3. **Click "New site from Git"**
4. **Connect to GitHub and select:** `ASAtechin/digiboard`
5. **Configure build settings:**
   - **Base directory:** `admin-dashboard`
   - **Build command:** `npm install`
   - **Publish directory:** `admin-dashboard`
   - **Functions directory:** `netlify/functions`

6. **Add Environment Variables in Netlify Dashboard:**
   ```
   MONGODB_URI=mongodb+srv://asatechin_db_user_digi_board:QzqmoV4B8R6qnRjE@cluster0.nxz9wpg.mongodb.net/digiboard?retryWrites=true&w=majority&appName=Cluster0
   NODE_ENV=production
   SESSION_SECRET=your-secret-key-here
   NETLIFY=true
   ```

### **Method 3: Drag & Drop**

1. **Build the project locally:**
   ```bash
   cd admin-dashboard
   npm install
   ```

2. **Create a zip file** of the admin-dashboard folder
3. **Go to Netlify dashboard** and drag the zip file
4. **Add environment variables** in site settings

## 🔧 Configuration Details

### **netlify.toml** (Already configured)
```toml
[build]
  command = "npm install"
  functions = "netlify/functions"

[build.environment]
  NODE_ENV = "production"

[[redirects]]
  from = "/*"
  to = "/.netlify/functions/server"
  status = 200
```

### **Serverless Function** (Already created)
- Location: `netlify/functions/server.js`
- Wraps Express app for serverless deployment

## 🌐 Access Your Admin Dashboard

After deployment, you'll get a URL like:
`https://your-site-name.netlify.app`

### **Login Credentials:**
- **Username:** `admin`
- **Password:** `admin123`

## 🔐 Security Notes

1. **Change default credentials** after deployment
2. **Add custom domain** for production use
3. **Enable HTTPS** (automatic on Netlify)
4. **Set up proper authentication** for production

## 📝 Environment Variables Required

| Variable | Value | Description |
|----------|-------|-------------|
| `MONGODB_URI` | MongoDB Atlas connection string | Database connection |
| `NODE_ENV` | `production` | Environment setting |
| `SESSION_SECRET` | Random secret string | Session encryption |
| `NETLIFY` | `true` | Netlify environment flag |

## 🚀 After Deployment

1. **Test all functionality:**
   - Login page
   - Dashboard overview
   - Teachers management
   - Lectures management
   - Schedule views

2. **Configure MongoDB connection:**
   - Ensure Atlas allows connections from anywhere (0.0.0.0/0)
   - Or add Netlify's IP ranges to whitelist

3. **Monitor logs:**
   - Check Netlify Functions logs for any issues
   - Monitor database connections

## 🎉 You're Live!

Your DigiBoard Admin Dashboard will be accessible worldwide with:
- ✅ HTTPS enabled
- ✅ Global CDN
- ✅ Automatic deployments on git push
- ✅ Serverless scaling
