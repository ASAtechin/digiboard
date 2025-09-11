const mongoose = require('mongoose');
const Teacher = require('./models/Teacher');
const Subject = require('./models/Subject');
const Class = require('./models/Class');
const Syllabus = require('./models/Syllabus');
const Timetable = require('./models/Timetable');
const Lecture = require('./models/Lecture');
require('dotenv').config();

// CBSE and ICSE Subject Data
const subjectsData = {
  CBSE: [
    // Primary Classes (1-5)
    { name: 'English', code: 'ENG', category: 'Language', classes: ['Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5'] },
    { name: 'Hindi', code: 'HIN', category: 'Language', classes: ['Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5'] },
    { name: 'Mathematics', code: 'MATH', category: 'Core', classes: ['Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5'] },
    { name: 'Environmental Studies', code: 'EVS', category: 'Core', classes: ['Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5'] },
    { name: 'Computer Science', code: 'CS', category: 'Skill', classes: ['Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5'] },
    { name: 'Art Education', code: 'ART', category: 'Activity', classes: ['Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5'] },
    { name: 'Physical Education', code: 'PE', category: 'Activity', classes: ['Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5'] },
    
    // Middle Classes (6-8)
    { name: 'English', code: 'ENG', category: 'Language', classes: ['Class 6', 'Class 7', 'Class 8'] },
    { name: 'Hindi', code: 'HIN', category: 'Language', classes: ['Class 6', 'Class 7', 'Class 8'] },
    { name: 'Mathematics', code: 'MATH', category: 'Core', classes: ['Class 6', 'Class 7', 'Class 8'] },
    { name: 'Science', code: 'SCI', category: 'Core', classes: ['Class 6', 'Class 7', 'Class 8'] },
    { name: 'Social Science', code: 'SST', category: 'Core', classes: ['Class 6', 'Class 7', 'Class 8'] },
    { name: 'Sanskrit', code: 'SAN', category: 'Language', classes: ['Class 6', 'Class 7', 'Class 8'] },
    
    // Secondary Classes (9-10)
    { name: 'English', code: 'ENG', category: 'Language', classes: ['Class 9', 'Class 10'] },
    { name: 'Hindi', code: 'HIN', category: 'Language', classes: ['Class 9', 'Class 10'] },
    { name: 'Mathematics', code: 'MATH', category: 'Core', classes: ['Class 9', 'Class 10'] },
    { name: 'Science', code: 'SCI', category: 'Core', classes: ['Class 9', 'Class 10'] },
    { name: 'Social Science', code: 'SST', category: 'Core', classes: ['Class 9', 'Class 10'] },
    { name: 'Sanskrit', code: 'SAN', category: 'Language', classes: ['Class 9', 'Class 10'] },
    { name: 'French', code: 'FRE', category: 'Language', classes: ['Class 9', 'Class 10'] },
    { name: 'Information Technology', code: 'IT', category: 'Skill', classes: ['Class 9', 'Class 10'] },
    
    // Senior Secondary Classes (11-12)
    { name: 'English Core', code: 'ENG_CORE', category: 'Language', classes: ['Class 11', 'Class 12'] },
    { name: 'Physics', code: 'PHY', category: 'Core', classes: ['Class 11', 'Class 12'] },
    { name: 'Chemistry', code: 'CHEM', category: 'Core', classes: ['Class 11', 'Class 12'] },
    { name: 'Mathematics', code: 'MATH', category: 'Core', classes: ['Class 11', 'Class 12'] },
    { name: 'Biology', code: 'BIO', category: 'Core', classes: ['Class 11', 'Class 12'] },
    { name: 'Computer Science', code: 'CS', category: 'Elective', classes: ['Class 11', 'Class 12'] },
    { name: 'Economics', code: 'ECO', category: 'Core', classes: ['Class 11', 'Class 12'] },
    { name: 'Business Studies', code: 'BS', category: 'Core', classes: ['Class 11', 'Class 12'] },
    { name: 'Accountancy', code: 'ACC', category: 'Core', classes: ['Class 11', 'Class 12'] },
    { name: 'Political Science', code: 'POL', category: 'Core', classes: ['Class 11', 'Class 12'] },
    { name: 'History', code: 'HIST', category: 'Core', classes: ['Class 11', 'Class 12'] },
    { name: 'Geography', code: 'GEO', category: 'Core', classes: ['Class 11', 'Class 12'] }
  ],
  ICSE: [
    // Similar structure for ICSE with slight variations
    { name: 'English Language', code: 'ENG_LANG', category: 'Language', classes: ['Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5'] },
    { name: 'English Literature', code: 'ENG_LIT', category: 'Language', classes: ['Class 9', 'Class 10', 'Class 11', 'Class 12'] },
    { name: 'Hindi', code: 'HIN', category: 'Language', classes: ['Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5'] },
    { name: 'Mathematics', code: 'MATH', category: 'Core', classes: ['Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5', 'Class 6', 'Class 7', 'Class 8', 'Class 9', 'Class 10', 'Class 11', 'Class 12'] },
    { name: 'Physics', code: 'PHY', category: 'Core', classes: ['Class 9', 'Class 10', 'Class 11', 'Class 12'] },
    { name: 'Chemistry', code: 'CHEM', category: 'Core', classes: ['Class 9', 'Class 10', 'Class 11', 'Class 12'] },
    { name: 'Biology', code: 'BIO', category: 'Core', classes: ['Class 9', 'Class 10', 'Class 11', 'Class 12'] },
    { name: 'History & Civics', code: 'HIST_CIV', category: 'Core', classes: ['Class 6', 'Class 7', 'Class 8', 'Class 9', 'Class 10'] },
    { name: 'Geography', code: 'GEO', category: 'Core', classes: ['Class 6', 'Class 7', 'Class 8', 'Class 9', 'Class 10'] },
    { name: 'Computer Applications', code: 'COMP_APP', category: 'Skill', classes: ['Class 9', 'Class 10'] }
  ]
};

