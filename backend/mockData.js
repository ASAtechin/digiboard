const mockTeachers = [
  { id: '1', name: 'Dr. Smith', department: 'Computer Science', email: 'smith@example.com' },
  { id: '2', name: 'Prof. Johnson', department: 'Mathematics', email: 'johnson@example.com' },
  { id: '3', name: 'Ms. Davis', department: 'Physics', email: 'davis@example.com' }
];

const mockLectures = [
  {
    id: '101',
    subject: 'Data Structures',
    teacher: mockTeachers[0],
    classroom: 'CS-101',
    startTime: new Date(new Date().setHours(9, 0, 0, 0)),
    endTime: new Date(new Date().setHours(10, 30, 0, 0)),
    lectureType: 'Theory',
    description: 'Introduction to Trees and Graphs'
  },
  {
    id: '102',
    subject: 'Calculus II',
    teacher: mockTeachers[1],
    classroom: 'MATH-202',
    startTime: new Date(new Date().setHours(11, 0, 0, 0)),
    endTime: new Date(new Date().setHours(12, 30, 0, 0)),
    lectureType: 'Theory',
    description: 'Integration Techniques'
  },
  {
    id: '103',
    subject: 'Physics Lab',
    teacher: mockTeachers[2],
    classroom: 'PHY-LAB',
    startTime: new Date(new Date().setHours(14, 0, 0, 0)),
    endTime: new Date(new Date().setHours(16, 0, 0, 0)),
    lectureType: 'Lab',
    description: 'Optics Experiments'
  }
];

const getNextLecture = () => {
  const now = new Date();
  return mockLectures.find(l => l.startTime > now) || null;
};

const getTodayLectures = () => {
  return mockLectures;
};

const getWeeklySchedule = () => {
  return {
    Monday: mockLectures,
    Tuesday: mockLectures,
    Wednesday: mockLectures,
    Thursday: mockLectures,
    Friday: mockLectures
  };
};

module.exports = {
  mockTeachers,
  mockLectures,
  getNextLecture,
  getTodayLectures,
  getWeeklySchedule
};
