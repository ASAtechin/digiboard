# DigiBoard - Digital Lecture Schedule Board

A modern, full-stack application that displays upcoming lecture schedules, teacher information, and class details. Built with Flutter for the frontend and Node.js/Express/MongoDB for the backend.

## 🚀 Live Demo

- **Frontend**: [Coming Soon - Deploy on Netlify]
- **Backend API**: [Coming Soon - Deploy on Railway]

## ✨ Features

- **📅 Next Lecture Display**: Shows the upcoming lecture with detailed information
- **👨‍🏫 Teacher Profiles**: Complete teacher information including contact details, qualifications, and subjects
- **📋 Schedule Views**: Today's schedule and full weekly calendar
- **🎨 Modern UI**: Beautiful Material Design 3 interface with responsive layout
- **⚡ Real-time Data**: Live updates from the backend API
- **🌐 Cross-platform**: Web, Android, iOS support with Flutter

## 🛠️ Tech Stack

### Backend
- **Node.js** with Express.js
- **MongoDB** with Mongoose ODM
- **CORS** enabled for cross-origin requests
- **Environment variables** for configuration

### Frontend
- **Flutter** framework (Web, Mobile, Desktop)
- **Material Design 3** theming
- **HTTP** client for API communication
- **Cached Network Images** for profile pictures
- **Provider** for state management

## 📁 Project Structure

```
digiboard/
├── backend/                 # Node.js/Express API
│   ├── models/             # MongoDB models
│   │   ├── Teacher.js      # Teacher schema
│   │   └── Lecture.js      # Lecture schema
│   ├── routes/             # API routes
│   │   ├── teachers.js     # Teacher endpoints
│   │   ├── lectures.js     # Lecture endpoints
│   │   └── schedule.js     # Schedule endpoints
│   ├── server.js           # Express server setup
│   ├── seed.js             # Database seeding script
│   └── package.json
├── frontend/                # Flutter application
│   ├── lib/
│   │   ├── models/         # Data models
│   │   ├── services/       # API services
│   │   ├── screens/        # App screens
│   │   ├── widgets/        # Reusable widgets
│   │   └── main.dart       # App entry point
│   └── pubspec.yaml
├── DEPLOYMENT.md           # Deployment guide
└── README.md
└── README.md
```

## 🚀 Quick Start

### Local Development

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/digiboard.git
   cd digiboard
   ```

2. **Backend Setup**:
   ```bash
   # Install dependencies
   npm install
   
   # Set up environment variables
   cp .env.example .env
   # Edit .env with your MongoDB connection
   
   # Seed database (optional)
   npm run seed
   
   # Start development server
   npm run dev
   ```

3. **Frontend Setup**:
   ```bash
   # Navigate to frontend
   cd frontend
   
   # Install Flutter dependencies
   flutter pub get
   
   # Run the app
   flutter run -d chrome
   ```

### Production Deployment

See [DEPLOYMENT.md](DEPLOYMENT.md) for complete deployment instructions using:
- **MongoDB Atlas** (Free database)
- **Railway** (Free backend hosting)
- **Netlify** (Free frontend hosting)

## 📚 API Documentation

### Schedule Endpoints
- `GET /api/schedule/next` - Get next upcoming lecture
- `GET /api/schedule/today` - Get today's schedule
- `GET /api/schedule/week` - Get weekly schedule

### Lectures Endpoints
- `GET /api/lectures` - Get all lectures
- `GET /api/lectures/:id` - Get specific lecture
- `POST /api/lectures` - Create new lecture
- `PUT /api/lectures/:id` - Update lecture
- `DELETE /api/lectures/:id` - Delete lecture

### Teachers Endpoints
- `GET /api/teachers` - Get all teachers
- `GET /api/teachers/:id` - Get specific teacher
- `POST /api/teachers` - Create new teacher
- `PUT /api/teachers/:id` - Update teacher
- `DELETE /api/teachers/:id` - Delete teacher

### Health Check
- `GET /api/health` - Server health status

## Database Schema

### Teacher Model
```javascript
{
  name: String (required),
  email: String (required, unique),
  department: String (required),
  phone: String,
  office: String,
  profileImage: String,
  subjects: [String],
  experience: Number,
  qualifications: [String]
}
```

### Lecture Model
```javascript
{
  subject: String (required),
  teacher: ObjectId (ref: Teacher),
  classroom: String (required),
  startTime: Date (required),
  endTime: Date (required),
  dayOfWeek: String (required),
  lectureType: String (enum: ['Lecture', 'Lab', 'Tutorial', 'Seminar']),
  chapter: String,
  description: String,
  isActive: Boolean,
  semester: String (required),
  course: String (required)
}
```

## Scripts

### Backend Scripts
- `npm start` - Start production server
- `npm run dev` - Start development server with nodemon
- `npm run seed` - Populate database with sample data

### Flutter Commands
- `flutter run` - Run the app in debug mode
- `flutter build` - Build the app for production
- `flutter test` - Run tests
- `flutter pub get` - Install dependencies

## Environment Variables

### Backend (.env)
```
MONGODB_URI=mongodb://localhost:27017/digiboard
PORT=5000
NODE_ENV=development
```

## Sample Data

The seed script creates sample teachers and lectures for testing:
- 4 teachers from different departments
- 15 lectures spread across weekdays
- Various lecture types (Lecture, Lab, Tutorial)
- Realistic schedules and classroom assignments

## Development

### Running in Development
1. Start MongoDB
2. Start backend: `npm run dev` (port 5000)
3. Start Flutter: `flutter run`

### Adding New Features
1. Backend: Add routes in `/routes`, update models in `/models`
2. Frontend: Create services in `/services`, screens in `/screens`, widgets in `/widgets`
3. Update API service to handle new endpoints

## Troubleshooting

### Common Issues

1. **MongoDB Connection Error**:
   - Ensure MongoDB is running
   - Check connection string in `.env`

2. **Flutter Network Error**:
   - Verify backend is running on port 5000
   - Check API base URL in `api_service.dart`

3. **Dependencies Issues**:
   - Run `npm install` for backend
   - Run `flutter pub get` for frontend

## 🤝 Contributing

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Commit your changes**: `git commit -m 'Add amazing feature'`
4. **Push to the branch**: `git push origin feature/amazing-feature`
5. **Open a Pull Request**

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Material Design for the beautiful UI components
- MongoDB for the flexible database solution
- Railway and Netlify for free hosting solutions

## 📧 Contact

For questions or support, please open an issue in this repository.

---

**Made with ❤️ using Flutter and Node.js**
- Modern Material Design 3 interface
- Gradient cards for lectures
- Teacher profile cards with contact information
- Responsive schedule views
- Error handling and loading states

For more information or support, please check the documentation or create an issue in the repository.
