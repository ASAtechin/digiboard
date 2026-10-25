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

    // Create teachers with Indian names and realistic school data
    const teachers = await Teacher.create([
      {
        name: 'Dr. Rajesh Kumar Sharma',
        email: 'rajesh.sharma@dpsdelhi.edu.in',
        department: 'Computer Science',
        phone: '+91-98765-43210',
        office: 'CS-Block, Room 201',
        subjects: ['Computer Science XII', 'Information Practices', 'Python Programming'],
        experience: 15,
        qualifications: ['PhD Computer Science (IIT Delhi)', 'M.Tech Software Engineering (IIIT Hyderabad)', 'B.Tech CSE (NSUT Delhi)'],
        profileImage: 'https://via.placeholder.com/150/0066CC/FFFFFF?text=RKS'
      },
      {
        name: 'Mrs. Priya Agarwal',
        email: 'priya.agarwal@dpsdelhi.edu.in',
        department: 'Mathematics',
        phone: '+91-98765-43211',
        office: 'Math Block, Room 105',
        subjects: ['Mathematics XII', 'Applied Mathematics', 'Statistics'],
        experience: 12,
        qualifications: ['M.Sc Mathematics (Delhi University)', 'B.Ed (NCERT)', 'B.Sc Honors Mathematics (Shri Ram College)'],
        profileImage: 'https://via.placeholder.com/150/009900/FFFFFF?text=PA'
      },
      {
        name: 'Dr. Arjun Singh Chauhan',
        email: 'arjun.chauhan@dpsdelhi.edu.in',
        department: 'Physics',
        phone: '+91-98765-43212',
        office: 'Science Block, Room 301',
        subjects: ['Physics XII', 'Applied Physics', 'Electronics'],
        experience: 18,
        qualifications: ['PhD Physics (IISc Bangalore)', 'M.Sc Physics (JNU Delhi)', 'B.Sc Physics (Hindu College DU)'],
        profileImage: 'https://via.placeholder.com/150/CC6600/FFFFFF?text=ASC'
      },
      {
        name: 'Ms. Kavya Reddy',
        email: 'kavya.reddy@dpsdelhi.edu.in',
        department: 'Chemistry',
        phone: '+91-98765-43213',
        office: 'Science Block, Room 205',
        subjects: ['Chemistry XII', 'Organic Chemistry', 'Physical Chemistry'],
        experience: 8,
        qualifications: ['M.Sc Chemistry (BITS Pilani)', 'B.Ed Science (Jamia Millia)', 'B.Sc Chemistry (St. Stephens College)'],
        profileImage: 'https://via.placeholder.com/150/9900CC/FFFFFF?text=KR'
      },
      {
        name: 'Mr. Suresh Gupta',
        email: 'suresh.gupta@dpsdelhi.edu.in',
        department: 'English',
        phone: '+91-98765-43214',
        office: 'Humanities Block, Room 110',
        subjects: ['English XII', 'English Literature', 'Creative Writing'],
        experience: 20,
        qualifications: ['MA English Literature (JNU)', 'B.Ed English (NCERT)', 'BA Honors English (Miranda House DU)'],
        profileImage: 'https://via.placeholder.com/150/CC0066/FFFFFF?text=SG'
      },
      {
        name: 'Dr. Meera Patel',
        email: 'meera.patel@dpsdelhi.edu.in',
        department: 'Biology',
        phone: '+91-98765-43215',
        office: 'Science Block, Room 402',
        subjects: ['Biology XII', 'Biotechnology', 'Environmental Science'],
        experience: 14,
        qualifications: ['PhD Biotechnology (IIT Bombay)', 'M.Sc Botany (Mumbai University)', 'B.Sc Life Sciences (DU)'],
        profileImage: 'https://via.placeholder.com/150/00CC99/FFFFFF?text=MP'
      }
    ]);

    console.log('Teachers created:', teachers.length);

    // Create lectures for the week with Indian school schedule
    const lectures = [];
    const times = [
      { start: '08:00', end: '08:45' },  // 1st Period
      { start: '08:45', end: '09:30' },  // 2nd Period
      { start: '09:50', end: '10:35' },  // 3rd Period (after short break)
      { start: '10:35', end: '11:20' },  // 4th Period
      { start: '11:40', end: '12:25' },  // 5th Period (after long break)
      { start: '12:25', end: '13:10' },  // 6th Period
      { start: '14:00', end: '14:45' },  // 7th Period (after lunch)
      { start: '14:45', end: '15:30' }   // 8th Period
    ];

    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    const subjects = [
      { 
        name: 'Computer Science - Class XII', 
        teacher: teachers[0]._id, 
        chapter: 'Chapter 5: Database Concepts & SQL', 
        course: 'Computer Science',
        room: 'Computer Lab 1'
      },
      { 
        name: 'Mathematics - Class XII', 
        teacher: teachers[1]._id, 
        chapter: 'Chapter 8: Application of Integrals', 
        course: 'Mathematics',
        room: 'Room 201'
      },
      { 
        name: 'Physics - Class XII', 
        teacher: teachers[2]._id, 
        chapter: 'Chapter 12: Atoms', 
        course: 'Physics',
        room: 'Physics Lab'
      },
      { 
        name: 'Chemistry - Class XII', 
        teacher: teachers[3]._id, 
        chapter: 'Chapter 6: General Principles of Metallurgy', 
        course: 'Chemistry',
        room: 'Chemistry Lab'
      },
      { 
        name: 'English - Class XII', 
        teacher: teachers[4]._id, 
        chapter: 'Flamingo: Chapter 3 - Deep Water', 
        course: 'English Core',
        room: 'Room 105'
      },
      { 
        name: 'Biology - Class XII', 
        teacher: teachers[5]._id, 
        chapter: 'Chapter 7: Evolution', 
        course: 'Biology',
        room: 'Biology Lab'
      },
      { 
        name: 'Information Practices - Class XII', 
        teacher: teachers[0]._id, 
        chapter: 'Chapter 4: Introduction to Python', 
        course: 'Information Practices',
        room: 'Computer Lab 2'
      },
      { 
        name: 'Applied Mathematics - Class XI', 
        teacher: teachers[1]._id, 
        chapter: 'Chapter 5: Complex Numbers', 
        course: 'Applied Mathematics',
        room: 'Room 203'
      }
    ];

    let lectureIndex = 0;
    for (const day of days) {
      // Indian schools typically have 6-8 periods per day
      const periodsPerDay = day === 'Saturday' ? 4 : 6; // Saturday half day
      
      for (let i = 0; i < periodsPerDay; i++) {
        const subject = subjects[lectureIndex % subjects.length];
        const time = times[i];
        
        const startDate = new Date();
        startDate.setHours(parseInt(time.start.split(':')[0]), parseInt(time.start.split(':')[1]), 0);
        
        const endDate = new Date();
        endDate.setHours(parseInt(time.end.split(':')[0]), parseInt(time.end.split(':')[1]), 0);

        lectures.push({
          subject: subject.name,
          teacher: subject.teacher,
          classroom: subject.room,
          startTime: startDate,
          endTime: endDate,
          dayOfWeek: day,
          lectureType: subject.room.includes('Lab') ? 'Lab' : 'Lecture',
          chapter: subject.chapter,
          description: `${subject.name} - ${subject.chapter}. Important topics: CBSE Board preparation, practical assignments, and conceptual clarity.`,
          semester: 'Academic Year 2024-25',
          course: subject.course,
          isActive: true
        });
        lectureIndex++;
      }
    }

    await Lecture.create(lectures);
    console.log('Lectures created:', lectures.length);

    console.log('🏫 Delhi Public School DigiBoard Database seeded successfully!');
    console.log('📚 Created Indian school data with CBSE curriculum');
    console.log('👨‍🏫 Teachers: 6 faculty members with Indian qualifications');
    console.log('📅 Lectures: Weekly schedule for Classes XI & XII');
    console.log('🇮🇳 Realistic Indian educational institution scenario ready!');
    
    // Don't exit when called as module
    if (require.main === module) {
      process.exit(0);
    }
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
