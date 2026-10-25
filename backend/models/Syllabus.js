const mongoose = require('mongoose');

const syllabusSchema = new mongoose.Schema({
  subject: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Subject',
    required: true
  },
  className: {
    type: String,
    required: true,
    trim: true
  },
  board: {
    type: String,
    required: true,
    enum: ['CBSE', 'ICSE', 'State Board'],
    default: 'CBSE'
  },
  academicYear: {
    type: String,
    required: true,
    // e.g., "2024-25"
  },
  term: {
    type: String,
    enum: ['Term 1', 'Term 2', 'Annual'],
    default: 'Annual'
  },
  units: [{
    unitNumber: { type: Number, required: true },
    unitName: { type: String, required: true },
    description: { type: String },
    chapters: [{
      chapterNumber: { type: Number, required: true },
      chapterName: { type: String, required: true },
      topics: [{ type: String }],
      learningOutcomes: [{ type: String }],
      estimatedHours: { type: Number, default: 10 },
      month: { 
        type: String,
        enum: ['April', 'May', 'June', 'July', 'August', 'September', 
               'October', 'November', 'December', 'January', 'February', 'March']
      }
    }],
    totalHours: { type: Number, default: 0 },
    weightage: { type: Number, default: 0 }, // percentage in exam
    assessmentType: {
      type: String,
      enum: ['FA1', 'FA2', 'SA1', 'SA2', 'Project', 'Practical'],
      default: 'SA1'
    }
  }],
  practicalWork: [{
    experimentName: { type: String, required: true },
    objectives: [{ type: String }],
    materials: [{ type: String }],
    procedure: { type: String },
    month: { 
      type: String,
      enum: ['April', 'May', 'June', 'July', 'August', 'September', 
             'October', 'November', 'December', 'January', 'February', 'March']
    }
  }],
  textbooks: [{
    title: { type: String, required: true },
    author: { type: String, required: true },
    publisher: { type: String, required: true },
    isbn: { type: String },
    isMain: { type: Boolean, default: false }
  }],
  referenceBooks: [{
    title: { type: String, required: true },
    author: { type: String, required: true },
    publisher: { type: String, required: true }
  }],
  evaluationScheme: {
    internalAssessment: { type: Number, default: 20 }, // percentage
    terminalExam: { type: Number, default: 80 }, // percentage
    practicalExam: { type: Number, default: 0 } // percentage
  },
  isActive: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true
});

// Compound index for unique syllabus per subject-class-year
syllabusSchema.index({ subject: 1, className: 1, academicYear: 1, term: 1 }, { unique: true });

module.exports = mongoose.model('Syllabus', syllabusSchema);
