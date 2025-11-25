const mongoose = require('mongoose');
const Lecture = require('./models/Lecture');
require('dotenv').config();

const addSaturdayLectures = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('Connected to MongoDB');

    // Get existing Monday lectures to duplicate for Saturday
    const mondayLectures = await Lecture.find({ dayOfWeek: 'Monday', isActive: true });
    
    if (mondayLectures.length === 0) {
      console.log('No Monday lectures found to copy');
      process.exit(1);
    }

    // Create Saturday lectures
    const saturdayLectures = mondayLectures.map(lecture => ({
      ...lecture.toObject(),
      _id: undefined, // Let MongoDB generate new ID
      dayOfWeek: 'Saturday'
    }));

    // Insert Saturday lectures
    const result = await Lecture.insertMany(saturdayLectures);
    console.log(`✅ Added ${result.length} Saturday lectures`);

    // Verify
    const count = await Lecture.countDocuments({ dayOfWeek: 'Saturday', isActive: true });
    console.log(`Total Saturday lectures in DB: ${count}`);

    await mongoose.connection.close();
  } catch (error) {
    console.error('Error adding Saturday lectures:', error);
    process.exit(1);
  }
};

addSaturdayLectures();
