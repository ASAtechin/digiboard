# DigiBoard Admin Dashboard

## Installation & Setup

1. Install dependencies:
```bash
cd admin-dashboard
npm install
```

2. Set environment variables:
```bash
# Copy and modify environment file
cp .env.example .env
```

3. Start the admin dashboard:
```bash
npm run dev
```

## Default Login
- Username: `admin`
- Password: `admin123`

## Features
- **Dashboard**: Overview of all statistics and next lecture
- **Teachers Management**: Add, edit, delete teacher profiles
- **Lectures Management**: Complete CRUD operations for lectures
- **Schedule View**: Today's and weekly schedule overview
- **Quick Update**: Fast emergency updates and substitutions
- **Bulk Operations**: Mass activate/deactivate lectures

## Admin Dashboard URLs
- Dashboard: http://localhost:3001/dashboard
- Teachers: http://localhost:3001/teachers
- Lectures: http://localhost:3001/lectures
- Schedule: http://localhost:3001/schedule
- Quick Update: http://localhost:3001/quick-update

## API Integration
The admin dashboard connects to the main API server at `http://localhost:5000/api`

Make sure the main backend server is running before using the admin dashboard.

## Security Note
This is a demo implementation. In production:
- Use proper authentication with JWT tokens
- Implement role-based access control
- Use HTTPS for all communications
- Add proper session management
- Implement audit logging
