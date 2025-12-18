const mongoose = require('mongoose');
const Teacher = require('./models/Teacher');
const Subject = require('./models/Subject');
const Lecture = require('./models/Lecture');
require('dotenv').config();

/**
 * Seed Sunday's Lectures with Complete Data
 * 
 * Creates comprehensive lecture schedule for Sunday with:
 * - ✅ 10+ lectures throughout the day
 * - 🎯 All different states (completed, active, next, upcoming)
 * - 🏫 Multiple classrooms and subjects
 * - 👨‍🏫 All 5 different teachers
 * - 📚 Diverse subject matter
 * - 🎓 Multiple semesters
 * - 🎬 Various lecture types
 */

const getTodayDate = () => new Date().toDateString();

const seedSundayLectures = async () => {
  try {
    const mongoUri = process.env.MONGODB_URI;
    if (!mongoUri) {
      throw new Error('MONGODB_URI environment variable is not defined');
    }
    await mongoose.connect(mongoUri);
    console.log('✅ Connected to MongoDB');

    // Get or create teachers
    console.log('👨‍🏫 Setting up teachers...');
    let teachers = await Teacher.find().limit(5);

    if (teachers.length < 5) {
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

    if (subjects.length < 10) {
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

    // Get Sunday date
    const today = new Date();
    const daysUntilSunday = (0 - today.getDay() + 7) % 7;
    const sunday = new Date(today);
    sunday.setDate(today.getDate() + daysUntilSunday);

    const dayOfWeek = 'Sunday';

    console.log(`\n📅 Creating Sunday's lectures for ${dayOfWeek}, ${sunday.toDateString()}`);

    // Clear Sunday's old lectures
    await Lecture.deleteMany({
      dayOfWeek: dayOfWeek,
    });

    // Create Sunday's comprehensive lecture schedule
    const sundayLectures = [];

    // Helper function to create time
    const createTime = (hours, minutes) => {
      const time = new Date(sunday);
      time.setHours(hours, minutes, 0, 0);
      return time;
    };

    // === COMPLETED LECTURES (Past) ===

    // 1. ✅ COMPLETED - 08:00-09:30 (Morning - 1.5 hours ago)
    sundayLectures.push({
      subject: subjects[0]._id,
      teacher: teachers[0]._id,
      classroom: 'A101',
      startTime: createTime(8, 0),
      endTime: createTime(9, 30),
      dayOfWeek: dayOfWeek,
      lectureType: 'Lecture',
      chapter: 'Variables and Data Types',
      description: 'Understanding basic programming concepts and variable declaration',
      isActive: true,
      semester: '1st',
      course: 'CS101'
    });

    // 2. ✅ COMPLETED - 10:00-11:00 (Mid-morning)
    sundayLectures.push({
      subject: subjects[3]._id,
      teacher: teachers[1]._id,
      classroom: 'B201',
      startTime: createTime(10, 0),
      endTime: createTime(11, 0),
      dayOfWeek: dayOfWeek,
      lectureType: 'Tutorial',
      chapter: 'Matrix Operations',
      description: 'Solving linear systems using matrices',
      isActive: true,
      semester: '2nd',
      course: 'MATH201'
    });

    // 3. ✅ COMPLETED - 11:30-12:30 (Late morning)
    sundayLectures.push({
      subject: subjects[4]._id,
      teacher: teachers[2]._id,
      classroom: 'C301',
      startTime: createTime(11, 30),
      endTime: createTime(12, 30),
      dayOfWeek: dayOfWeek,
      lectureType: 'Lab',
      chapter: 'Kinematics Experiments',
      description: 'Practical lab on motion and velocity',
      isActive: true,
      semester: '1st',
      course: 'PHYS101'
    });

    // === ACTIVE LECTURE (Current) ===

    // 4. 🔴 ACTIVE/HAPPENING NOW - 13:00-14:30 (Early afternoon, current time around 13:30)
    sundayLectures.push({
      subject: subjects[1]._id,
      teacher: teachers[0]._id,
      classroom: 'D102',
      startTime: createTime(13, 0),
      endTime: createTime(14, 30),
      dayOfWeek: dayOfWeek,
      lectureType: 'Lecture',
      chapter: 'Sorting Algorithms Deep Dive',
      description: 'Understanding Quick Sort, Merge Sort, and Heap Sort implementations',
      isActive: true,
      semester: '2nd',
      course: 'CS201'
    });

    // === NEXT LECTURE (Coming Soon) ===

    // 5. ⭕ NEXT - 15:00-16:00 (Afternoon, ~1.5 hours away)
    sundayLectures.push({
      subject: subjects[2]._id,
      teacher: teachers[1]._id,
      classroom: 'E201',
      startTime: createTime(15, 0),
      endTime: createTime(16, 0),
      dayOfWeek: dayOfWeek,
      lectureType: 'Lecture',
      chapter: 'Derivatives and Applications',
      description: 'Understanding calculus derivatives and real-world applications',
      isActive: true,
      semester: '1st',
      course: 'MATH101'
    });

    // === UPCOMING LECTURES ===

    // 6. ⏳ UPCOMING - 16:30-17:30 (Afternoon)
    sundayLectures.push({
      subject: subjects[6]._id,
      teacher: teachers[3]._id,
      classroom: 'F301',
      startTime: createTime(16, 30),
      endTime: createTime(17, 30),
      dayOfWeek: dayOfWeek,
      lectureType: 'Lab',
      chapter: 'Circuit Design Fundamentals',
      description: 'Hands-on circuit construction and testing',
      isActive: true,
      semester: '2nd',
      course: 'ENG201'
    });

    // 7. ⏳ UPCOMING - 18:00-19:00 (Late afternoon)
    sundayLectures.push({
      subject: subjects[5]._id,
      teacher: teachers[2]._id,
      classroom: 'G201',
      startTime: createTime(18, 0),
      endTime: createTime(19, 0),
      dayOfWeek: dayOfWeek,
      lectureType: 'Seminar',
      chapter: 'Quantum Tunneling Phenomena',
      description: 'Advanced discussion on quantum mechanics phenomena',
      isActive: true,
      semester: '3rd',
      course: 'PHYS301'
    });

    // 8. ⏳ UPCOMING - 19:30-20:30 (Evening)
    sundayLectures.push({
      subject: subjects[8]._id,
      teacher: teachers[4]._id,
      classroom: 'H101',
      startTime: createTime(19, 30),
      endTime: createTime(20, 30),
      dayOfWeek: dayOfWeek,
      lectureType: 'Lecture',
      chapter: 'Organic Synthesis Routes',
      description: 'Planning and executing organic synthesis procedures',
      isActive: true,
      semester: '3rd',
      course: 'CHEM201'
    });

    // 9. ⏳ UPCOMING - 21:00-22:00 (Night)
    sundayLectures.push({
      subject: subjects[7]._id,
      teacher: teachers[3]._id,
      classroom: 'I201',
      startTime: createTime(21, 0),
      endTime: createTime(22, 0),
      dayOfWeek: dayOfWeek,
      lectureType: 'Tutorial',
      chapter: 'Digital Logic Design',
      description: 'Truth tables, boolean algebra, and logic gates',
      isActive: true,
      semester: '2nd',
      course: 'ENG301'
    });

    // === BONUS: More diverse lectures ===

    // 10. ⏳ UPCOMING - 09:00-10:30 (Morning - alternative to show diversity)
    sundayLectures.push({
      subject: subjects[9]._id,
      teacher: teachers[4]._id,
      classroom: 'J301',
      startTime: createTime(9, 0),
      endTime: createTime(10, 30),
      dayOfWeek: dayOfWeek,
      lectureType: 'Lecture',
      chapter: 'Thermodynamic Principles',
      description: 'First and second laws of thermodynamics',
      isActive: true,
      semester: '3rd',
      course: 'CHEM301'
    });

    // 11. ⏳ UPCOMING - 14:00-15:00 (Afternoon alternative)
    sundayLectures.push({
      subject: subjects[0]._id,
      teacher: teachers[0]._id,
      classroom: 'K201',
      startTime: createTime(14, 0),
      endTime: createTime(15, 0),
      dayOfWeek: dayOfWeek,
      lectureType: 'Lab',
      chapter: 'Object-Oriented Programming Basics',
      description: 'Classes, objects, and inheritance in programming',
      isActive: true,
      semester: '1st',
      course: 'CS101'
    });

    // 12. ⏳ UPCOMING - 20:00-21:00 (Evening alternative)
    sundayLectures.push({
      subject: subjects[2]._id,
      teacher: teachers[1]._id,
      classroom: 'L101',
      startTime: createTime(20, 0),
      endTime: createTime(21, 0),
      dayOfWeek: dayOfWeek,
      lectureType: 'Tutorial',
      chapter: 'Integration Techniques',
      description: 'Substitution, integration by parts, and partial fractions',
      isActive: true,
      semester: '1st',
      course: 'MATH101'
    });

    // Insert all lectures
    const insertedLectures = await Lecture.insertMany(sundayLectures);

    console.log('\n✅ Sunday\'s Complete Lecture Schedule Created:');
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
      if (idx <= 2) status = '✅ COMPLETED';
      else if (idx === 3) status = '🔴 ACTIVE/HAPPENING NOW';
      else if (idx === 4) status = '⭕ NEXT LECTURE';
      else status = '⏳ UPCOMING';

      const subject = subjects.find(s => s._id.equals(lecture.subject));
      const teacher = teachers.find(t => t._id.equals(lecture.teacher));

      console.log(`\n${lecIdx}. ${status}`);
      console.log(`   Subject: ${subject.name} (${subject.code})`);
      console.log(`   Teacher: ${teacher.name}`);
      console.log(`   Time: ${startTime} - ${endTime}`);
      console.log(`   Room: ${lecture.classroom}`);
      console.log(`   Type: ${lecture.lectureType}`);
      console.log(`   Chapter: ${lecture.chapter}`);
      console.log(`   Semester: ${lecture.semester}`);

      lecIdx++;
    });

    console.log('\n═════════════════════════════════════════════════════════');
    console.log(`\n✅ Successfully seeded ${insertedLectures.length} lectures for Sunday!`);

    // Count by status
    const completedCount = 3;
    const activeCount = 1;
    const nextCount = 1;
    const upcomingCount = insertedLectures.length - completedCount - activeCount - nextCount;

    console.log('\n📊 Summary by Status:');
    console.log(`   ✅ ${completedCount} Completed lectures (past)`);
    console.log(`   🔴 ${activeCount} Active lecture (happening now)`);
    console.log(`   ⭕ ${nextCount} Next lecture (coming up soon)`);
    console.log(`   ⏳ ${upcomingCount} Upcoming lectures (later today)`);

    console.log('\n📊 Summary by Teacher:');
    const teacherCounts = {};
    insertedLectures.forEach(lec => {
      const teacher = teachers.find(t => t._id.equals(lec.teacher));
      teacherCounts[teacher.name] = (teacherCounts[teacher.name] || 0) + 1;
    });
    Object.entries(teacherCounts).forEach(([name, count]) => {
      console.log(`   👨‍🏫 ${name}: ${count} lectures`);
    });

    console.log('\n📚 Summary by Subject:');
    const subjectCounts = {};
    insertedLectures.forEach(lec => {
      const subject = subjects.find(s => s._id.equals(lec.subject));
      subjectCounts[subject.code] = (subjectCounts[subject.code] || 0) + 1;
    });
    Object.entries(subjectCounts).forEach(([code, count]) => {
      console.log(`   📖 ${code}: ${count} lectures`);
    });

    console.log('\n🏫 Summary by Classroom:');
    const classroomCounts = {};
    insertedLectures.forEach(lec => {
      classroomCounts[lec.classroom] = (classroomCounts[lec.classroom] || 0) + 1;
    });
    Object.entries(classroomCounts).forEach(([room, count]) => {
      console.log(`   🚪 Room ${room}: ${count} lectures`);
    });

    console.log('\n📋 Summary by Type:');
    const typeCounts = {};
    insertedLectures.forEach(lec => {
      typeCounts[lec.lectureType] = (typeCounts[lec.lectureType] || 0) + 1;
    });
    Object.entries(typeCounts).forEach(([type, count]) => {
      console.log(`   🎓 ${type}: ${count} lectures`);
    });

    console.log('\n💾 Data saved to MongoDB Atlas');
    console.log(`🌐 Check dashboard at http://localhost:3000`);
    console.log(`📅 Today's lectures: Saturday`);
    console.log(`📅 Sunday lectures: ${sunday.toDateString()}`);

  } catch (error) {
    console.error('❌ Error seeding database:', error.message);
    console.error(error);
    process.exit(1);
  } finally {
    await mongoose.connection.close();
    console.log('\n🔌 Database connection closed');
  }
};

// Run seed
seedSundayLectures();
