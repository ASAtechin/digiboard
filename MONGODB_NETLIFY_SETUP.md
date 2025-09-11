# MongoDB Environment Variables for Different Hosting Platforms

## For Railway (Backend Hosting)

Set these environment variables in Railway dashboard:

```
MONGODB_URI=mongodb+srv://asatechin_db_user_digi_board:QzqmoV4B8R6qnRjE@cluster0.nxz9wpg.mongodb.net/digiboard?retryWrites=true&w=majority&appName=Cluster0
NODE_ENV=production
PORT=5000
```

## For Netlify (Frontend + Functions)

### Option 1: Static Site Only (Current Setup)
Netlify serves the Flutter web build. The backend runs separately on Railway/Render.

Frontend build command (with backend URL):
```bash
flutter build web --dart-define=API_URL=https://your-backend.railway.app/api
```

### Option 2: With Netlify Functions (Future Enhancement)
If you want to add serverless functions to Netlify:

Environment Variables in Netlify dashboard:
```
MONGODB_URI=mongodb+srv://asatechin_db_user_digi_board:QzqmoV4B8R6qnRjE@cluster0.nxz9wpg.mongodb.net/digiboard?retryWrites=true&w=majority&appName=Cluster0
NODE_ENV=production
```

## For Heroku (Alternative Backend)

Set these environment variables in Heroku dashboard or CLI:

```bash
heroku config:set MONGODB_URI="mongodb+srv://asatechin_db_user_digi_board:QzqmoV4B8R6qnRjE@cluster0.nxz9wpg.mongodb.net/digiboard?retryWrites=true&w=majority&appName=Cluster0"
heroku config:set NODE_ENV=production
```

## For Vercel (Alternative Deployment)

Environment Variables in Vercel dashboard:
```
MONGODB_URI=mongodb+srv://asatechin_db_user_digi_board:QzqmoV4B8R6qnRjE@cluster0.nxz9wpg.mongodb.net/digiboard?retryWrites=true&w=majority&appName=Cluster0
NODE_ENV=production
```

## For Render (Alternative Backend)

Environment Variables in Render dashboard:
```
MONGODB_URI=mongodb+srv://asatechin_db_user_digi_board:QzqmoV4B8R6qnRjE@cluster0.nxz9wpg.mongodb.net/digiboard?retryWrites=true&w=majority&appName=Cluster0
NODE_ENV=production
PORT=5000
```

## Security Notes

1. **Never commit MongoDB credentials to Git**
2. **Use environment variables in production**
3. **Rotate credentials periodically**
4. **Limit database access to specific IPs if possible**

## Current Deployment Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Netlify       │    │    Railway      │    │  MongoDB Atlas  │
│   (Frontend)    │────│   (Backend)     │────│   (Database)    │
│   Flutter Web   │    │   Node.js API   │    │   Cloud DB      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
  digiboard.netlify.app  your-app.railway.app   cluster0.mongodb.net
```

## Quick Setup Commands

1. **Deploy Backend to Railway:**
   ```bash
   git push origin feature/educational-management-system
   # Connect Railway to GitHub repo
   # Set MONGODB_URI in Railway dashboard
   ```

2. **Deploy Frontend to Netlify:**
   ```bash
   cd frontend
   flutter build web --release
   # Upload build/web folder to Netlify
   ```

3. **Test API Connection:**
   ```bash
   curl https://your-backend.railway.app/health
   ```