// Teacher Data
const teachersData = [
  {
    name: 'Dr. Priya Sharma',
    email: 'priya.sharma@dps.edu.in',
    department: 'Mathematics',
    phone: '+91 9876543210',
    office: 'Room 101, Academic Block A',
    subjects: ['Mathematics', 'Physics'],
    experience: 15,
    qualifications: ['M.Sc Mathematics', 'Ph.D Mathematics', 'B.Ed']
  },
  {
    name: 'Mr. Rajesh Kumar',
    email: 'rajesh.kumar@dps.edu.in',
    department: 'Science',
    phone: '+91 9876543211',
    office: 'Room 102, Science Block',
    subjects: ['Physics', 'Chemistry'],
    experience: 12,
    qualifications: ['M.Sc Physics', 'B.Ed']
  },
  {
    name: 'Ms. Anjali Verma',
    email: 'anjali.verma@dps.edu.in',
    department: 'English',
    phone: '+91 9876543212',
    office: 'Room 201, Academic Block B',
    subjects: ['English', 'English Literature'],
    experience: 10,
    qualifications: ['M.A English Literature', 'B.Ed']
  },
  {
    name: 'Mr. Suresh Patel',
    email: 'suresh.patel@dps.edu.in',
    department: 'Science',
    phone: '+91 9876543213',
    office: 'Room 103, Science Block',
    subjects: ['Chemistry', 'Biology'],
    experience: 14,
    qualifications: ['M.Sc Chemistry', 'Ph.D Chemistry', 'B.Ed']
  },
  {
    name: 'Ms. Kavita Singh',
    email: 'kavita.singh@dps.edu.in',
    department: 'Social Science',
    phone: '+91 9876543214',
    office: 'Room 202, Academic Block B',
    subjects: ['History', 'Geography', 'Political Science'],
    experience: 11,
    qualifications: ['M.A History', 'B.Ed']
  },
  {
    name: 'Mr. Amit Gupta',
    email: 'amit.gupta@dps.edu.in',
    department: 'Computer Science',
    phone: '+91 9876543215',
    office: 'Room 301, IT Block',
    subjects: ['Computer Science', 'Information Technology'],
    experience: 8,
    qualifications: ['MCA', 'B.Tech Computer Science']
  },
  {
    name: 'Mrs. Sunita Agarwal',
    email: 'sunita.agarwal@dps.edu.in',
    department: 'Languages',
    phone: '+91 9876543216',
    office: 'Room 203, Academic Block B',
    subjects: ['Hindi', 'Sanskrit'],
    experience: 13,
    qualifications: ['M.A Hindi', 'B.Ed']
  },
  {
    name: 'Dr. Vikram Malhotra',
    email: 'vikram.malhotra@dps.edu.in',
    department: 'Science',
    phone: '+91 9876543217',
    office: 'Room 104, Science Block',
    subjects: ['Biology', 'Environmental Studies'],
    experience: 16,
    qualifications: ['M.Sc Biology', 'Ph.D Biology', 'B.Ed']
  },
  {
    name: 'Ms. Neha Joshi',
    email: 'neha.joshi@dps.edu.in',
    department: 'Commerce',
    phone: '+91 9876543218',
    office: 'Room 204, Academic Block B',
    subjects: ['Economics', 'Business Studies', 'Accountancy'],
    experience: 9,
    qualifications: ['M.Com', 'MBA', 'B.Ed']
  },
  {
    name: 'Mr. Rohit Bhatia',
    email: 'rohit.bhatia@dps.edu.in',
    department: 'Physical Education',
    phone: '+91 9876543219',
    office: 'Sports Complex',
    subjects: ['Physical Education', 'Health Education'],
    experience: 7,
    qualifications: ['M.P.Ed', 'B.P.Ed']
  }
];

