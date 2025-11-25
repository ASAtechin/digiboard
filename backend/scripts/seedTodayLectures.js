const mongoose = require('mongoose');
const Teacher = require('./models/Teacher');
const Subject = require('./models/Subject');
const Lecture = require('./models/Lecture');
require('dotenv').config();

/**
 * Seed Today's Lectures with Multiple States
 * 
 * Creates lectures for today with different states:
 * - ✅ COMPLETED (past lectures)
 * - 🔴 ACTIVE/HAPPENING NOW (current lecture)
 * - ⭕ NEXT (upcoming next)
 * - ⏳ UPCOMING (future lectures)
 */

const getTodayDate = () => new Date().toDateString();
const getDayOfWeek = () => {
  const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  return days[new Date().getDay()];
};

const seedTodayLectures = async () => {
  try {
    const mongoUri = process.env.MONGODB_URI || 'mongodb://localhost:27017/digiboard';
    await mongoose.connect(mongoUri);
    console.log('✅ Connected to MongoDB');

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
      console.log(`   ✅ Created ${subjects.length} subjects`);
    } else {
      console.log(`   ✅ Found ${subjects.length} existing subjects`);
    }

    // Get today's date and day
    const today = new Date();
    const dayOfWeek = getDayOfWeek();
    
    console.log(`\n📅 Creating today's lectures for ${dayOfWeek}, ${today.toDateString()}`);

    // Clear today's lectures first
    await Lecture.deleteMany({
      dayOfWeek: dayOfWeek,
      startTime: {
        $gte: new Date(today.getFullYear(), today.getMonth(), today.getDate()),
        $lt: new Date(today.getFullYear(), today.getMonth(), today.getDate() + 1)
      }
    });

    // Create today's lectures with different states
    const todayLectures = [];

    // Helper function to create time
    const createTime = (hours, minutes) => {
      const time = new Date();
      time.setHours(hours, minutes, 0, 0);
      return time;
    };

    // Get current time
    const now = new Date();
    const currentHours = now.getHours();
    const currentMinutes = now.getMinutes();

    // 1. ✅ COMPLETED LECTURE (Past - ended 1 hour ago)
    todayLectures.push({
      subject: subjects[0]._id,
      teacher: teachers[0]._id,
      classroom: 'A101',
      startTime: createTime(currentHours - 2, 0),
      endTime: createTime(currentHours - 1, 30),
      dayOfWeek: dayOfWeek,
      lectureType: 'Lecture',
      chapter: 'Introduction to Variables',
      description: 'Basic programming concepts and variable declaration',
      isActive: true,
      semester: '1st',
      course: 'CS101'
    });

    // 2. ✅ COMPLETED LECTURE (Past - ended 30 minutes ago)
    todayLectures.push({
      subject: subjects[3]._id,
      teacher: teachers[1]._id,
      classroom: 'B201',
      startTime: createTime(currentHours - 1, 30),
      endTime: createTime(currentHours - 0.5, 0),
      dayOfWeek: dayOfWeek,
      lectureType: 'Lecture',
      chapter: 'Matrix Operations',
      description: 'Understanding linear algebra matrices',
      isActive: true,
      semester: '2nd',
      course: 'MATH201'
    });

    // 3. 🔴 ACTIVE/HAPPENING NOW (Current - started 15 minutes ago, ends in 45 minutes)
    todayLectures.push({
      subject: subjects[1]._id,
      teacher: teachers[0]._id,
      classroom: 'C301',
      startTime: createTime(currentHours, currentMinutes - 15),
      endTime: createTime(currentHours + 1, currentMinutes + 45),
      dayOfWeek: dayOfWeek,
      lectureType: 'Lecture',
      chapter: 'Sorting Algorithms',
      description: 'Efficient sorting: Quick Sort and Merge Sort',
      isActive: true,
      semester: '2nd',
      course: 'CS201'
    });

    // 4. ⭕ NEXT LECTURE (Upcoming - starts in 30 minutes)
    todayLectures.push({
      subject: subjects[4]._id,
      teacher: teachers[2]._id,
      classroom: 'D102',
      startTime: createTime(currentHours + 1, currentMinutes + 30),
      endTime: createTime(currentHours + 2, currentMinutes + 30),
      dayOfWeek: dayOfWeek,
      lectureType: 'Lab',
      chapter: 'Newton\'s Laws',
      description: 'Practical experiments on motion and forces',
      isActive: true,
      semester: '1st',
      course: 'PHYS101'
    });

    // 5. ⏳ UPCOMING LECTURE (Future - starts in 2 hours)
    todayLectures.push({
      subject: subjects[6]._id,
      teacher: teachers[3]._id,
      classroom: 'E201',
      startTime: createTime(currentHours + 2, currentMinutes + 30),
      endTime: createTime(currentHours + 3, currentMinutes + 30),
      dayOfWeek: dayOfWeek,
      lectureType: 'Lecture',
      chapter: 'Ohm\'s Law',
      description: 'Understanding electrical circuits and resistance',
      isActive: true,
      semester: '2nd',
      course: 'ENG201'
    });

    // 6. ⏳ UPCOMING LECTURE (Future - starts in 3.5 hours)
    todayLectures.push({
      subject: subjects[8]._id,
      teacher: teachers[4]._id,
      classroom: 'F301',
      startTime: createTime(currentHours + 3, currentMinutes + 30),
      endTime: createTime(currentHours + 4, currentMinutes + 30),
      dayOfWeek: dayOfWeek,
      lectureType: 'Lecture',
      chapter: 'Organic Bonding',
      description: 'Covalent and ionic bonds in organic molecules',
      isActive: true,
      semester: '3rd',
      course: 'CHEM201'
    });

    // 7. ⏳ LATE EVENING LECTURE (Future - starts in 5 hours)
    todayLectures.push({
      subject: subjects[2]._id,
      teacher: teachers[1]._id,
      classroom: 'A301',
      startTime: createTime(currentHours + 5, currentMinutes),
      endTime: createTime(currentHours + 6, currentMinutes),
      dayOfWeek: dayOfWeek,
      lectureType: 'Tutorial',
      chapter: 'Calculus Derivatives',
      description: 'Understanding limits and derivatives',
      isActive: true,
      semester: '1st',
      course: 'MATH101'
    });

    // Insert all lectures
    const insertedLectures = await Lecture.insertMany(todayLectures);
    
    console.log('\n✅ Today\'s Lecture Schedule Created:');
    console.log('═════════════════════════════════════════════════════════');
    
    let lecIdx = 1;
    insertedLectures.forEach((lecture, idx) => {
      const startTime = lecture.startTime.toLocaleTimeString('en-US', {
        hour: '2-digit',
        minute: '2-digit',
        hour12: true
      });
      const endTime = lecture.endTime.toLocaleTimeString('en-US', {
        hour: '2-digit',
        minute: '2-digit',
        hour12: true
      });
      
      let status = '⏳';
      if (idx <= 1) status = '✅ COMPLETED';
      else if (idx === 2) status = '🔴 ACTIVE/HAPPENING NOW';
      else if (idx === 3) status = '⭕ NEXT LECTURE';
      else status = '⏳ UPCOMING';
      
      console.log(`\n${lecIdx}. ${status}`);
      console.log(`   Subject: ${subjects.find(s => s._id.equals(lecture.subject)).name}`);
      console.log(`   Teacher: ${teachers.find(t => t._id.equals(lecture.teacher)).name}`);
      console.log(`   Time: ${startTime} - ${endTime}`);
      console.log(`   Room: ${lecture.classroom}`);
      console.log(`   Type: ${lecture.lectureType}`);
      
      lecIdx++;
    });

    console.log('\n═════════════════════════════════════════════════════════');
    console.log(`\n✅ Successfully seeded ${insertedLectures.length} lectures for today!`);
    console.log('\n📊 Summary:');
    console.log(`   ✅ 2 Completed lectures (past)`);
    console.log(`   🔴 1 Active lecture (happening now)`);
    console.log(`   ⭕ 1 Next lecture (coming up soon)`);
    console.log(`   ⏳ 3 Upcoming lectures (later today)`);
    console.log(`\n💾 Data saved to MongoDB Atlas`);
    console.log(`🌐 Check dashboard at http://localhost:3000`);

  } catch (error) {
    console.error('❌ Error seeding database:', error);
    process.exit(1);
  } finally {
    await mongoose.connection.close();
    console.log('\n🔌 Database connection closed');
  }
};

// Run seed
seedTodayLectures();
