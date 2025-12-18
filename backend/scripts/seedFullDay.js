const mongoose = require('mongoose');
const dotenv = require('dotenv');
const path = require('path');

// Load env vars
dotenv.config({ path: path.join(__dirname, '.env') });

// Models
const Lecture = require('./models/Lecture');
const Teacher = require('./models/Teacher');
const Subject = require('./models/Subject');

// Connect to MongoDB
// Connect to MongoDB
const mongoUri = process.env.MONGODB_URI;
if (!mongoUri) {
  console.error('FATAL ERROR: MONGODB_URI environment variable is not defined');
  process.exit(1);
}

mongoose.connect(mongoUri)
  .then(() => console.log('✅ Connected to MongoDB'))
  .catch(err => {
    console.error('❌ MongoDB connection error:', err);
    process.exit(1);
  });

const subjectsData = [
  { name: 'Mathematics', code: 'MATH101', board: 'CBSE' },
  { name: 'Physics', code: 'PHY101', board: 'CBSE' },
  { name: 'Chemistry', code: 'CHEM101', board: 'CBSE' },
  { name: 'Biology', code: 'BIO101', board: 'CBSE' },
  { name: 'Computer Science', code: 'CS101', board: 'CBSE' },
  { name: 'English Literature', code: 'ENG101', board: 'CBSE' },
  { name: 'History', code: 'HIST101', board: 'CBSE' },
  { name: 'Geography', code: 'GEO101', board: 'CBSE' }
];

const teachersData = [
  { name: 'Dr. Sarah Smith', email: 'sarah.smith@school.edu', department: 'Science' },
  { name: 'Mr. James Wilson', email: 'james.wilson@school.edu', department: 'Mathematics' },
  { name: 'Mrs. Emily Davis', email: 'emily.davis@school.edu', department: 'Languages' },
  { name: 'Prof. Alan Turing', email: 'alan.turing@school.edu', department: 'Computer Science' },
  { name: 'Dr. Marie Curie', email: 'marie.curie@school.edu', department: 'Chemistry' },
  { name: 'Mr. Isaac Newton', email: 'isaac.newton@school.edu', department: 'Physics' }
];

const generateSchedule = async () => {
  try {
    // 1. Clear today's lectures
    const startOfDay = new Date();
    startOfDay.setHours(0, 0, 0, 0);
    const endOfDay = new Date();
    endOfDay.setHours(23, 59, 59, 999);

    await Lecture.deleteMany({
      startTime: { $gte: startOfDay, $lte: endOfDay }
    });
    console.log('🧹 Cleared today\'s existing lectures');

    // 2. Create/Get Teachers
    const teacherDocs = [];
    for (const t of teachersData) {
      let teacher = await Teacher.findOne({ email: t.email });
      if (!teacher) {
        teacher = await Teacher.create(t);
      }
      teacherDocs.push(teacher);
    }
    console.log(`👥 Loaded ${teacherDocs.length} teachers`);

    // 3. Create/Get Subjects
    const subjectDocs = [];
    for (const s of subjectsData) {
      let subject = await Subject.findOne({ code: s.code });
      if (!subject) {
        subject = await Subject.create(s);
      }
      subjectDocs.push(subject);
    }
    console.log(`📚 Loaded ${subjectDocs.length} subjects`);

    // 4. Generate Schedule
    const lectures = [];

    // Start schedule at 8:00 AM
    let currentTime = new Date();
    currentTime.setHours(8, 0, 0, 0);

    const scheduleSlots = 8; // 8 lectures
    const durationMinutes = 45;
    const breakMinutes = 10;

    for (let i = 0; i < scheduleSlots; i++) {
      const subject = subjectDocs[i % subjectDocs.length];
      const teacher = teacherDocs[i % teacherDocs.length];

      let startTime = new Date(currentTime);
      let endTime = new Date(currentTime);
      endTime.setMinutes(endTime.getMinutes() + durationMinutes);

      lectures.push({
        subject: subject._id,
        teacher: teacher._id,
        classroom: `Room ${101 + i}`,
        startTime: startTime,
        endTime: endTime,
        dayOfWeek: startTime.toLocaleDateString('en-US', { weekday: 'long' }),
        lectureType: 'Lecture',
        chapter: `Chapter ${i + 1}`,
        description: `Detailed study of ${subject.name} concepts. Homework: Exercise ${i + 1}.1`,
        isActive: true,
        semester: 'Fall 2025',
        course: 'Grade 10'
      });

      // Advance time
      currentTime.setMinutes(currentTime.getMinutes() + durationMinutes + breakMinutes);
    }

    // 5. Inject "Current Lecture"
    // We'll add a special lecture that starts 10 mins ago and ends in 35 mins
    const currentStart = new Date();
    currentStart.setMinutes(currentStart.getMinutes() - 15);
    const currentEnd = new Date();
    currentEnd.setMinutes(currentEnd.getMinutes() + 30);

    // Find a subject and teacher for the current lecture
    const currentSubject = subjectDocs.find(s => s.name === 'Computer Science') || subjectDocs[0];
    const currentTeacher = teacherDocs.find(t => t.department === 'Computer Science') || teacherDocs[0];

    lectures.push({
      subject: currentSubject._id,
      teacher: currentTeacher._id,
      classroom: "Innovation Lab",
      startTime: currentStart,
      endTime: currentEnd,
      dayOfWeek: currentStart.toLocaleDateString('en-US', { weekday: 'long' }),
      lectureType: 'Lab', // Valid enum
      chapter: "Generative AI Models",
      description: "Deep dive into Large Language Models and Transformer architecture.",
      isActive: true,
      semester: 'Fall 2025',
      course: 'Special Track'
    });

    // Sort lectures by start time
    lectures.sort((a, b) => a.startTime - b.startTime);

    await Lecture.insertMany(lectures);
    console.log(`✅ Successfully seeded ${lectures.length} lectures for today!`);
    console.log(`🕒 Added 'Advanced AI Workshop' happening NOW (${currentStart.toLocaleTimeString()} - ${currentEnd.toLocaleTimeString()})`);

    process.exit(0);
  } catch (error) {
    console.error('❌ Error seeding database:', error);
    process.exit(1);
  }
};

generateSchedule();