// CBSE Class 10 Mathematics Syllabus (Detailed)
const class10MathSyllabus = {
  subject: null, // Will be filled after subject creation
  className: 'Class 10',
  board: 'CBSE',
  academicYear: '2024-25',
  term: 'Annual',
  units: [
    {
      unitNumber: 1,
      unitName: 'Number Systems',
      description: 'Real Numbers and their applications',
      chapters: [
        {
          chapterNumber: 1,
          chapterName: 'Real Numbers',
          topics: [
            'Euclid\'s division lemma',
            'Fundamental Theorem of Arithmetic',
            'HCF and LCM of positive integers',
            'Proving √2, √3, √5 are irrational',
            'Decimal representations of rational numbers'
          ],
          learningOutcomes: [
            'Apply Euclid\'s division algorithm to find HCF',
            'Prove the fundamental theorem of arithmetic',
            'Express numbers in terms of their prime factorization'
          ],
          estimatedHours: 15,
          month: 'April'
        }
      ],
      totalHours: 15,
      weightage: 6,
      assessmentType: 'SA1'
    },
    {
      unitNumber: 2,
      unitName: 'Algebra',
      description: 'Polynomials, Linear Equations, Quadratic Equations',
      chapters: [
        {
          chapterNumber: 2,
          chapterName: 'Polynomials',
          topics: [
            'Polynomials in one variable',
            'Zeros of a polynomial',
            'Relationship between zeros and coefficients of quadratic polynomials',
            'Division algorithm for polynomials'
          ],
          learningOutcomes: [
            'Find zeros of quadratic polynomials',
            'Verify the relationship between zeros and coefficients',
            'Apply division algorithm for polynomials'
          ],
          estimatedHours: 12,
          month: 'May'
        },
        {
          chapterNumber: 3,
          chapterName: 'Pair of Linear Equations in Two Variables',
          topics: [
            'Pair of linear equations in two variables',
            'Graphical method of solution',
            'Algebraic methods: substitution, elimination, cross-multiplication',
            'Applications in day-to-day life problems'
          ],
          learningOutcomes: [
            'Solve pair of linear equations graphically',
            'Apply algebraic methods to solve linear equations',
            'Formulate problems from real life situations'
          ],
          estimatedHours: 15,
          month: 'June'
        },
        {
          chapterNumber: 4,
          chapterName: 'Quadratic Equations',
          topics: [
            'Standard form of a quadratic equation',
            'Solution by factorization',
            'Solution by completing the square',
            'Quadratic formula',
            'Nature of roots',
            'Applications'
          ],
          learningOutcomes: [
            'Solve quadratic equations by different methods',
            'Determine nature of roots without solving',
            'Apply quadratic equations to solve practical problems'
          ],
          estimatedHours: 15,
          month: 'July'
        }
      ],
      totalHours: 42,
      weightage: 20,
      assessmentType: 'SA1'
    },
    {
      unitNumber: 3,
      unitName: 'Coordinate Geometry',
      description: 'Lines and basic concepts',
      chapters: [
        {
          chapterNumber: 7,
          chapterName: 'Coordinate Geometry',
          topics: [
            'Distance formula',
            'Section formula',
            'Area of a triangle',
            'Concepts related to coordinate geometry'
          ],
          learningOutcomes: [
            'Find distance between two points',
            'Apply section formula to find coordinates',
            'Calculate area of triangle using coordinates'
          ],
          estimatedHours: 12,
          month: 'August'
        }
      ],
      totalHours: 12,
      weightage: 6,
      assessmentType: 'SA2'
    },
    {
      unitNumber: 4,
      unitName: 'Geometry',
      description: 'Triangles, Circles, and Constructions',
      chapters: [
        {
          chapterNumber: 6,
          chapterName: 'Triangles',
          topics: [
            'Definitions, examples, counter examples of similar triangles',
            'Basic proportionality theorem',
            'Criteria for similarity of triangles',
            'Areas of similar triangles',
            'Pythagoras theorem'
          ],
          learningOutcomes: [
            'Prove similarity of triangles',
            'Apply properties of similar triangles',
            'Use Pythagoras theorem in problem solving'
          ],
          estimatedHours: 15,
          month: 'September'
        },
        {
          chapterNumber: 10,
          chapterName: 'Circles',
          topics: [
            'Tangent to a circle from a point outside it',
            'Properties of tangents',
            'Number of tangents from a point on a circle'
          ],
          learningOutcomes: [
            'Construct tangents to a circle',
            'Apply properties of tangents in problem solving'
          ],
          estimatedHours: 10,
          month: 'October'
        },
        {
          chapterNumber: 11,
          chapterName: 'Constructions',
          topics: [
            'Division of a line segment in a given ratio',
            'Construction of triangles similar to given triangle',
            'Construction of tangents to a circle'
          ],
          learningOutcomes: [
            'Construct geometric figures using compass and ruler',
            'Apply construction techniques in problem solving'
          ],
          estimatedHours: 8,
          month: 'November'
        }
      ],
      totalHours: 33,
      weightage: 15,
      assessmentType: 'SA2'
    },
    {
      unitNumber: 5,
      unitName: 'Trigonometry',
      description: 'Introduction to Trigonometry and Applications',
      chapters: [
        {
          chapterNumber: 8,
          chapterName: 'Introduction to Trigonometry',
          topics: [
            'Trigonometric ratios of an acute angle',
            'Trigonometric ratios of specific angles',
            'Trigonometric identities',
            'Applications of trigonometry'
          ],
          learningOutcomes: [
            'Find trigonometric ratios of given angles',
            'Prove and apply trigonometric identities',
            'Solve problems using trigonometry'
          ],
          estimatedHours: 12,
          month: 'December'
        },
        {
          chapterNumber: 9,
          chapterName: 'Some Applications of Trigonometry',
          topics: [
            'Heights and distances',
            'Angle of elevation and depression',
            'Line of sight',
            'Applications in real life situations'
          ],
          learningOutcomes: [
            'Solve problems on heights and distances',
            'Apply trigonometry in practical situations'
          ],
          estimatedHours: 10,
          month: 'January'
        }
      ],
      totalHours: 22,
      weightage: 12,
      assessmentType: 'SA2'
    },
    {
      unitNumber: 6,
      unitName: 'Mensuration',
      description: 'Areas and Volumes',
      chapters: [
        {
          chapterNumber: 13,
          chapterName: 'Surface Areas and Volumes',
          topics: [
            'Surface areas and volumes of combinations of solids',
            'Conversion of solid from one shape to another',
            'Frustum of a cone'
          ],
          learningOutcomes: [
            'Calculate surface areas and volumes of complex solids',
            'Apply mensuration in real life problems'
          ],
          estimatedHours: 15,
          month: 'February'
        }
      ],
      totalHours: 15,
      weightage: 10,
      assessmentType: 'SA2'
    },
    {
      unitNumber: 7,
      unitName: 'Statistics and Probability',
      description: 'Statistical Analysis and Basic Probability',
      chapters: [
        {
          chapterNumber: 14,
          chapterName: 'Statistics',
          topics: [
            'Mean, median and mode of grouped data',
            'Cumulative frequency graph',
            'Graphical representation of statistical data'
          ],
          learningOutcomes: [
            'Calculate measures of central tendency for grouped data',
            'Interpret statistical graphs and charts'
          ],
          estimatedHours: 12,
          month: 'February'
        },
        {
          chapterNumber: 15,
          chapterName: 'Probability',
          topics: [
            'Classical definition of probability',
            'Simple problems on probability',
            'Theoretical and experimental probability'
          ],
          learningOutcomes: [
            'Calculate probability of simple events',
            'Distinguish between theoretical and experimental probability'
          ],
          estimatedHours: 10,
          month: 'March'
        }
      ],
      totalHours: 22,
      weightage: 11,
      assessmentType: 'SA2'
    }
  ],
  textbooks: [
    {
      title: 'Mathematics for Class X',
      author: 'R.D. Sharma',
      publisher: 'Dhanpat Rai Publications',
      isbn: '978-93-5004-207-1',
      isMain: true
    },
    {
      title: 'NCERT Mathematics Class 10',
      author: 'NCERT',
      publisher: 'National Council of Educational Research and Training',
      isbn: '978-81-7450-648-9',
      isMain: true
    }
  ],
  referenceBooks: [
    {
      title: 'Secondary School Mathematics for Class 10',
      author: 'M.L. Aggarwal',
      publisher: 'Avichal Publishing Company'
    },
    {
      title: 'Mathematics for Class 10',
      author: 'Lakhmir Singh & Manjit Kaur',
      publisher: 'S. Chand Publishing'
    }
  ],
  evaluationScheme: {
    internalAssessment: 20,
    terminalExam: 80,
    practicalExam: 0
  }
};

