const mongoose = require('mongoose');
const Teacher = require('./models/Teacher');
const Subject = require('./models/Subject');
const Lecture = require('./models/Lecture');
require('dotenv').config();

// Real educational data for DigiBoard
const seedDatabase = async () => {
  try {
    // Clear existing data
    console.log('🧹 Clearing existing data...');
    await Teacher.deleteMany({});
    await Subject.deleteMany({});
    await Lecture.deleteMany({});

    // Create Teachers
    console.log('👨‍🏫 Creating teachers...');
    const teachers = await Teacher.insertMany([
      {
        name: 'Dr. Sarah Johnson',
        email: 'sarah.johnson@university.edu',
        department: 'Computer Science',
        office: 'CS Building, Room 301',
        phone: '+1-555-0101',
        profileImage: 'https://api.dicebear.com/7.x/personas/svg?seed=sarah',
        qualifications: ['PhD in Computer Science', 'MSc in Software Engineering'],
        experience: 12
      },
      {
        name: 'Prof. Michael Chen',
        email: 'michael.chen@university.edu', 
        department: 'Mathematics',
        office: 'Math Building, Room 205',
        phone: '+1-555-0102',
        profileImage: 'https://api.dicebear.com/7.x/personas/svg?seed=michael',
        qualifications: ['PhD in Applied Mathematics', 'MSc in Statistics'],
        experience: 15
      },
      {
        name: 'Dr. Emma Rodriguez',
        email: 'emma.rodriguez@university.edu',
        department: 'Physics',
        office: 'Physics Building, Room 412', 
        phone: '+1-555-0103',
        profileImage: 'https://api.dicebear.com/7.x/personas/svg?seed=emma',
        qualifications: ['PhD in Theoretical Physics', 'MSc in Quantum Mechanics'],
        experience: 8
      },
      {
        name: 'Prof. David Williams',
        email: 'david.williams@university.edu',
        department: 'Engineering', 
        office: 'Engineering Building, Room 108',
        phone: '+1-555-0104',
        profileImage: 'https://api.dicebear.com/7.x/personas/svg?seed=david',
        qualifications: ['PhD in Electrical Engineering', 'MSc in Systems Engineering'],
        experience: 20
      },
      {
        name: 'Dr. Lisa Thompson',
        email: 'lisa.thompson@university.edu',
        department: 'Chemistry',
        office: 'Chemistry Building, Room 220',
        phone: '+1-555-0105', 
        profileImage: 'https://api.dicebear.com/7.x/personas/svg?seed=lisa',
        qualifications: ['PhD in Organic Chemistry', 'MSc in Chemical Engineering'],
        experience: 10
      }
    ]);

    console.log(`✅ Created ${teachers.length} teachers`);

    // Create Subjects
    console.log('📚 Creating subjects...');
    const subjects = await Subject.insertMany([
      { name: 'Introduction to Programming', code: 'CS101', credits: 3 },
      { name: 'Data Structures & Algorithms', code: 'CS201', credits: 4 },
      { name: 'Calculus I', code: 'MATH101', credits: 4 },
      { name: 'Linear Algebra', code: 'MATH201', credits: 3 },
      { name: 'General Physics I', code: 'PHYS101', credits: 4 },
      { name: 'Quantum Mechanics', code: 'PHYS301', credits: 3 },
      { name: 'Circuit Analysis', code: 'ENG201', credits: 3 },
      { name: 'Digital Systems', code: 'ENG301', credits: 4 },
      { name: 'Organic Chemistry I', code: 'CHEM201', credits: 4 },
      { name: 'Physical Chemistry', code: 'CHEM301', credits: 3 }
    ]);

    console.log(`✅ Created ${subjects.length} subjects`);

    // Create comprehensive weekly schedule
    console.log('📅 Creating weekly lecture schedule...');
    
    const lectures = [];
    
    // Monday Schedule
    lectures.push(
      {
        subject: subjects.find(s => s.code === 'CS101')._id,
        teacher: teachers.find(t => t.name === 'Dr. Sarah Johnson')._id,
        dayOfWeek: 'Monday',
        startTime: new Date(`1970-01-01T09:00:00Z`),
        endTime: new Date(`1970-01-01T10:30:00Z`),
        classroom: 'A101',
        course: 'CS101',
        semester: 'Fall 2025',
        isActive: true
      },
      {
        subject: subjects.find(s => s.code === 'MATH101')._id,
        teacher: teachers.find(t => t.name === 'Prof. Michael Chen')._id,
        dayOfWeek: 'Monday',
        startTime: new Date(`1970-01-01T11:00:00Z`),
        endTime: new Date(`1970-01-01T12:30:00Z`),
        classroom: 'B201',
        course: 'MATH101',
        semester: 'Fall 2025',
        isActive: true
      }
    );

    // Tuesday Schedule (Current day - November 18, 2025)
    lectures.push(
      {
        subject: subjects.find(s => s.code === 'PHYS101')._id,
        teacher: teachers.find(t => t.name === 'Dr. Emma Rodriguez')._id,
        dayOfWeek: 'Tuesday',
        startTime: new Date(`1970-01-01T09:00:00Z`),
        endTime: new Date(`1970-01-01T10:30:00Z`),
        classroom: 'C301',
        course: 'PHYS101',
        semester: 'Fall 2025',
        isActive: true
      },
      {
        subject: subjects.find(s => s.code === 'ENG201')._id,
        teacher: teachers.find(t => t.name === 'Prof. David Williams')._id,
        dayOfWeek: 'Tuesday',
        startTime: new Date(`1970-01-01T14:00:00Z`),
        endTime: new Date(`1970-01-01T15:30:00Z`),
        classroom: 'Lab1',
        course: 'ENG201',
        semester: 'Fall 2025',
        isActive: true
      }
    );

    // Wednesday Schedule
    lectures.push(
      {
        subject: subjects.find(s => s.code === 'CHEM201')._id,
        teacher: teachers.find(t => t.name === 'Dr. Lisa Thompson')._id,
        dayOfWeek: 'Wednesday',
        startTime: new Date(`1970-01-01T09:00:00Z`),
        endTime: new Date(`1970-01-01T10:30:00Z`),
        classroom: 'Lab2',
        course: 'CHEM201',
        semester: 'Fall 2025',
        isActive: true
      },
      {
        subject: subjects.find(s => s.code === 'CS201')._id,
        teacher: teachers.find(t => t.name === 'Dr. Sarah Johnson')._id,
        dayOfWeek: 'Wednesday',
        startTime: new Date(`1970-01-01T11:00:00Z`),
        endTime: new Date(`1970-01-01T12:30:00Z`),
        classroom: 'A102',
        course: 'CS201',
        semester: 'Fall 2025',
        isActive: true
      }
    );

    // Thursday Schedule
    lectures.push(
      {
        subject: subjects.find(s => s.code === 'MATH201')._id,
        teacher: teachers.find(t => t.name === 'Prof. Michael Chen')._id,
        dayOfWeek: 'Thursday',
        startTime: new Date(`1970-01-01T09:00:00Z`),
        endTime: new Date(`1970-01-01T10:30:00Z`),
        classroom: 'B202',
        course: 'MATH201',
        semester: 'Fall 2025',
        isActive: true
      },
      {
        subject: subjects.find(s => s.code === 'PHYS301')._id,
        teacher: teachers.find(t => t.name === 'Dr. Emma Rodriguez')._id,
        dayOfWeek: 'Thursday',
        startTime: new Date(`1970-01-01T14:00:00Z`),
        endTime: new Date(`1970-01-01T15:30:00Z`),
        classroom: 'C302',
        course: 'PHYS301',
        semester: 'Fall 2025',
        isActive: true
      }
    );

    // Friday Schedule
    lectures.push(
      {
        subject: subjects.find(s => s.code === 'ENG301')._id,
        teacher: teachers.find(t => t.name === 'Prof. David Williams')._id,
        dayOfWeek: 'Friday',
        startTime: new Date(`1970-01-01T11:00:00Z`),
        endTime: new Date(`1970-01-01T12:30:00Z`),
        classroom: 'Lab1',
        course: 'ENG301',
        semester: 'Fall 2025',
        isActive: true
      },
      {
        subject: subjects.find(s => s.code === 'CHEM301')._id,
        teacher: teachers.find(t => t.name === 'Dr. Lisa Thompson')._id,
        dayOfWeek: 'Friday',
        startTime: new Date(`1970-01-01T16:00:00Z`),
        endTime: new Date(`1970-01-01T17:30:00Z`),
        classroom: 'Lab2',
        course: 'CHEM301',
        semester: 'Fall 2025',
        isActive: true
      }
    );

    // Insert all lectures
    await Lecture.insertMany(lectures);
    console.log(`✅ Created ${lectures.length} lectures across the week`);

    // Summary
    const teacherCount = await Teacher.countDocuments();
    const subjectCount = await Subject.countDocuments();
    const lectureCount = await Lecture.countDocuments();

    console.log('\n🎉 Database seeded successfully!');
    console.log(`📊 Summary:`);
    console.log(`   👨‍🏫 Teachers: ${teacherCount}`);
    console.log(`   📚 Subjects: ${subjectCount}`);
    console.log(`   📅 Lectures: ${lectureCount}`);
    console.log('');

    // Show today's schedule (Tuesday - November 18, 2025)
    const today = new Date().toLocaleDateString('en-US', { weekday: 'long' });
    const todayLectures = await Lecture.find({ dayOfWeek: today })
      .populate('subject', 'name code')
      .populate('teacher', 'name department');
      
    console.log(`📅 Today (${today}) Schedule:`);
    if (todayLectures.length > 0) {
      todayLectures.forEach(lecture => {
        const startTime = lecture.startTime.toLocaleTimeString('en-US', { 
          hour: '2-digit', 
          minute: '2-digit',
          timeZone: 'UTC'
        });
        console.log(`   ${startTime} - ${lecture.subject?.name || 'Unknown'} (${lecture.teacher?.name || 'TBA'}) - Room ${lecture.classroom}`);
      });
    } else {
      console.log('   No lectures scheduled for today');
    }

    return {
      teachers: teacherCount,
      subjects: subjectCount, 
      lectures: lectureCount
    };

  } catch (error) {
    console.error('❌ Error seeding database:', error);
    throw error;
  }
};

// Connect and seed if running directly
if (require.main === module) {
  const connectAndSeed = async () => {
    try {
      // Try MongoDB Atlas first
      const mongoUri = process.env.MONGODB_URI || 'mongodb+srv://asatechin_db_user_digi_board:QzqmoV4B8R6qnRjE@cluster0.nxz9wpg.mongodb.net/digiboard?retryWrites=true&w=majority&appName=Cluster0';
      
      console.log('🔌 Connecting to MongoDB for seeding...');
      try {
        await mongoose.connect(mongoUri);
        console.log('✅ Connected to MongoDB Atlas');
      } catch (atlasError) {
        console.log('⚠️ Atlas failed, trying local MongoDB...');
        await mongoose.connect('mongodb://admin:admin123@localhost:27017/digiboard?authSource=admin');
        console.log('✅ Connected to local MongoDB');
      }
      
      await seedDatabase();
      await mongoose.connection.close();
      console.log('🔌 Database connection closed');
      process.exit(0);
    } catch (error) {
      console.error('❌ Seeding failed:', error);
      process.exit(1);
    }
  };
  
  connectAndSeed();
}

module.exports = { seedDatabase };