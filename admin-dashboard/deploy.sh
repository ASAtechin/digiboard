#!/bin/bash

# DigiBoard Admin Dashboard Deployment Script

echo "🚀 DigiBoard Admin Dashboard Deployment"
echo "========================================"

# Check if we're in the admin-dashboard directory
if [ ! -f "server.js" ]; then
    echo "❌ Error: Please run this script from the admin-dashboard directory"
    exit 1
fi

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Check if .env exists
if [ ! -f ".env" ]; then
    echo "⚙️  Creating .env file..."
    cat > .env << EOF
# Admin Dashboard Environment Variables
MONGODB_URI=mongodb+srv://asatechin_db_user_digi_board:QzqmoV4B8R6qnRjE@cluster0.nxz9wpg.mongodb.net/digiboard?retryWrites=true&w=majority&appName=Cluster0
NODE_ENV=production
ADMIN_PORT=3001
EOF
    echo "✅ .env file created"
else
    echo "✅ .env file already exists"
fi

# Build the application
echo "🔨 Building application..."
npm run build

echo ""
echo "✅ Deployment setup complete!"
echo ""
echo "🌐 Hosting Options:"
echo "1. Railway: https://railway.app"
echo "2. Render: https://render.com"
echo "3. Vercel: https://vercel.com"
echo "4. Heroku: https://heroku.com"
echo ""
echo "📖 See DEPLOYMENT.md for detailed instructions"
echo ""
echo "🔐 Default Login:"
echo "   Username: admin"
echo "   Password: admin123"
echo ""
echo "🎉 Ready to deploy!"