// Sample Class Data
const classesData = [
  {
    className: 'Class 1',
    section: 'A',
    board: 'CBSE',
    academicYear: '2024-25',
    students: [
      { name: 'Aarav Sharma', rollNumber: '1', admissionNumber: 'DPS2024001' },
      { name: 'Ishita Patel', rollNumber: '2', admissionNumber: 'DPS2024002' },
      { name: 'Arjun Kumar', rollNumber: '3', admissionNumber: 'DPS2024003' },
      { name: 'Priya Singh', rollNumber: '4', admissionNumber: 'DPS2024004' },
      { name: 'Rohan Gupta', rollNumber: '5', admissionNumber: 'DPS2024005' }
    ],
    totalStudents: 25
  },
  {
    className: 'Class 5',
    section: 'A',
    board: 'CBSE',
    academicYear: '2024-25',
    students: [
      { name: 'Anaya Verma', rollNumber: '1', admissionNumber: 'DPS2020001' },
      { name: 'Dhruv Malhotra', rollNumber: '2', admissionNumber: 'DPS2020002' },
      { name: 'Kavya Agarwal', rollNumber: '3', admissionNumber: 'DPS2020003' },
      { name: 'Neil Joshi', rollNumber: '4', admissionNumber: 'DPS2020004' },
      { name: 'Saanvi Bhatia', rollNumber: '5', admissionNumber: 'DPS2020005' }
    ],
    totalStudents: 30
  },
  {
    className: 'Class 10',
    section: 'A',
    board: 'CBSE',
    academicYear: '2024-25',
    students: [
      { name: 'Aditya Raj', rollNumber: '1', admissionNumber: 'DPS2015001' },
      { name: 'Shreya Kapoor', rollNumber: '2', admissionNumber: 'DPS2015002' },
      { name: 'Vihaan Sinha', rollNumber: '3', admissionNumber: 'DPS2015003' },
      { name: 'Myra Choudhary', rollNumber: '4', admissionNumber: 'DPS2015004' },
      { name: 'Kabir Aggarwal', rollNumber: '5', admissionNumber: 'DPS2015005' }
    ],
    totalStudents: 35
  },
  {
    className: 'Class 12',
    section: 'A',
    board: 'CBSE',
    academicYear: '2024-25',
    students: [
      { name: 'Aryan Mehta', rollNumber: '1', admissionNumber: 'DPS2013001' },
      { name: 'Diya Sharma', rollNumber: '2', admissionNumber: 'DPS2013002' },
      { name: 'Ayaan Khan', rollNumber: '3', admissionNumber: 'DPS2013003' },
      { name: 'Zara Patel', rollNumber: '4', admissionNumber: 'DPS2013004' },
      { name: 'Reyansh Gupta', rollNumber: '5', admissionNumber: 'DPS2013005' }
    ],
    totalStudents: 32
  }
];

