const mongoose = require('mongoose');
const Settings = require('./models/Settings');
require('dotenv').config();

const showLocation = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('Connected to MongoDB');

    const setting = await Settings.findOne({ key: 'school_location' });
    if (setting) {
      console.log('\n--- School Location in DB ---');
      console.log('Key:', setting.key);
      console.log('Value:', JSON.stringify(setting.value, null, 2));
      console.log('Description:', setting.description);
      console.log('-----------------------------\n');
    } else {
      console.log('No school location found in DB.');
    }

    await mongoose.disconnect();
  } catch (err) {
    console.error('Error:', err);
  }
};

showLocation();
