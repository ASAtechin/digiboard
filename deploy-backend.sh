#!/bin/bash

# DigiBoard Backend Deployment Script

echo "🚀 DigiBoard Backend Deployment to Railway"
echo "=========================================="

# Check if we're in the correct directory
if [ ! -f "backend/server.js" ]; then
    echo "❌ Error: Please run this script from the digiboard root directory"
    exit 1
fi

# Check if Railway CLI is installed
if ! command -v railway &> /dev/null; then
    echo "📦 Installing Railway CLI..."
    npm install -g @railway/cli
fi

# Login to Railway (if not already logged in)
echo "🔐 Please login to Railway if prompted..."
railway login

# Deploy the backend
echo "🚀 Deploying backend to Railway..."
railway up

echo ""
echo "✅ Deployment initiated!"
echo ""
echo "📝 Next steps:"
echo "1. Check Railway dashboard for deployment status"
echo "2. Note the new deployment URL"
echo "3. Update the Flutter app with the new URL"
echo "4. Test the API endpoints"
echo ""
echo "🔗 Railway Dashboard: https://railway.app/dashboard"
