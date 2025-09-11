#!/bin/bash

# DigiBoard Deployment Setup Script
# This script helps set up environment variables for different hosting platforms

echo "🚀 DigiBoard Deployment Setup"
echo "=============================="

# MongoDB Atlas Connection String
MONGODB_URI="mongodb+srv://asatechin_db_user_digi_board:QzqmoV4B8R6qnRjE@cluster0.nxz9wpg.mongodb.net/digiboard?retryWrites=true&w=majority&appName=Cluster0"

echo ""
echo "📊 MongoDB Atlas Configuration:"
echo "Database: digiboard"
echo "Cluster: cluster0.nxz9wpg.mongodb.net"
echo "User: asatechin_db_user_digi_board"
echo ""

echo "🔧 Environment Variables to Set:"
echo "================================"
echo ""

echo "For Railway (Backend Hosting):"
echo "------------------------------"
echo "MONGODB_URI=\"$MONGODB_URI\""
echo "NODE_ENV=production"
echo "PORT=5000"
echo ""

echo "For Heroku (Alternative Backend):"
echo "---------------------------------"
echo "heroku config:set MONGODB_URI=\"$MONGODB_URI\""
echo "heroku config:set NODE_ENV=production"
echo ""

echo "For Render (Alternative Backend):"
echo "---------------------------------"
echo "MONGODB_URI=\"$MONGODB_URI\""
echo "NODE_ENV=production"
echo "PORT=5000"
echo ""

echo "For Netlify (Frontend Only):"
echo "----------------------------"
echo "No MongoDB variables needed - uses external API"
echo "API_URL should point to your backend deployment"
echo ""

echo "🌐 Deployment URLs:"
echo "=================="
echo "Frontend (Netlify): https://digiboard.netlify.app"
echo "Backend (Railway): https://your-app.railway.app"
echo "Analytics Dashboard: https://your-app.railway.app/analytics"
echo ""

echo "✅ Next Steps:"
echo "=============="
echo "1. Deploy backend to Railway with MongoDB variables"
echo "2. Update API_URL in Netlify configuration"
echo "3. Deploy frontend to Netlify"
echo "4. Test the connection between frontend and backend"
echo ""

echo "🔗 Quick Deploy Commands:"
echo "========================="
echo "# Deploy to Railway:"
echo "git push origin feature/educational-management-system"
echo ""
echo "# Build for Netlify:"
echo "cd frontend && flutter build web --release"
echo ""

echo "📋 Environment Variables Summary:"
echo "================================="
echo "MONGODB_URI: Connection to MongoDB Atlas database"
echo "NODE_ENV: Should be 'production' for live deployment"
echo "PORT: Server port (usually 5000 for backend)"
echo "API_URL: Frontend's backend API endpoint"
