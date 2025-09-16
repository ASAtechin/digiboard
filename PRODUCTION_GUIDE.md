# DigiBoard Production Deployment Guide

## 🚀 Production-Ready Features

### Backend Enhancements
- ✅ **Security**: Helmet, CORS, Rate limiting
- ✅ **Performance**: Compression, Connection pooling
- ✅ **Monitoring**: Health checks, Error handling, Logging
- ✅ **Database**: MongoDB connection optimization
- ✅ **Environment**: Production/Development configurations

### Frontend Enhancements
- ✅ **Environment Detection**: Automatic API URL switching
- ✅ **Build Optimization**: Production builds with compression
- ✅ **Performance**: Static asset caching
- ✅ **Security**: Content Security Policy headers

## 📋 Prerequisites

1. **MongoDB Atlas Account** (for production database)
2. **Railway Account** (for backend hosting)
3. **Netlify Account** (for frontend hosting)
4. **Git Repository** (GitHub/GitLab)

## 🛠️ Deployment Steps

### 1. Environment Setup

#### Backend (.env file)
```bash
cd backend
cp .env.example .env
# Edit .env with your production values
```

Required variables:
- `MONGODB_URI`: Your MongoDB Atlas connection string
- `NODE_ENV=production`
- `FRONTEND_URL`: Your Netlify app URL

### 2. Backend Deployment (Railway)

1. **Connect Repository**:
   - Log into Railway
   - Create new project from GitHub repository
   - Select the DigiBoard repository

2. **Configure Environment**:
   - Add environment variables in Railway dashboard
   - Set `MONGODB_URI` to your MongoDB Atlas connection
   - Set `NODE_ENV=production`

3. **Deploy**:
   - Railway automatically deploys from your main branch
   - Health check endpoint: `/health`

4. **Seed Database**:
   ```bash
   curl -X POST https://your-railway-app.up.railway.app/api/seed
   ```

### 3. Frontend Deployment (Netlify)

1. **Connect Repository**:
   - Log into Netlify
   - Create new site from Git
   - Select the DigiBoard repository

2. **Build Settings**:
   - Build command: `./build-frontend.sh`
   - Publish directory: `frontend/build/web`
   - Environment variables:
     - `API_URL`: Your Railway backend URL

3. **Deploy**:
   - Netlify automatically builds and deploys
   - Updates on every push to main branch

### 4. Quick Deployment (Using Scripts)

```bash
# Run the production deployment script
./deploy-production.sh
```

## 🔧 Configuration Files

### Railway (railway.toml)
```toml
[build]
builder = "nixpacks"
buildCommand = "cd backend && npm install --production"

[deploy]
healthcheckPath = "/health"
healthcheckTimeout = 300
restartPolicyType = "on_failure"
startCommand = "cd backend && npm start"

[env]
NODE_ENV = "production"
PORT = "5000"
```

### Netlify (netlify.toml)
```toml
[build]
command = "./build-frontend.sh"
publish = "frontend/build/web"

[build.environment]
FLUTTER_WEB = "true"
NODE_ENV = "production"
API_URL = "https://your-railway-app.up.railway.app/api"
```

## 🏥 Health Checks

### Backend Health Endpoints
- `GET /health` - Server health status
- `GET /api/health` - API health status

### Example Health Check Response
```json
{
  "status": "Server is running",
  "database": "connected",
  "timestamp": "2025-09-16T10:30:00.000Z"
}
```

## 📊 Monitoring & Maintenance

### 1. Database Seeding
```bash
# Seed production database
curl -X POST https://your-backend-url/api/seed
```

### 2. API Testing
```bash
# Test today's schedule
curl https://your-backend-url/api/schedule/today

# Test lectures endpoint
curl https://your-backend-url/api/lectures
```

### 3. Error Monitoring
- Check Railway logs for backend errors
- Check Netlify deploy logs for frontend issues
- Monitor health check endpoints

## 🔒 Security Features

### Backend Security
- **Helmet**: Security headers
- **CORS**: Cross-origin protection
- **Rate Limiting**: API abuse prevention
- **Input Validation**: Mongoose validation
- **Error Handling**: Secure error responses

### Frontend Security
- **CSP Headers**: Content Security Policy
- **XSS Protection**: Cross-site scripting prevention
- **HTTPS Enforcement**: Secure connections only

## 🚀 Performance Optimizations

### Backend
- **Compression**: Gzip compression for responses
- **Connection Pooling**: MongoDB connection optimization
- **Caching Headers**: Static asset caching

### Frontend
- **Web Renderer**: Optimized HTML renderer
- **Asset Caching**: Long-term cache for static assets
- **Code Splitting**: Optimized bundle sizes

## 🔧 Troubleshooting

### Common Issues

1. **CORS Errors**:
   - Verify frontend URL in backend CORS config
   - Check API_URL in frontend configuration

2. **Database Connection**:
   - Verify MongoDB Atlas connection string
   - Check IP whitelist in MongoDB Atlas
   - Ensure correct database name

3. **Build Failures**:
   - Check Flutter version compatibility
   - Verify all dependencies are installed
   - Check build logs for specific errors

### Support Commands

```bash
# Check backend health
curl https://your-backend-url/health

# View Railway logs
railway logs

# Rebuild frontend
cd frontend && flutter clean && flutter build web --release
```

## 📞 Support

For issues or questions:
1. Check the troubleshooting section above
2. Review deployment logs
3. Verify environment variables
4. Test health check endpoints

## 🎉 Success Checklist

- [ ] Backend deployed and health check passing
- [ ] Frontend deployed and accessible
- [ ] Database connected and seeded
- [ ] API endpoints responding correctly
- [ ] CORS configured properly
- [ ] Environment variables set correctly
- [ ] SSL certificates active (HTTPS)
- [ ] Performance optimizations active
