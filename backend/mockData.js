// Mock data for offline development
const mockTeachers = [
  {
    _id: '1',
    name: 'Dr. Sarah Johnson',
    email: 'sarah.johnson@digiboard.edu',
    phone: '+1 (555) 123-4567',
    department: 'Computer Science',
    specialization: 'Artificial Intelligence',
    photo: 'https://i.pravatar.cc/150?img=1',
    officeHours: 'Mon-Wed 2-4 PM',
    bio: 'PhD in AI from MIT, 15 years teaching experience'
  },
  {
    _id: '2',
    name: 'Prof. Michael Chen',
    email: 'michael.chen@digiboard.edu',
    phone: '+1 (555) 234-5678',
    department: 'Mathematics',
    specialization: 'Calculus & Linear Algebra',
    photo: 'https://i.pravatar.cc/150?img=2',
    officeHours: 'Tue-Thu 3-5 PM',
    bio: 'Mathematics education specialist with 20 years experience'
  },
  {
    _id: '3',
    name: 'Dr. Emily Rodriguez',
    email: 'emily.rodriguez@digiboard.edu',
    phone: '+1 (555) 345-6789',
    department: 'Physics',
    specialization: 'Quantum Mechanics',
    photo: 'https://i.pravatar.cc/150?img=3',
    officeHours: 'Mon-Fri 1-3 PM',
    bio: 'Quantum physics researcher and educator'
  }
];

const mockLectures = [
  {
    _id: '101',
    subject: 'Introduction to AI',
    teacher: mockTeachers[0],
    dayOfWeek: 'Monday',
    startTime: '09:00',
    endTime: '10:30',
    room: 'CS-101',
    semester: 'Fall 2025',
    credits: 3
  },
  {
    _id: '102',
    subject: 'Machine Learning Basics',
    teacher: mockTeachers[0],
    dayOfWeek: 'Wednesday',
    startTime: '14:00',
    endTime: '15:30',
    room: 'CS-102',
    semester: 'Fall 2025',
    credits: 3
  },
  {
    _id: '103',
    subject: 'Calculus I',
    teacher: mockTeachers[1],
    dayOfWeek: 'Tuesday',
    startTime: '10:00',
    endTime: '11:30',
    room: 'MATH-201',
    semester: 'Fall 2025',
    credits: 4
  },
  {
    _id: '104',
    subject: 'Linear Algebra',
    teacher: mockTeachers[1],
    dayOfWeek: 'Thursday',
    startTime: '13:00',
    endTime: '14:30',
    room: 'MATH-202',
    semester: 'Fall 2025',
    credits: 3
  },
  {
    _id: '105',
    subject: 'Quantum Physics',
    teacher: mockTeachers[2],
    dayOfWeek: 'Friday',
    startTime: '11:00',
    endTime: '12:30',
    room: 'PHY-301',
    semester: 'Fall 2025',
    credits: 4
  }
];

// Helper function to get current day and time
function getCurrentDayAndTime() {
  const now = new Date();
  const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  const currentDay = days[now.getDay()];
  const currentTime = now.toTimeString().slice(0, 5); // HH:MM format
  return { currentDay, currentTime };
}

// Get next lecture
function getNextLecture() {
  const { currentDay, currentTime } = getCurrentDayAndTime();
  const dayOrder = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  const currentDayIndex = dayOrder.indexOf(currentDay);
  
  // Find next lecture today
  const todayLectures = mockLectures
    .filter(l => l.dayOfWeek === currentDay && l.startTime > currentTime)
    .sort((a, b) => a.startTime.localeCompare(b.startTime));
  
  if (todayLectures.length > 0) {
    return todayLectures[0];
  }
  
  // Find next lecture in upcoming days
  for (let i = 1; i <= 7; i++) {
    const nextDayIndex = (currentDayIndex + i) % 7;
    const nextDay = dayOrder[nextDayIndex];
    const nextDayLectures = mockLectures
      .filter(l => l.dayOfWeek === nextDay)
      .sort((a, b) => a.startTime.localeCompare(b.startTime));
    
    if (nextDayLectures.length > 0) {
      return nextDayLectures[0];
    }
  }
  
  // If no future lectures, return first lecture
  return mockLectures[0];
}

// Get today's lectures
function getTodayLectures() {
  const { currentDay } = getCurrentDayAndTime();
  return mockLectures
    .filter(l => l.dayOfWeek === currentDay)
    .sort((a, b) => a.startTime.localeCompare(b.startTime));
}

// Get weekly schedule
function getWeeklySchedule() {
  const schedule = {};
  const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
  
  days.forEach(day => {
    schedule[day] = mockLectures
      .filter(l => l.dayOfWeek === day)
      .sort((a, b) => a.startTime.localeCompare(b.startTime));
  });
  
  return schedule;
}

module.exports = {
  mockTeachers,
  mockLectures,
  getNextLecture,
  getTodayLectures,
  getWeeklySchedule
};
