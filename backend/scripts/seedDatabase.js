const mongoose = require('mongoose');
const Teacher = require('../models/Teacher');
const Subject = require('../models/Subject');
const Class = require('../models/Class');
const Syllabus = require('../models/Syllabus');
const Timetable = require('../models/Timetable');
const Lecture = require('../models/Lecture');
require('dotenv').config();

// --- Data Arrays for Random Generation ---

const firstNames = [
  "Aarav", "Vihaan", "Aditya", "Sai", "Arjun", "Reyansh", "Muhammad", "Aryan", "Ishaan", "Dhruv",
  "Ananya", "Aadhya", "Saanvi", "Diya", "Myra", "Ira", "Fatima", "Zoya", "Viha", "Amaya",
  "Krishna", "Rohan", "Rahul", "Amit", "Suresh", "Ramesh", "Priya", "Neha", "Sneha", "Kavita",
  "Vikram", "Siddharth", "Manish", "Deepak", "Anil", "Sunita", "Anita", "Meena", "Rekha", "Suman",
  "Kabir", "Zara", "Aaliyah", "Inaya", "Ayaan", "Vivaan", "Advik", "Atharv", "Shaurya", "Kiara"
];

const lastNames = [
  "Sharma", "Verma", "Gupta", "Malhotra", "Singh", "Kumar", "Patel", "Iyer", "Reddy", "Rao",
  "Nair", "Menon", "Khan", "Ahmed", "Ali", "Siddiqui", "Fernandes", "Dsouza", "Lobo", "Pinto",
  "Agarwal", "Joshi", "Bhatia", "Saxena", "Mehta", "Chopra", "Desai", "Shah", "Kulkarni", "Patil",
  "Yadav", "Mishra", "Pandey", "Tiwari", "Das", "Biswas", "Ghosh", "Banerjee", "Mukherjee", "Chatterjee"
];

const departments = ['Mathematics', 'Science', 'English', 'Social Science', 'Languages', 'Computer Science', 'Commerce', 'Physical Education'];

const commonTeacherQualifications = ['M.Sc', 'B.Ed', 'M.A', 'Ph.D', 'M.Com', 'MCA', 'B.Tech', 'M.P.Ed'];

// --- Subject Data Configuration ---

const subjectsData = {
  CBSE: [
    { name: 'English', code: 'ENG', category: 'Language', classes: ['Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5', 'Class 6', 'Class 7', 'Class 8', 'Class 9', 'Class 10', 'Class 11', 'Class 12'] },
    { name: 'Hindi', code: 'HIN', category: 'Language', classes: ['Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5', 'Class 6', 'Class 7', 'Class 8', 'Class 9', 'Class 10'] },
    { name: 'Mathematics', code: 'MATH', category: 'Core', classes: ['Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5', 'Class 6', 'Class 7', 'Class 8', 'Class 9', 'Class 10', 'Class 11', 'Class 12'] },
    { name: 'Environmental Studies', code: 'EVS', category: 'Core', classes: ['Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5'] },
    { name: 'Science', code: 'SCI', category: 'Core', classes: ['Class 6', 'Class 7', 'Class 8', 'Class 9', 'Class 10'] },
    { name: 'Social Science', code: 'SST', category: 'Core', classes: ['Class 6', 'Class 7', 'Class 8', 'Class 9', 'Class 10'] },
    { name: 'Physics', code: 'PHY', category: 'Core', classes: ['Class 11', 'Class 12'] },
    { name: 'Chemistry', code: 'CHEM', category: 'Core', classes: ['Class 11', 'Class 12'] },
    { name: 'Biology', code: 'BIO', category: 'Core', classes: ['Class 11', 'Class 12'] },
    { name: 'Computer Science', code: 'CS', category: 'Skill', classes: ['Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5', 'Class 6', 'Class 7', 'Class 8', 'Class 9', 'Class 10', 'Class 11', 'Class 12'] },
    { name: 'History', code: 'HIST', category: 'Core', classes: ['Class 11', 'Class 12'] },
    { name: 'Political Science', code: 'POL', category: 'Core', classes: ['Class 11', 'Class 12'] },
    { name: 'Economics', code: 'ECO', category: 'Core', classes: ['Class 11', 'Class 12'] },
    { name: 'Accountancy', code: 'ACC', category: 'Core', classes: ['Class 11', 'Class 12'] },
    { name: 'Business Studies', code: 'BS', category: 'Core', classes: ['Class 11', 'Class 12'] },
    { name: 'Physical Education', code: 'PE', category: 'Activity', classes: ['Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5', 'Class 6', 'Class 7', 'Class 8', 'Class 9', 'Class 10', 'Class 11', 'Class 12'] }
  ]
};

