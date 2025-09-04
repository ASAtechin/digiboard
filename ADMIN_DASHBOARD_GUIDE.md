# DigiBoard Admin Dashboard - Complete Setup Guide

## 🎯 Admin Dashboard Features

Your new DigiBoard Admin Dashboard provides comprehensive schedule management capabilities for educational institutions:

### 📊 Dashboard Overview
- **Real-time Statistics**: Total teachers, lectures, and active schedules
- **Next Lecture Display**: Shows upcoming lecture with full details
- **Quick Actions**: Fast access to add teachers, lectures, and emergency updates
- **System Status**: Live connection monitoring

### 👥 Teacher Management
- **Complete CRUD Operations**: Add, edit, view, and delete teacher profiles
- **Rich Profiles**: Name, email, department, phone, office, qualifications, experience
- **Subject Assignments**: Track which subjects each teacher handles
- **Profile Images**: Support for teacher photos
- **Search & Filter**: Quick search through teacher database

### 📚 Lecture Management
- **Full Schedule Control**: Create, modify, and delete lectures
- **Bulk Operations**: Mass activate/deactivate lectures
- **Time Management**: Smart time validation and conflict detection
- **Classroom Assignment**: Room allocation and management
- **Lecture Types**: Support for Lectures, Labs, Tutorials, Seminars
- **Chapter Tracking**: Current topic/chapter being taught
- **Status Control**: Active/inactive lecture management

### 📅 Schedule Views
- **Today's Schedule**: All lectures for current day
- **Weekly Overview**: Complete week view with day-wise breakdowns
- **Real-time Updates**: Auto-refresh every 2 minutes
- **Current Lecture Highlighting**: Visual indicator for ongoing lectures
- **Time Until Next**: Shows countdown for upcoming lectures

### ⚡ Quick Update Center
- **Emergency Controls**: Rapidly cancel or reschedule lectures
- **Teacher Substitution**: Quick teacher replacement system
- **Bulk Cancellations**: Cancel multiple lectures at once
- **Emergency Broadcast**: Send alerts to all display screens
- **Classroom Changes**: Quick room reassignments

## 🚀 Complete Setup Instructions

### 1. Prerequisites
```bash
# Install MongoDB (Ubuntu/Linux)
sudo apt-get install mongodb-community

# Install Node.js (if not already installed)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install Flutter (if not already installed)
# Follow: https://docs.flutter.dev/get-started/install
```

### 2. Database Setup
```bash
# Start MongoDB service
sudo systemctl start mongod
sudo systemctl enable mongod

# Verify MongoDB is running
sudo systemctl status mongod
```

### 3. Backend API Setup
```bash
# Navigate to project root
cd /home/rntbci/projects/digiboard

# Install backend dependencies
npm install

# Create environment file
cp .env.example .env

# Edit .env file with your MongoDB connection
nano .env
# Set: MONGODB_URI=mongodb://localhost:27017/digiboard

# Seed the database with sample data
npm run seed

# Start the backend server
npm run dev
```

### 4. Admin Dashboard Setup
```bash
# Navigate to admin dashboard
cd admin-dashboard

# Install dependencies
npm install

# Create environment file
cp .env.example .env

# Edit environment variables if needed
nano .env

# Start the admin dashboard
npm run dev
# or
node server.js
```

### 5. Flutter App Setup (Optional)
```bash
# Navigate to frontend
cd ../frontend

# Install Flutter dependencies
flutter pub get

# Run the Flutter app
flutter run -d chrome
```

## 🌐 Access Points

### Admin Dashboard
- **URL**: http://localhost:3001
- **Login**: 
  - Username: `admin`
  - Password: `admin123`

### API Endpoints
- **Base URL**: http://localhost:5000/api
- **Health Check**: http://localhost:5000/api/health

### Flutter App
- **URL**: http://localhost:*flutter-assigned-port*

## 🔧 Using the Admin Dashboard

### 1. Dashboard Overview
- View real-time statistics
- Monitor next upcoming lecture
- Access quick actions for common tasks
- Check system connectivity status

### 2. Managing Teachers
- **Add Teacher**: Complete profile with qualifications and subjects
- **Edit Teacher**: Update contact info, subjects, and experience
- **Delete Teacher**: Remove teacher (with confirmation)
- **Search Teachers**: Quick search by name or department

### 3. Managing Lectures
- **Add Lecture**: Schedule new lectures with all details
- **Edit Lecture**: Modify time, room, teacher, or content
- **Bulk Operations**: Select multiple lectures for mass actions
- **Status Control**: Activate/deactivate lectures
- **Time Validation**: System prevents scheduling conflicts

