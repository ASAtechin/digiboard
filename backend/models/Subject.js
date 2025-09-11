const mongoose = require('mongoose');

const subjectSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true,
    // e.g., "Mathematics", "English", "Science", "Hindi"
  },
  code: {
    type: String,
    required: true,
    trim: true,
    uppercase: true,
    // e.g., "MATH", "ENG", "SCI", "HIN"
  },
  board: {
    type: String,
    required: true,
    enum: ['CBSE', 'ICSE', 'State Board'],
    default: 'CBSE'
  },
  classes: [{
    className: { type: String, required: true },
    isCompulsory: { type: Boolean, default: true },
    periodsPerWeek: { type: Number, default: 5 },
    duration: { type: Number, default: 40 } // minutes
  }],
  category: {
    type: String,
    enum: ['Core', 'Language', 'Elective', 'Activity', 'Skill'],
    default: 'Core'
  },
  description: {
    type: String,
    trim: true
  },
  isActive: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true
});

// Compound index for unique subject-board combination
subjectSchema.index({ code: 1, board: 1 }, { unique: true });

module.exports = mongoose.model('Subject', subjectSchema);