// --- Helper Functions ---

const getRandomElement = (arr) => arr[Math.floor(Math.random() * arr.length)];

const generateRandomName = () => `${getRandomElement(firstNames)} ${getRandomElement(lastNames)}`;

const generateRandomMobile = () => `+91 ${9000000000 + Math.floor(Math.random() * 999999999)}`;

const generateStudents = (className, section, count) => {
  const students = [];
  const startRoll = 1;
  const yearPrefix = '2024'; // Current admission year

  for (let i = 0; i < count; i++) {
    const rollNum = (startRoll + i).toString();
    // Unique Admission Number: Year + Class(2digits) + Section(Ascii) + Roll(3digits)
    // padding class number
    const classNumStr = className.replace('Class ', '').padStart(2, '0');
    const sectionCode = section.charCodeAt(0);
    const rollStr = rollNum.padStart(3, '0');
    const adminNum = `DPS${yearPrefix}${classNumStr}${sectionCode}${rollStr}`;

    students.push({
      name: generateRandomName(),
      rollNumber: rollNum,
      admissionNumber: adminNum
    });
  }
  return students;
};

const generateTeachers = (count) => {
  const teachers = [];
  for (let i = 0; i < count; i++) {
    const name = generateRandomName();
    const firstName = name.split(' ')[0].toLowerCase();
    const dept = getRandomElement(departments);

    // Assign generic subjects based on department
    let subjects = [];
    if (dept === 'Mathematics') subjects = ['Mathematics'];
    else if (dept === 'Science') subjects = ['Science', 'Physics', 'Chemistry', 'Biology', 'Environmental Studies'];
    else if (dept === 'English') subjects = ['English'];
    else if (dept === 'Social Science') subjects = ['Social Science', 'History', 'Geography', 'Political Science'];
    else if (dept === 'Computer Science') subjects = ['Computer Science'];
    else if (dept === 'Commerce') subjects = ['Economics', 'Accountancy', 'Business Studies'];
    else if (dept === 'Languages') subjects = ['Hindi', 'Sanskrit'];
    else if (dept === 'Physical Education') subjects = ['Physical Education'];

    teachers.push({
      name: `Dr. ${name}`.replace('Dr. Dr.', 'Dr.'), // Simple check, or just use prefixes array
      email: `${firstName}.${Math.floor(Math.random() * 1000)}@dps.edu.in`,
      department: dept,
      phone: generateRandomMobile(),
      office: `Room ${100 + i}`,
      subjects: subjects,
      experience: Math.floor(Math.random() * 20) + 1,
      qualifications: [getRandomElement(commonTeacherQualifications), 'B.Ed']
    });
  }
  return teachers;
};

// Time slots configuration
const timeSlots = {
  primary: [ // Classes 1-5
    { periodNumber: 1, startTime: '08:00', endTime: '08:35' },
    { periodNumber: 2, startTime: '08:35', endTime: '09:10' },
    { periodNumber: 3, startTime: '09:10', endTime: '09:45' },
    { periodNumber: 4, startTime: '09:45', endTime: '10:20' },
    // Break 10:20 - 10:35
    { periodNumber: 5, startTime: '10:35', endTime: '11:10' },
    { periodNumber: 6, startTime: '11:10', endTime: '11:45' },
    { periodNumber: 7, startTime: '11:45', endTime: '12:20' },
    { periodNumber: 8, startTime: '12:20', endTime: '12:55' }
  ],
  secondary: [ // Classes 6-12
    { periodNumber: 1, startTime: '08:00', endTime: '08:40' },
    { periodNumber: 2, startTime: '08:40', endTime: '09:20' },
    { periodNumber: 3, startTime: '09:20', endTime: '10:00' },
    { periodNumber: 4, startTime: '10:00', endTime: '10:40' },
    // Break 10:40 - 10:55
    { periodNumber: 5, startTime: '10:55', endTime: '11:35' },
    { periodNumber: 6, startTime: '11:35', endTime: '12:15' },
    { periodNumber: 7, startTime: '12:15', endTime: '12:55' },
    { periodNumber: 8, startTime: '13:40', endTime: '14:20' }
  ]
};

// --- Main Seed Function ---

const connectDB = async () => {
  try {
    const mongoURI = process.env.MONGODB_URI || 'mongodb://localhost:27017/digiboard'; // Fallback
    await mongoose.connect(mongoURI);
    console.log('MongoDB connected successfully');
  } catch (error) {
    console.error('MongoDB connection error:', error);
    process.exit(1);
  }
};

