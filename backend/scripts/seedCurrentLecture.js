const mongoose = require('mongoose');
const Teacher = require('./models/Teacher');
const Subject = require('./models/Subject');
const Lecture = require('./models/Lecture');
require('dotenv').config();

/**
 * Seed Current/Happening Now Lectures
 * Creates lectures for RIGHT NOW with current time
 */

const seedCurrentLectures = async () => {
  try {
    const mongoUri = process.env.MONGODB_URI;
    if (!mongoUri) {
      throw new Error('MONGODB_URI environment variable is not defined');
    }
    await mongoose.connect(mongoUri);
    console.log('✅ Connected to MongoDB');

    // Get current time and create lecture times
    const now = new Date();
    const currentHour = now.getHours();
    const currentMinute = now.getMinutes();

    // Create start time: 30 minutes ago
    const startTime = new Date();
    startTime.setHours(currentHour, Math.max(0, currentMinute - 30), 0, 0);

    // Create end time: 1.5 hours from now
    const endTime = new Date();
    endTime.setHours(currentHour + 1, (currentMinute + 30) % 60, 0, 0);

    console.log('⏰ Lecture Times:');
    console.log(`   Start: ${startTime.toLocaleTimeString()}`);
    console.log(`   End: ${endTime.toLocaleTimeString()}`);

    // Get or create teachers
    console.log('👨‍🏫 Setting up teachers...');
    let teachers = await Teacher.find().limit(5);

    if (teachers.length === 0) {
      console.log('   Creating new teachers...');
      teachers = await Teacher.insertMany([
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
          qualifications: ['PhD in Mathematics', 'MSc in Statistics'],
          experience: 8
        },
        {
          name: 'Dr. Emily Rodriguez',
          email: 'emily.rodriguez@university.edu',
          department: 'Physics',
          office: 'Science Hall, Room 150',
          phone: '+1-555-0103',
          profileImage: 'https://api.dicebear.com/7.x/personas/svg?seed=emily',
          qualifications: ['PhD in Physics', 'MSc in Quantum Mechanics'],
          experience: 10
        },
        {
          name: 'Prof. James Wilson',
          email: 'james.wilson@university.edu',
          department: 'Chemistry',
          office: 'Lab Building, Room 301',
          phone: '+1-555-0104',
          profileImage: 'https://api.dicebear.com/7.x/personas/svg?seed=james',
          qualifications: ['PhD in Organic Chemistry', 'MSc in Chemical Engineering'],
          experience: 14
        },
        {
          name: 'Dr. Lisa Anderson',
          email: 'lisa.anderson@university.edu',
          department: 'Biology',
          office: 'Biology Building, Room 250',
          phone: '+1-555-0105',
          profileImage: 'https://api.dicebear.com/7.x/personas/svg?seed=lisa',
          qualifications: ['PhD in Molecular Biology', 'MSc in Genetics'],
          experience: 11
        }
      ]);
      console.log(`   ✅ Created ${teachers.length} teachers`);
    } else {
      console.log(`   ✅ Found ${teachers.length} existing teachers`);
    }

    // Get or create subjects
    console.log('📚 Setting up subjects...');
    let subjects = await Subject.find().limit(10);

    if (subjects.length === 0) {
      console.log('   Creating new subjects...');
      subjects = await Subject.insertMany([
        { name: 'Web Development', code: 'CS101', description: 'Modern web technologies' },
        { name: 'Data Structures', code: 'CS102', description: 'Advanced data structures' },
        { name: 'Calculus I', code: 'MATH101', description: 'Differential calculus' },
        { name: 'Linear Algebra', code: 'MATH102', description: 'Matrix theory and applications' },
        { name: 'Physics I', code: 'PHY101', description: 'Classical mechanics' },
        { name: 'Organic Chemistry', code: 'CHEM201', description: 'Organic reactions' },
        { name: 'General Biology', code: 'BIO101', description: 'Cell and molecular biology' },
        { name: 'Database Design', code: 'CS201', description: 'Relational databases' },
        { name: 'Machine Learning', code: 'CS301', description: 'AI and ML fundamentals' },
        { name: 'Quantum Physics', code: 'PHY301', description: 'Quantum mechanics' }
      ]);
      console.log(`   ✅ Created ${subjects.length} subjects`);
    } else {
      console.log(`   ✅ Found ${subjects.length} existing subjects`);
    }

    // Delete existing lectures for today to avoid duplicates
    const today = new Date().toDateString();
    await Lecture.deleteMany({
      date: { $gte: new Date(today), $lt: new Date(new Date(today).getTime() + 24 * 60 * 60 * 1000) }
    });
    console.log('🗑️  Cleared existing today\'s lectures');

    // Create current lectures
    console.log('\n🚀 Creating CURRENT/HAPPENING NOW lectures...');
    const dayOfWeek = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'][new Date().getDay()];

    const currentLectures = [
      {
        subject: subjects[0]._id,
        teacher: teachers[0]._id,
        classroom: 'Room A101',
        startTime: startTime,
        endTime: endTime,
        dayOfWeek: dayOfWeek,
        semester: 'Fall 2024',
        course: 'CS-101',
        lectureType: 'Lecture',
        chapter: 'Chapter 5: Advanced Topics',
        description: 'Currently happening - Web Development Advanced Topics'
      },
      {
        subject: subjects[1]._id,
        teacher: teachers[1]._id,
        classroom: 'Lab B204',
        startTime: startTime,
        endTime: endTime,
        dayOfWeek: dayOfWeek,
        semester: 'Fall 2024',
        course: 'CS-102',
        lectureType: 'Lab',
        chapter: 'Chapter 3: Algorithms',
        description: 'Currently happening - Data Structures Lab'
      },
      {
        subject: subjects[4]._id,
        teacher: teachers[2]._id,
        classroom: 'Lecture Hall C301',
        startTime: startTime,
        endTime: endTime,
        dayOfWeek: dayOfWeek,
        semester: 'Fall 2024',
        course: 'PHY-101',
        lectureType: 'Lecture',
        chapter: 'Chapter 7: Dynamics',
        description: 'Currently happening - Physics I Mechanics'
      }
    ];

    const created = await Lecture.insertMany(currentLectures);
    console.log(`✅ Created ${created.length} CURRENT lectures happening RIGHT NOW!`);

    // Create upcoming lectures
    console.log('\n⏳ Creating UPCOMING lectures...');
    const upcomingStart1 = new Date(endTime.getTime() + 15 * 60 * 1000); // 15 mins after current ends
    const upcomingEnd1 = new Date(upcomingStart1.getTime() + 50 * 60 * 1000); // 50 min duration

    const upcomingStart2 = new Date(upcomingEnd1.getTime() + 15 * 60 * 1000);
    const upcomingEnd2 = new Date(upcomingStart2.getTime() + 50 * 60 * 1000);

    const upcomingLectures = [
      {
        subject: subjects[2]._id,
        teacher: teachers[1]._id,
        classroom: 'Room D205',
        startTime: upcomingStart1,
        endTime: upcomingEnd1,
        dayOfWeek: dayOfWeek,
        semester: 'Fall 2024',
        course: 'MATH-101',
        lectureType: 'Lecture',
        chapter: 'Chapter 4: Integration',
        description: 'Upcoming - Calculus I'
      },
      {
        subject: subjects[5]._id,
        teacher: teachers[3]._id,
        classroom: 'Lab E102',
        startTime: upcomingStart2,
        endTime: upcomingEnd2,
        dayOfWeek: dayOfWeek,
        semester: 'Fall 2024',
        course: 'CHEM-201',
        lectureType: 'Lab',
        chapter: 'Chapter 6: Synthesis',
        description: 'Upcoming - Organic Chemistry Lab'
      }
    ];

    const upcomingCreated = await Lecture.insertMany(upcomingLectures);
    console.log(`✅ Created ${upcomingCreated.length} UPCOMING lectures`);

    // Display summary
    console.log('\n📊 Database Summary:');
    console.log(`   ✅ ${created.length} lectures happening RIGHT NOW`);
    console.log(`   ⏳ ${upcomingCreated.length} upcoming lectures today`);
    console.log(`   👨‍🏫 ${teachers.length} teachers`);
    console.log(`   📚 ${subjects.length} subjects`);

    console.log('\n✨ Database populated successfully!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error seeding database:', error);
    process.exit(1);
  }
};

seedCurrentLectures();