// Time slots for different classes
const timeSlots = {
  primary: [ // Classes 1-5
    { periodNumber: 1, startTime: '08:00', endTime: '08:35' },
    { periodNumber: 2, startTime: '08:35', endTime: '09:10' },
    { periodNumber: 3, startTime: '09:10', endTime: '09:45' },
    { periodNumber: 4, startTime: '09:45', endTime: '10:20' },
    { periodNumber: 5, startTime: '10:35', endTime: '11:10' }, // After break
    { periodNumber: 6, startTime: '11:10', endTime: '11:45' },
    { periodNumber: 7, startTime: '11:45', endTime: '12:20' },
    { periodNumber: 8, startTime: '12:20', endTime: '12:55' }
  ],
  secondary: [ // Classes 6-12
    { periodNumber: 1, startTime: '08:00', endTime: '08:40' },
    { periodNumber: 2, startTime: '08:40', endTime: '09:20' },
    { periodNumber: 3, startTime: '09:20', endTime: '10:00' },
    { periodNumber: 4, startTime: '10:00', endTime: '10:40' },
    { periodNumber: 5, startTime: '10:55', endTime: '11:35' }, // After break
    { periodNumber: 6, startTime: '11:35', endTime: '12:15' },
    { periodNumber: 7, startTime: '12:15', endTime: '12:55' },
    { periodNumber: 8, startTime: '13:40', endTime: '14:20' } // After lunch
  ]
};

