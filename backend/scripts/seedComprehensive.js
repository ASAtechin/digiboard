const mongoose = require('mongoose');
const Class = require('../models/Class');
const Subject = require('../models/Subject');
const Syllabus = require('../models/Syllabus');
const Teacher = require('../models/Teacher');
const Lecture = require('../models/Lecture');
const Timetable = require('../models/Timetable');
require('dotenv').config();

const BOARDS = ['CBSE', 'ICSE', 'State Board'];
const SECTIONS = ['A', 'B', 'C', 'D'];
const CLASSES = Array.from({ length: 12 }, (_, i) => i + 1); // 1 to 12

const SUBJECTS_DATA = {
    primary: [ // 1-5
        { name: 'English', code: 'ENG' },
        { name: 'Hindi', code: 'HIN' },
        { name: 'Mathematics', code: 'MATH' },
        { name: 'EVS', code: 'EVS' },
        { name: 'Computer Science', code: 'CS' }
    ],
    middle: [ // 6-8
        { name: 'English', code: 'ENG' },
        { name: 'Hindi', code: 'HIN' },
        { name: 'Mathematics', code: 'MATH' },
        { name: 'Science', code: 'SCI' },
        { name: 'Social Science', code: 'SST' },
        { name: 'Sanskrit', code: 'SKT' }
    ],
    secondary: [ // 9-10
        { name: 'English', code: 'ENG' },
        { name: 'Hindi', code: 'HIN' },
        { name: 'Mathematics', code: 'MATH' },
        { name: 'Science', code: 'SCI' },
        { name: 'Social Science', code: 'SST' }
    ],
    senior_science: [ // 11-12
        { name: 'English Core', code: 'ENG' },
        { name: 'Physics', code: 'PHY' },
        { name: 'Chemistry', code: 'CHEM' },
        { name: 'Mathematics', code: 'MATH' },
        { name: 'Computer Science', code: 'CS' }
    ],
    senior_commerce: [ // 11-12
        { name: 'English Core', code: 'ENG' },
        { name: 'Accountancy', code: 'ACC' },
        { name: 'Business Studies', code: 'BST' },
        { name: 'Economics', code: 'ECO' },
        { name: 'Mathematics', code: 'MATH' }
    ]
};

const CHAPTERS_POOL = {
    'Mathematics': ['Real Numbers', 'Polynomials', 'Linear Equations', 'Quadratic Equations', 'AP', 'Triangles', 'Coordinate Geometry', 'Trigonometry', 'Circles', 'Constructions', 'Area Related to Circles', 'Surface Areas and Volumes', 'Statistics', 'Probability'],
    'Science': ['Chemical Reactions', 'Acids Bases Salts', 'Metals Non-Metals', 'Carbon Compounds', 'Periodic Classification', 'Life Processes', 'Control Coordination', 'Reproduction', 'Heredity Evolution', 'Light Reflection Refraction', 'Human Eye', 'Electricity', 'Magnetic Effects', 'Sources of Energy', 'Our Environment'],
    'English': ['A Letter to God', 'Nelson Mandela', 'Two Stories about Flying', 'From the Diary of Anne Frank', 'The Hundred Dresses', 'Glimpses of India', 'Mijbil the Otter', 'Madam Rides the Bus', 'The Sermon at Benares', 'The Proposal'],
    'Social Science': ['Rise of Nationalism in Europe', 'Nationalism in India', 'Making of Global World', 'Age of Industrialisation', 'Print Culture', 'Resources and Development', 'Forest and Wildlife', 'Water Resources', 'Agriculture', 'Minerals and Energy'],
    'Hindi': ['Pad', 'Ram-Lakshman-Parshuram Samvad', 'Savaiya', 'Aatmkathya', 'Utsah', 'Att Nahi Rahi Hai', 'Yah Danturit Muskan', 'Chaya Mat Chuna', 'Kanyadan', 'Sangatkar'],
    'EVS': ['Super Senses', 'A Snake Charmers Story', 'From Tasting to Digesting', 'Mangoes Round the Year', 'Seeds and Seeds', 'Every Drop Counts', 'Experiments with Water', 'A Treat for Mosquitoes', 'Up You Go', 'Walls Tell Stories'],
    'Physics': ['Electric Charges and Fields', 'Electrostatic Potential', 'Current Electricity', 'Moving Charges and Magnetism', 'Magnetism and Matter', 'EMI', 'Alternating Current', 'EM Waves', 'Ray Optics', 'Wave Optics'],
    'Chemistry': ['Solid State', 'Solutions', 'Electrochemistry', 'Chemical Kinetics', 'Surface Chemistry', 'Isolation of Elements', 'p-Block Elements', 'd and f Block Elements', 'Coordination Compounds', 'Haloalkanes'],
    'Biology': ['Reproduction in Organisms', 'Sexual Reproduction', 'Human Reproduction', 'Reproductive Health', 'Inheritance and Variation', 'Molecular Basis of Inheritance', 'Evolution', 'Human Health and Disease'],
    'Accountancy': ['NPO', 'Partnership', 'Admission of Partner', 'Retirement of Partner', 'Dissolution', 'Share Capital', 'Debentures', 'Financial Statements', 'Ratio Analysis', 'Cash Flow'],
    'Business Studies': ['Nature and Significance of Management', 'Principles of Management', 'Business Environment', 'Planning', 'Organising', 'Staffing', 'Directing', 'Controlling', 'Financial Management'],
    'Economics': ['National Income', 'Money and Banking', 'Determination of Income', 'Government Budget', 'Balance of Payments', 'Indian Economy on Eve of Independence', 'Indian Economy 1950-1990']
};