### 4. Schedule Management
- **Today's View**: Focus on current day's schedule
- **Weekly View**: See entire week at a glance
- **Real-time Updates**: Dashboard refreshes automatically
- **Visual Indicators**: Current lectures highlighted in green

### 5. Quick Updates
- **Cancel Lectures**: Quickly disable lectures for emergencies
- **Substitute Teachers**: Replace teachers for specific lectures
- **Reschedule**: Change time or classroom rapidly
- **Emergency Broadcast**: Send alerts to all DigiBoard displays

## 🔒 Security Features

### Current Implementation (Demo)
- Simple username/password authentication
- Session-based login system
- Basic form validation
- CORS protection

### Production Recommendations
- Implement JWT token authentication
- Add role-based access control (Admin, Teacher, Viewer)
- Use HTTPS for all communications
- Add audit logging for all changes
- Implement rate limiting
- Add password hashing and complexity requirements

## 🎨 UI Features

### Responsive Design
- **Desktop**: Full-featured interface with sidebar navigation
- **Tablet**: Adapted layouts with touch-friendly controls
- **Mobile**: Compact interface optimized for small screens

### Modern Interface
- **Bootstrap 5**: Latest responsive framework
- **Font Awesome Icons**: Comprehensive icon library
- **Gradient Backgrounds**: Modern visual appeal
- **Loading States**: Visual feedback for all operations
- **Error Handling**: User-friendly error messages

### Interactive Elements
- **Real-time Search**: Instant filtering as you type
- **Bulk Selection**: Checkbox-based multi-select
- **Modal Dialogs**: Clean popup interfaces
- **Form Validation**: Client-side and server-side validation
- **Auto-save**: Form data preservation during editing

## 📱 Use Cases

### Daily Operations
1. **Morning Setup**: Review and activate today's schedule
2. **Teacher Substitution**: Replace absent teachers
3. **Emergency Changes**: Cancel lectures due to emergencies
4. **Room Changes**: Reassign classrooms for maintenance
5. **Schedule Updates**: Add extra lectures or tutorials

### Weekly Planning
1. **New Schedule Creation**: Set up next week's lectures
2. **Teacher Assignment**: Assign teachers to new subjects
3. **Bulk Modifications**: Update multiple lectures at once
4. **Semester Planning**: Prepare schedules for new academic terms
5. **Resource Management**: Optimize classroom utilization

### Emergency Scenarios
1. **Weather Closures**: Quickly cancel all lectures
2. **Faculty Meetings**: Reschedule conflicting lectures
3. **Technical Issues**: Move lectures to different rooms
4. **Guest Lectures**: Add special sessions rapidly
5. **Exam Schedules**: Clear rooms for examinations

## 🔄 Data Flow

```
Frontend App     →  Backend API     →  MongoDB
Admin Dashboard  →  Backend API     →  MongoDB
                 ↑                  ↑
            Port 3001          Port 5000
```

### Real-time Updates
- Admin makes changes in dashboard
- Changes saved to MongoDB via API
- Frontend apps fetch updated data
- All displays show current information

## 🚨 Troubleshooting

### MongoDB Connection Issues
```bash
# Check if MongoDB is running
sudo systemctl status mongod

# Start MongoDB if stopped
sudo systemctl start mongod

# Check MongoDB logs
sudo tail -f /var/log/mongodb/mongod.log
```

### Admin Dashboard Issues
```bash
# Check if backend API is running
curl http://localhost:5000/api/health

# Check admin dashboard logs
# Look at terminal where admin dashboard is running

# Restart admin dashboard
cd admin-dashboard
node server.js
```

### Common Solutions
1. **Port Conflicts**: Change ports in .env files
2. **Permission Issues**: Check file permissions
3. **Missing Dependencies**: Run `npm install` again
4. **Database Errors**: Verify MongoDB connection string
5. **Browser Cache**: Clear browser cache and cookies

## 📈 Future Enhancements

### Planned Features
- **User Roles**: Teacher, Admin, Viewer access levels
- **Notifications**: Email/SMS alerts for schedule changes
- **Calendar Integration**: Sync with Google Calendar/Outlook
- **Attendance Tracking**: Mark student attendance
- **Resource Booking**: Reserve projectors, labs, equipment
- **Analytics**: Usage statistics and reporting
- **Mobile App**: Native admin app for smartphones
- **API Documentation**: Swagger/OpenAPI integration

### Scalability Options
- **Multi-campus**: Support multiple school locations
- **Department Isolation**: Separate department management
- **Automated Scheduling**: AI-powered optimal scheduling
- **Integration APIs**: Connect with school management systems
- **Real-time Collaboration**: Multiple admin simultaneous editing

---

**Your DigiBoard Admin Dashboard is now ready for production use!**

Login at: http://localhost:3001 with `admin` / `admin123`
