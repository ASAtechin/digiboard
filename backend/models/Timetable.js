const mongoose = require('mongoose');

const timetableSchema = new mongoose.Schema({
  class: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Class',
    required: true
  },
  academicYear: {
    type: String,
    required: true,
    // e.g., "2024-25"
  },
  effectiveFrom: {
    type: Date,
    required: true,
    default: Date.now
  },
  effectiveTo: {
    type: Date,
    required: true
  },
  weeklySchedule: [{
    dayOfWeek: {
      type: String,
      required: true,
      enum: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
    },
    periods: [{
      periodNumber: { type: Number, required: true },
      subject: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Subject',
        required: function() { return !this.isBreak; }
      },
      teacher: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Teacher',
        required: function() { return !this.isBreak; }
      },
      startTime: { type: String, required: true }, // "09:00"
      endTime: { type: String, required: true },   // "09:40"
      classroom: { type: String, required: true },
      periodType: {
        type: String,
        enum: ['Regular', 'Lab', 'Library', 'Assembly', 'Break', 'Lunch', 'Games', 'Activity'],
        default: 'Regular'
      },
      isBreak: { type: Boolean, default: false }
    }]
  }],
  specialSchedules: [{
    date: { type: Date, required: true },
    reason: { type: String, required: true }, // "Holiday", "Exam", "Event"
    description: { type: String },
    modifiedPeriods: [{
      periodNumber: { type: Number, required: true },
      subject: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Subject'
      },
      teacher: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Teacher'
      },
      startTime: { type: String },
      endTime: { type: String },
      classroom: { type: String },
      isCancelled: { type: Boolean, default: false }
    }]
  }],
  breakTimings: [{
    name: { type: String, required: true }, // "Morning Break", "Lunch Break"
    startTime: { type: String, required: true },
    endTime: { type: String, required: true },
    duration: { type: Number, required: true } // minutes
  }],
  isActive: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true
});

// Compound index for unique timetable per class-year
timetableSchema.index({ class: 1, academicYear: 1, effectiveFrom: 1 }, { unique: true });

module.exports = mongoose.model('Timetable', timetableSchema);
