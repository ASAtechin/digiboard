# DigiBoard Deployment Guide

## Free Hosting Setup

### Step 1: Database Setup (MongoDB Atlas)

1. **Create MongoDB Atlas Account**
   - Go to https://www.mongodb.com/cloud/atlas/register
   - Sign up for free account

2. **Create Free Cluster**
   - Choose "Build a Database" → "M0 FREE" tier
   - Select closest region
   - Name your cluster (e.g., "digiboard-cluster")

3. **Configure Database Access**
   - Go to "Database Access" → "Add New Database User"
   - Create username/password
   - Set privileges to "Read and write to any database"

4. **Configure Network Access**
   - Go to "Network Access" → "Add IP Address"
   - Add "0.0.0.0/0" (allow access from anywhere) for hosting

5. **Get Connection String**
   - Go to "Database" → "Connect" → "Connect your application"
   - Copy the connection string
   - Replace `<password>` with your database user password
   - Replace `<dbname>` with "digiboard"

### Step 2: Backend Hosting (Railway - Recommended)

1. **Setup Railway Account**
   - Go to https://railway.app
   - Sign up with GitHub

2. **Deploy Backend**
   - Connect your GitHub repository
   - Railway will auto-detect Node.js
   - Set environment variables:
     - `MONGODB_URI`: Your Atlas connection string
     - `NODE_ENV`: production

3. **Configure Domain**
   - Railway provides a free `.railway.app` domain
   - Note this URL for frontend configuration

### Step 3: Frontend Hosting (Netlify)

1. **Build Frontend**
   ```bash
   # Set your backend URL
   export API_URL=https://your-app.railway.app/api
   
   # Build the frontend
   ./build-frontend.sh
   ```

2. **Deploy to Netlify**
   - Go to https://netlify.com
   - Sign up with GitHub
   - Drag and drop the `frontend/build/web` folder
   - Or connect GitHub for auto-deployments

### Alternative Hosting Options

#### Backend Alternatives:
- **Render**: Similar to Railway, free tier with sleep
- **Heroku**: $5/month but reliable
- **Cyclic**: Free Node.js hosting

#### Frontend Alternatives:
- **Vercel**: Excellent for Flutter web
- **Firebase Hosting**: Google's hosting platform
- **GitHub Pages**: Free static hosting

### Environment Variables Reference

**Backend (.env):**
```
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/digiboard?retryWrites=true&w=majority
NODE_ENV=production
PORT=5000
```

**Frontend Build:**
```bash
flutter build web --dart-define=API_URL=https://your-backend.railway.app/api
```

### Deployment Commands

**Local Development:**
```bash
# Start backend
npm run dev

# Start frontend (in another terminal)
cd frontend && flutter run -d chrome
```

**Production Build:**
```bash
# Backend (automatic on Railway/Render)
npm install
npm start

# Frontend
./build-frontend.sh
```

### Cost Breakdown (Free Tiers)

| Service | Free Limit | Cost After |
|---------|------------|------------|
| MongoDB Atlas | 512MB | $9/month |
| Railway | 500 hours/month | $5/month |
| Netlify | 100GB bandwidth | $19/month |
| **Total** | **Free for small projects** | **~$33/month** |

### Monitoring & Maintenance

1. **Health Checks**
   - Your backend has `/api/health` endpoint
   - Use it to monitor uptime

2. **Logs**
   - Railway/Render provide real-time logs
   - Monitor for errors and performance

3. **Updates**
   - Push to GitHub triggers auto-deployments
   - Test locally before pushing

### Next Steps

1. Set up MongoDB Atlas
2. Deploy backend to Railway
3. Build and deploy frontend to Netlify
4. Test the full application
5. Set up custom domain (optional)

Your DigiBoard will be live and accessible worldwide! 🚀