const seedDatabase = async () => {
  try {
    await connectDB();

    console.log('🗑️  Clearing existing data...');
    await Promise.all([
      Teacher.deleteMany({}),
      Subject.deleteMany({}),
      Class.deleteMany({}),
      Syllabus.deleteMany({}),
      Timetable.deleteMany({}),
      Lecture.deleteMany({})
    ]);

    // 1. Create Teachers
    console.log('👨‍🏫 Seeding teachers...');
    const generatedTeachers = generateTeachers(30); // Generate 30 teachers
    const teachers = await Teacher.insertMany(generatedTeachers);
    console.log(`✅ Created ${teachers.length} teachers`);

    // 2. Create Subjects
    console.log('📚 Seeding subjects...');
    let allSubjects = [];
    // Only CBSE for this demo to keep it simple but comprehensive
    for (const subjectData of subjectsData.CBSE) {
      const subjectClasses = subjectData.classes.map(className => ({
        className,
        isCompulsory: true,
        periodsPerWeek: subjectData.category === 'Core' ? 6 : 4,
        duration: 40
      }));
      allSubjects.push({
        name: subjectData.name,
        code: `CBSE_${subjectData.code}`,
        board: 'CBSE',
        classes: subjectClasses,
        category: subjectData.category
      });
    }

    const createdSubjects = await Subject.insertMany(allSubjects);
    console.log(`✅ Created ${createdSubjects.length} subjects`);

    // 3. Create Classes & Students
    console.log('🏫 Seeding classes and students...');
    const sections = ['A', 'B']; // Two sections for each class
    const classDocs = [];

    for (let i = 1; i <= 12; i++) {
      const className = `Class ${i}`;

      for (const section of sections) {
        // Find a class teacher (simple round-robin or random)
        const teacher = teachers[Math.floor(Math.random() * teachers.length)];

        const studentCount = 25 + Math.floor(Math.random() * 10); // 25-34 students
        const students = generateStudents(className, section, studentCount);

        classDocs.push({
          className,
          section,
          board: 'CBSE',
          academicYear: '2024-25',
          classTeacher: teacher._id,
          students: students,
          totalStudents: students.length
        });
      }
    }

    const createdClasses = await Class.insertMany(classDocs);
    console.log(`✅ Created ${createdClasses.length} classes`);

    // 4. Create Syllabus (Placeholder for all)
    console.log('📖 Seeding syllabus...');
    const syllabusDocs = [];
    for (const subject of createdSubjects) {
      for (const classMapping of subject.classes) {
        syllabusDocs.push({
          subject: subject._id,
          className: classMapping.className,
          board: 'CBSE',
          academicYear: '2024-25',
          term: 'Annual',
          units: [{
            unitNumber: 1,
            unitName: `Introduction to ${subject.name}`,
            chapters: [
              {
                chapterNumber: 1,
                chapterName: 'Chapter 1',
                topics: ['Topic 1', 'Topic 2'],
                learningOutcomes: ['Outcome 1'],
                estimatedHours: 10,
                month: 'April'
              },
              {
                chapterNumber: 2,
                chapterName: 'Chapter 2',
                topics: ['Topic A', 'Topic B'],
                learningOutcomes: ['Outcome 2'],
                estimatedHours: 12,
                month: 'May'
              }
            ],
            totalHours: 22,
            weightage: 20,
            assessmentType: 'SA1'
          }],
          textbooks: [{ title: 'Standard Textbook', author: 'Author', publisher: 'Pub', isMain: true }]
        });
      }
    }
    // Batch insert can fail if duplicates, but we cleared DB. 
    // However, some subjects map to SAME class (e.g. English, Hindi both for Class 1)
    // Syllabus is unique per subject+class+board.
    await Syllabus.insertMany(syllabusDocs);
    console.log(`✅ Created ${syllabusDocs.length} syllabus entries`);


    // 5. Create Timetables & Lectures
    console.log('⏰ Seeding timetables and lectures...');
    const timetables = [];
    const lectures = [];
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

    // Date Setup for Lectures (Current Week)
    const today = new Date();
    // Calculate start of current week (assuming Monday start)
    const dayOfWeek = today.getDay(); // 0 (Sun) - 6 (Sat)
    const diffToMon = today.getDate() - dayOfWeek + (dayOfWeek === 0 ? -6 : 1);
    const mondayDate = new Date(today.setDate(diffToMon)); // Monday of current week

    // We will generate lectures for Mon-Sat of THIS week
    const weekDates = [];
    for (let d = 0; d < 6; d++) {
      const date = new Date(mondayDate);
      date.setDate(mondayDate.getDate() + d);
      weekDates.push(date);
    }

    for (const cls of createdClasses) {
      const isPrimary = cls.className.match(/Class [1-5]$/);
      const slots = isPrimary ? timeSlots.primary : timeSlots.secondary;

      const possibleSubjects = createdSubjects.filter(s => s.classes.some(c => c.className === cls.className));

      const weeklySchedule = [];

      for (let dayIndex = 0; dayIndex < days.length; dayIndex++) {
        const day = days[dayIndex];
        const dateForDay = weekDates[dayIndex];

        const periods = [];

        for (let i = 0; i < slots.length; i++) {
          const slot = slots[i];
          // Simple logic: pick a random subject
          // Ideally we'd cycle through them to ensure coverge, but random is okay for mock
          const subject = possibleSubjects[i % possibleSubjects.length];

          // Find a teacher for this subject
          // In our mock teacher generation, they have subjects strings.
          // Subject model has 'name'. Match them up.
          const teacher = teachers.find(t => t.subjects.includes(subject.name)) || teachers[0];

          const periodObj = {
            periodNumber: slot.periodNumber,
            startTime: slot.startTime,
            endTime: slot.endTime,
            classroom: `Room ${cls.className}-${cls.section}`,
            periodType: 'Regular',
            subject: subject._id,
            teacher: teacher._id
          };

          periods.push(periodObj);

          // Generate Lecture for this specific period instance
          // Parse time for Date object
          const [startH, startM] = slot.startTime.split(':');
          const [endH, endM] = slot.endTime.split(':');

          const lectureStart = new Date(dateForDay);
          lectureStart.setHours(parseInt(startH), parseInt(startM), 0);

          const lectureEnd = new Date(dateForDay);
          lectureEnd.setHours(parseInt(endH), parseInt(endM), 0);

          lectures.push({
            subject: subject._id,
            teacher: teacher._id,
            classroom: periodObj.classroom,
            startTime: lectureStart,
            endTime: lectureEnd,
            dayOfWeek: day,
            lectureType: 'Lecture',
            semester: 'Term 1',
            course: cls.className,
            chapter: `Chapter ${1 + Math.floor(Math.random() * 5)}`,
            description: `Regular session`,
            isActive: true
          });
        }

        // Add Breaks (Fixed for now based on slots array logic implicitly)
        // But strict Timetable schema might require specific break structure if 'periods' includes breaks
        // Looking at schema: periodType includes 'Break'.
        // Let's insert a break at proper index
        const breakIndex = isPrimary ? 4 : 4; // After 4th period
        const breakSlot = {
          periodNumber: 5, // technically shifts others? No, periodNumber is explicit
          // Simplify: just adding it to schedule structure if needed. 
          // Schema has 'isBreak'.
          // Let's just create the break period object
          startTime: isPrimary ? '10:20' : '10:40',
          endTime: isPrimary ? '10:35' : '10:55',
          classroom: 'Playground',
          periodType: 'Break',
          isBreak: true
        };
        // Note: In real logic we'd insert this into the periods array used for Timetable
        // but for simplicity I am just keeping the 'regular' periods in the loop above distinct.
        periods.push(breakSlot);

        weeklySchedule.push({
          dayOfWeek: day,
          periods: periods.sort((a, b) => parseInt(a.startTime) - parseInt(b.startTime))
        });
      }

      timetables.push({
        class: cls._id,
        academicYear: '2024-25',
        effectiveFrom: new Date('2024-04-01'),
        effectiveTo: new Date('2025-03-31'),
        weeklySchedule: weeklySchedule,
        breakTimings: [{
          name: 'Recess',
          startTime: isPrimary ? '10:20' : '10:40',
          endTime: isPrimary ? '10:35' : '10:55',
          duration: 15
        }]
      });
    }

    await Timetable.insertMany(timetables);
    console.log(`✅ Created ${timetables.length} timetables`);

    await Lecture.insertMany(lectures);
    console.log(`✅ Created ${lectures.length} lectures for the current week (${mondayDate.toDateString()} - ${weekDates[5].toDateString()})`);

    console.log('\n🎉 Database seeding completed successfully!');

  } catch (error) {
    console.error('❌ Error seeding database:', error);
  } finally {
    await mongoose.connection.close();
    console.log('\n✅ Database connection closed');
  }
};

if (require.main === module) {
  seedDatabase();
}

module.exports = { seedDatabase };
