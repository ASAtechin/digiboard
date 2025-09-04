# DigiBoard Admin Dashboard - Deployment Guide

## 🚀 Hosting Options

### 1. Railway (Recommended)
Railway offers free hosting with easy deployment from GitHub.

**Steps:**
1. Push your code to GitHub
2. Visit [railway.app](https://railway.app)
3. Connect your GitHub repository
4. Select the `admin-dashboard` folder
5. Add environment variables:
   - `MONGODB_URI`: `mongodb+srv://asatechin_db_user_digi_board:QzqmoV4B8R6qnRjE@cluster0.nxz9wpg.mongodb.net/digiboard?retryWrites=true&w=majority&appName=Cluster0`
   - `NODE_ENV`: `production`
6. Deploy!

### 2. Render
Render provides free web services with automatic deployments.

**Steps:**
1. Push your code to GitHub
2. Visit [render.com](https://render.com)
3. Create a new "Web Service"
4. Connect your GitHub repository
5. Set root directory to `admin-dashboard`
6. Add environment variables:
   - `MONGODB_URI`: `mongodb+srv://asatechin_db_user_digi_board:QzqmoV4B8R6qnRjE@cluster0.nxz9wpg.mongodb.net/digiboard?retryWrites=true&w=majority&appName=Cluster0`
   - `NODE_ENV`: `production`
7. Deploy!

### 3. Vercel
Vercel is great for serverless deployments.

**Steps:**
1. Install Vercel CLI: `npm install -g vercel`
2. In the admin-dashboard directory: `vercel`
3. Follow the prompts
4. Add environment variables in Vercel dashboard:
   - `MONGODB_URI`: `mongodb+srv://asatechin_db_user_digi_board:QzqmoV4B8R6qnRjE@cluster0.nxz9wpg.mongodb.net/digiboard?retryWrites=true&w=majority&appName=Cluster0`
   - `NODE_ENV`: `production`

### 4. Heroku
Heroku offers free tier for small applications.

**Steps:**
1. Install Heroku CLI
2. Login: `heroku login`
3. Create app: `heroku create digiboard-admin-dashboard`
4. Set environment variables:
   ```bash
   heroku config:set MONGODB_URI="mongodb+srv://asatechin_db_user_digi_board:QzqmoV4B8R6qnRjE@cluster0.nxz9wpg.mongodb.net/digiboard?retryWrites=true&w=majority&appName=Cluster0"
   heroku config:set NODE_ENV=production
   ```
5. Deploy: `git push heroku main`

## 📋 Environment Variables Required

| Variable | Value | Description |
|----------|-------|-------------|
| `MONGODB_URI` | MongoDB Atlas connection string | Database connection |
| `NODE_ENV` | `production` | Environment setting |
| `PORT` | Auto-assigned by host | Server port (optional) |

## 🔐 Security

- Default admin credentials: `admin` / `admin123`
- **Important**: Change the default password after deployment
- Consider implementing stronger authentication for production use

## 🔗 After Deployment

1. Access your admin dashboard at the provided URL
2. Login with: `admin` / `admin123`
3. Start managing your DigiBoard schedules!

## 📝 Notes

- The admin dashboard connects to the same MongoDB Atlas database as your main DigiBoard application
- All changes made in the admin dashboard will immediately reflect in your classroom displays
- The dashboard is responsive and works on both desktop and mobile devices
