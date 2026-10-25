const mongoose = require('mongoose');
const Teacher = require('../models/Teacher');
const Subject = require('../models/Subject');
const Class = require('../models/Class');
const Lecture = require('../models/Lecture');
require('dotenv').config();

const verify = async () => {
    try {
        const mongoURI = process.env.MONGODB_URI || 'mongodb://localhost:27017/digiboard';
        await mongoose.connect(mongoURI);

        console.log('--- Verification Report ---');

        // Check Classes and Students
        const classes = await Class.find({});
        console.log(`Total Classes: ${classes.length}`);
        const totalStudents = classes.reduce((sum, c) => sum + c.students.length, 0);
        console.log(`Total Students: ${totalStudents}`);
        console.log(`Average Students per Class: ${(totalStudents / classes.length).toFixed(2)}`);

        // Sample Class
        const sampleClass = classes[0];
        console.log(`Sample Class (${sampleClass.className}-${sampleClass.section}): ${sampleClass.students.length} students`);
        console.log(`Sample Student: ${JSON.stringify(sampleClass.students[0])}`);

        // Check Lectures
        const lectures = await Lecture.find({});
        console.log(`Total Lectures: ${lectures.length}`);

        // Distribution by Day
        const dayCounts = {};
        lectures.forEach(l => {
            dayCounts[l.dayOfWeek] = (dayCounts[l.dayOfWeek] || 0) + 1;
        });
        console.log('Lectures per Day:', dayCounts);

    } catch (error) {
        console.error(error);
    } finally {
        await mongoose.connection.close();
    }
};

verify();