const FIRST_NAMES = ['Aarav', 'Vihaan', 'Aditya', 'Sai', 'Arjun', 'Reyansh', 'Muhammad', 'Avyaan', 'Vivaan', 'Aryan', 'Anaya', 'Myra', 'Sara', 'Ira', 'Diya', 'Ahana', 'Riya', 'Anvi', 'Pari', 'Saanvi'];
const LAST_NAMES = ['Sharma', 'Verma', 'Gupta', 'Malhotra', 'Singh', 'Kumar', 'Patel', 'Mehta', 'Joshi', 'Agarwal', 'Reddy', 'Nair', 'Khan', 'Shah', 'Chopra', 'Jain', 'Bhatia', 'Saxena'];

function getRandomElement(arr) {
    return arr[Math.floor(Math.random() * arr.length)];
}

function generateName() {
    return `${getRandomElement(FIRST_NAMES)} ${getRandomElement(LAST_NAMES)}`;
}

function generateStudents(count, year) {
    const students = [];
    for (let i = 1; i <= count; i++) {
        students.push({
            name: generateName(),
            rollNumber: i.toString(),
            admissionNumber: `ADM${year}${i.toString().padStart(3, '0')}`
        });
    }
    return students;
}

const connectDB = async () => {
    try {
        await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/digiboard');
        console.log('MongoDB Connected');
    } catch (err) {
        console.error('MongoDB Connection Error:', err);
        process.exit(1);
    }
};

const seed = async () => {
    await connectDB();

    console.log('🧹 Clearing existing data...');
    // Drop collections to reset indexes
    await mongoose.connection.db.dropCollection('classes').catch(() => { });
    await mongoose.connection.db.dropCollection('subjects').catch(() => { });
    await mongoose.connection.db.dropCollection('syllabuses').catch(() => { });
    await mongoose.connection.db.dropCollection('teachers').catch(() => { });
    await mongoose.connection.db.dropCollection('lectures').catch(() => { });
    await mongoose.connection.db.dropCollection('timetables').catch(() => { });

    console.log('👩‍🏫 Creating Teachers...');
    const teachers = [];
    for (let i = 0; i < 50; i++) {
        teachers.push(await Teacher.create({
            name: generateName(),
            email: `teacher${i + 1}@school.com`,
            phone: `98765432${i.toString().padStart(2, '0')}`,
            subjects: ['Mathematics', 'Science', 'English'], // Simplified
            department: 'Science',
            qualifications: ['B.Ed', 'M.Sc'],
            experience: Math.floor(Math.random() * 15) + 1
        }));
    }

    console.log('🏫 Creating Classes, Subjects, and Syllabus...');

    for (const board of BOARDS) {
        console.log(`  Processing Board: ${board}`);

        for (const classNum of CLASSES) {
            // Determine subjects based on class level
            let subjectsList = [];
            if (classNum <= 5) subjectsList = SUBJECTS_DATA.primary;
            else if (classNum <= 8) subjectsList = SUBJECTS_DATA.middle;
            else if (classNum <= 10) subjectsList = SUBJECTS_DATA.secondary;
            else subjectsList = [...SUBJECTS_DATA.senior_science, ...SUBJECTS_DATA.senior_commerce]; // Simplified merging

            // Create Subjects for this class/board (Unique per board/code)
            const createdSubjects = [];
            for (const sub of subjectsList) {
                // Check if subject already exists for this board to avoid duplicates
                let subject = await Subject.findOne({ code: sub.code, board });
                if (!subject) {
                    subject = await Subject.create({
                        name: sub.name,
                        code: sub.code,
                        board: board,
                        classes: [{ className: `Class ${classNum}`, isCompulsory: true }],
                        category: 'Core'
                    });
                } else {
                    // Add class to existing subject if not present
                    if (!subject.classes.some(c => c.className === `Class ${classNum}`)) {
                        subject.classes.push({ className: `Class ${classNum}`, isCompulsory: true });
                        await subject.save();
                    }
                }
                createdSubjects.push(subject);

                // Create Syllabus for this subject/class/board
                const chapters = CHAPTERS_POOL[sub.name] || CHAPTERS_POOL['Science'] || []; // Fallback
                const units = [{
                    unitNumber: 1,
                    unitName: 'Term 1 Syllabus',
                    chapters: chapters.slice(0, 5).map((chap, idx) => ({
                        chapterNumber: idx + 1,
                        chapterName: chap,
                        estimatedHours: 8,
                        month: 'April'
                    }))
                }];

                // Check if syllabus exists
                const existingSyllabus = await Syllabus.findOne({
                    subject: subject._id,
                    className: `Class ${classNum}`,
                    board,
                    academicYear: '2024-25'
                });

                if (!existingSyllabus) {
                    await Syllabus.create({
                        subject: subject._id,
                        className: `Class ${classNum}`,
                        board,
                        academicYear: '2024-25',
                        units
                    });
                }
            }

            // Create Sections
            for (const section of SECTIONS) {
                const classTeacher = getRandomElement(teachers);
                const students = generateStudents(30 + Math.floor(Math.random() * 10), 2024); // 30-40 students

                await Class.create({
                    className: `Class ${classNum}`,
                    section,
                    board,
                    academicYear: '2024-25',
                    classTeacher: classTeacher._id,
                    students,
                    totalStudents: students.length
                });
            }
        }
    }

    console.log('✅ Seeding Complete!');
    process.exit(0);
};

seed();