const connectDB = async () => {
  try {
    const mongoURI = process.env.MONGODB_URI || 'mongodb://localhost:27017/digiboard';
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
    
    console.log('👨‍🏫 Seeding teachers...');
    const teachers = await Teacher.insertMany(teachersData);
    console.log(`✅ Created ${teachers.length} teachers`);
    
    console.log('📚 Seeding subjects...');
    const allSubjects = [];
    
    // Create CBSE subjects
    for (const subjectData of subjectsData.CBSE) {
      const subjectClasses = subjectData.classes.map(className => ({
        className,
        isCompulsory: true,
        periodsPerWeek: subjectData.category === 'Core' ? 6 : subjectData.category === 'Language' ? 5 : 3,
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
    
    // Create ICSE subjects
    for (const subjectData of subjectsData.ICSE) {
      const subjectClasses = subjectData.classes.map(className => ({
        className,
        isCompulsory: true,
        periodsPerWeek: subjectData.category === 'Core' ? 6 : subjectData.category === 'Language' ? 5 : 3,
        duration: 40
      }));
      
      allSubjects.push({
        name: subjectData.name,
        code: `ICSE_${subjectData.code}`,
        board: 'ICSE',
        classes: subjectClasses,
        category: subjectData.category
      });
    }
    
    // Insert subjects one by one to handle duplicates
    const subjects = [];
    for (const subjectData of allSubjects) {
      try {
        const subject = await Subject.create(subjectData);
        subjects.push(subject);
      } catch (error) {
        if (error.code === 11000) {
          // Find existing subject
          const existingSubject = await Subject.findOne({
            code: subjectData.code,
            board: subjectData.board
          });
          if (existingSubject) {
            subjects.push(existingSubject);
          }
        } else {
          throw error;
        }
      }
    }
    
    console.log(`✅ Created/Found ${subjects.length} subjects`);
    
    console.log('🏫 Seeding classes...');
    const classes = [];
    for (const classData of classesData) {
      // Find appropriate class teacher
      const classTeacher = teachers.find(t => 
        t.subjects.some(subject => 
          subject.toLowerCase().includes('english') || 
          subject.toLowerCase().includes('mathematics')
        )
      ) || teachers[0];
      
      classes.push({
        ...classData,
        classTeacher: classTeacher._id
      });
    }
    
    const createdClasses = await Class.insertMany(classes);
    console.log(`✅ Created ${createdClasses.length} classes`);
    
    console.log('📖 Seeding syllabus...');
    // Create detailed syllabus for Class 10 Mathematics
    const mathSubject = subjects.find(s => 
      s.name === 'Mathematics' && 
      s.board === 'CBSE' && 
      s.classes.some(c => c.className === 'Class 10')
    );
    
    if (mathSubject) {
      class10MathSyllabus.subject = mathSubject._id;
      await Syllabus.create(class10MathSyllabus);
      console.log('✅ Created detailed Class 10 Mathematics syllabus');
    }
    
    // Create basic syllabus for other subjects
    const basicSyllabusEntries = [];
    for (const subject of subjects.slice(0, 10)) { // First 10 subjects
      for (const classInfo of subject.classes.slice(0, 2)) { // First 2 classes per subject
        basicSyllabusEntries.push({
          subject: subject._id,
          className: classInfo.className,
          board: subject.board,
          academicYear: '2024-25',
          term: 'Annual',
          units: [
            {
              unitNumber: 1,
              unitName: `Introduction to ${subject.name}`,
              chapters: [
                {
                  chapterNumber: 1,
                  chapterName: `Basics of ${subject.name}`,
                  topics: [`Fundamental concepts of ${subject.name}`, 'Basic terminology', 'Practical applications'],
                  learningOutcomes: [`Understand basic concepts of ${subject.name}`, 'Apply knowledge in practical situations'],
                  estimatedHours: 10,
                  month: 'April'
                }
              ],
              totalHours: 10,
              weightage: 25,
              assessmentType: 'SA1'
            }
          ],
          textbooks: [
            {
              title: `NCERT ${subject.name} ${classInfo.className}`,
              author: 'NCERT',
              publisher: 'National Council of Educational Research and Training',
              isMain: true
            }
          ],
          evaluationScheme: {
            internalAssessment: 20,
            terminalExam: 80,
            practicalExam: 0
          }
        });
      }
    }
    
    // Insert syllabus entries one by one to handle duplicates
    let createdSyllabusCount = 0;
    for (const syllabusData of basicSyllabusEntries) {
      try {
        await Syllabus.create(syllabusData);
        createdSyllabusCount++;
      } catch (error) {
        if (error.code === 11000) {
          // Duplicate entry, skip
          console.log(`Syllabus already exists for ${syllabusData.className} - ${syllabusData.subject}`);
        } else {
          throw error;
        }
      }
    }
    
    console.log(`✅ Created ${createdSyllabusCount} basic syllabus entries`);
    
    console.log('⏰ Seeding timetables...');
    const timetables = [];
    
    for (const classData of createdClasses) {
      const classSubjects = subjects.filter(s => 
        s.board === classData.board && 
        s.classes.some(c => c.className === classData.className)
      ).slice(0, 6); // Take first 6 subjects
      
      const weeklySchedule = [];
      const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
      
      const slots = classData.className.includes('Class 1') || 
                   classData.className.includes('Class 2') || 
                   classData.className.includes('Class 3') || 
                   classData.className.includes('Class 4') || 
                   classData.className.includes('Class 5') ? 
                   timeSlots.primary : timeSlots.secondary;
      
      for (const day of days) {
        const periods = [];
        
        for (let i = 0; i < 6; i++) { // 6 periods per day
          const slot = slots[i];
          const subject = classSubjects[i % classSubjects.length];
          const teacher = teachers.find(t => t.subjects.includes(subject.name)) || teachers[0];
          
          periods.push({
            periodNumber: slot.periodNumber,
            subject: subject._id,
            teacher: teacher._id,
            startTime: slot.startTime,
            endTime: slot.endTime,
            classroom: `Room ${100 + Math.floor(Math.random() * 50)}`,
            periodType: 'Regular'
          });
        }
        
        // Add break
        periods.push({
          periodNumber: 9,
          startTime: '10:20',
          endTime: '10:35',
          classroom: 'Playground',
          periodType: 'Break',
          isBreak: true
        });
        
        weeklySchedule.push({
          dayOfWeek: day,
          periods
        });
      }
      
      timetables.push({
        class: classData._id,
        academicYear: '2024-25',
        effectiveFrom: new Date('2024-04-01'),
        effectiveTo: new Date('2025-03-31'),
        weeklySchedule,
        breakTimings: [
          {
            name: 'Morning Break',
            startTime: '10:20',
            endTime: '10:35',
            duration: 15
          },
          {
            name: 'Lunch Break',
            startTime: '12:55',
            endTime: '13:40',
            duration: 45
          }
        ]
      });
    }
    
    // Insert timetables one by one to handle duplicates
    let createdTimetableCount = 0;
    for (const timetableData of timetables) {
      try {
        await Timetable.create(timetableData);
        createdTimetableCount++;
      } catch (error) {
        if (error.code === 11000) {
          console.log(`Timetable already exists for class ${timetableData.class}`);
        } else {
          throw error;
        }
      }
    }
    
    console.log(`✅ Created ${createdTimetableCount} timetables`);
    
    console.log('🎓 Seeding current lectures...');
    const currentLectures = [];
    const today = new Date();
    const tomorrow = new Date(today);
    tomorrow.setDate(today.getDate() + 1);
    
    // Create lectures for today and tomorrow
    const activeTimetables = await Timetable.find({}).populate('class').limit(2);
    
    for (const timetable of activeTimetables) {
      if (!timetable.class) continue;
      
      const dayName = today.toLocaleDateString('en-US', { weekday: 'long' });
      const daySchedule = timetable.weeklySchedule.find(d => d.dayOfWeek === dayName);
      
      if (daySchedule) {
        for (const period of daySchedule.periods.slice(0, 3)) { // First 3 periods
          if (!period.isBreak) {
            const [startHour, startMinute] = period.startTime.split(':');
            const [endHour, endMinute] = period.endTime.split(':');
            
            const startTime = new Date(today);
            startTime.setHours(parseInt(startHour), parseInt(startMinute), 0, 0);
            
            const endTime = new Date(today);
            endTime.setHours(parseInt(endHour), parseInt(endMinute), 0, 0);
            
            currentLectures.push({
              subject: period.subject,
              teacher: period.teacher,
              classroom: period.classroom,
              startTime,
              endTime,
              dayOfWeek: dayName,
              lectureType: 'Lecture',
              semester: 'First',
              course: timetable.class.className,
              chapter: 'Current Chapter',
              description: `${dayName} lecture for ${timetable.class.className}`
            });
          }
        }
      }
    }
    
    let createdLectureCount = 0;
    for (const lectureData of currentLectures) {
      try {
        await Lecture.create(lectureData);
        createdLectureCount++;
      } catch (error) {
        console.log(`Lecture creation error (continuing): ${error.message}`);
      }
    }
    
    console.log(`✅ Created ${createdLectureCount} current lectures`);
    
    console.log('\n🎉 Database seeding completed successfully!');
    console.log('\n📊 Summary:');
    console.log(`👨‍🏫 Teachers: ${teachers.length}`);
    console.log(`📚 Subjects: ${subjects.length}`);
    console.log(`🏫 Classes: ${createdClasses.length}`);
    console.log(`📖 Syllabus: ${basicSyllabusEntries.length + 1}`);
    console.log(`⏰ Timetables: ${timetables.length}`);
    console.log(`🎓 Lectures: ${currentLectures.length}`);
    
  } catch (error) {
    console.error('❌ Error seeding database:', error);
  } finally {
    await mongoose.connection.close();
    console.log('\n✅ Database connection closed');
  }
};

// Run the seeding script
if (require.main === module) {
  seedDatabase();
}

module.exports = { seedDatabase };
