const mongoose = require('mongoose');
const Teacher = require('./models/Teacher');
const Lecture = require('./models/Lecture');
require('dotenv').config();

const seedData = async () => {
  try {
    // Use existing mongoose connection
    console.log('Seeding database...');

    // Clear existing data
    await Teacher.deleteMany({});
    await Lecture.deleteMany({});

    // Create teachers
    const teachers = await Teacher.create([
      {
        name: 'Dr. Sarah Johnson',
        email: 'sarah.johnson@university.edu',
        department: 'Computer Science',
        phone: '+1-555-0101',
        office: 'CS-201',
        subjects: ['Data Structures', 'Algorithms'],
        experience: 8,
        qualifications: ['PhD Computer Science', 'MS Software Engineering'],
        profileImage: 'https://via.placeholder.com/150/0066CC/FFFFFF?text=SJ'
      },
      {
        name: 'Prof. Michael Chen',
        email: 'michael.chen@university.edu',
        department: 'Mathematics',
        phone: '+1-555-0102',
        office: 'MATH-105',
        subjects: ['Calculus', 'Linear Algebra'],
        experience: 12,
        qualifications: ['PhD Mathematics', 'MS Applied Mathematics'],
        profileImage: 'https://via.placeholder.com/150/009900/FFFFFF?text=MC'
      },
      {
        name: 'Dr. Emily Rodriguez',
        email: 'emily.rodriguez@university.edu',
        department: 'Physics',
        phone: '+1-555-0103',
        office: 'PHY-301',
        subjects: ['Quantum Physics', 'Electromagnetism'],
        experience: 6,
        qualifications: ['PhD Physics', 'MS Theoretical Physics'],
        profileImage: 'https://via.placeholder.com/150/CC6600/FFFFFF?text=ER'
      },
      {
        name: 'Prof. David Wilson',
        email: 'david.wilson@university.edu',
        department: 'Computer Science',
        phone: '+1-555-0104',
        office: 'CS-105',
        subjects: ['Database Systems', 'Web Development'],
        experience: 10,
        qualifications: ['PhD Computer Science', 'MS Information Systems'],
        profileImage: 'https://via.placeholder.com/150/990066/FFFFFF?text=DW'
      }
    ]);

    console.log('Teachers created:', teachers.length);

    // Create lectures for the week
    const lectures = [];
    const times = [
      { start: '09:00', end: '10:30' },
      { start: '11:00', end: '12:30' },
      { start: '14:00', end: '15:30' },
      { start: '16:00', end: '17:30' }
    ];

    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
    const subjects = [
      { name: 'Data Structures & Algorithms', teacher: teachers[0]._id, chapter: 'Chapter 5: Binary Trees', course: 'Computer Science' },
      { name: 'Calculus II', teacher: teachers[1]._id, chapter: 'Chapter 8: Integration Techniques', course: 'Mathematics' },
      { name: 'Quantum Physics', teacher: teachers[2]._id, chapter: 'Chapter 3: Wave Functions', course: 'Physics' },
      { name: 'Database Systems', teacher: teachers[3]._id, chapter: 'Chapter 6: Query Optimization', course: 'Computer Science' },
      { name: 'Linear Algebra', teacher: teachers[1]._id, chapter: 'Chapter 4: Eigenvalues', course: 'Mathematics' },
      { name: 'Web Development', teacher: teachers[3]._id, chapter: 'Chapter 9: React Fundamentals', course: 'Computer Science' }
    ];

    let lectureIndex = 0;
    for (const day of days) {
      for (let i = 0; i < 3; i++) {
        const subject = subjects[lectureIndex % subjects.length];
        const time = times[i];
        
        const startDate = new Date();
        startDate.setHours(parseInt(time.start.split(':')[0]), parseInt(time.start.split(':')[1]), 0);
        
        const endDate = new Date();
        endDate.setHours(parseInt(time.end.split(':')[0]), parseInt(time.end.split(':')[1]), 0);

        lectures.push({
          subject: subject.name,
          teacher: subject.teacher,
          classroom: `Room ${200 + (lectureIndex % 10)}`,
          startTime: startDate,
          endTime: endDate,
          dayOfWeek: day,
          lectureType: i === 2 ? 'Lab' : 'Lecture',
          chapter: subject.chapter,
          description: `${subject.name} - ${subject.chapter}`,
          semester: 'Fall 2025',
          course: subject.course
        });
        lectureIndex++;
      }
    }

    await Lecture.create(lectures);
    console.log('Lectures created:', lectures.length);

    console.log('Database seeded successfully!');
    process.exit(0);
  } catch (error) {
    console.error('Error seeding database:', error);
    process.exit(1);
  }
};

// Export the function for use in API endpoint
module.exports = seedData;

// Also allow direct execution
if (require.main === module) {
  seedData();
}
