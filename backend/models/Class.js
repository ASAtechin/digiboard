const mongoose = require('mongoose');

const classSchema = new mongoose.Schema({
  className: {
    type: String,
    required: true,
    trim: true,
    // e.g., "Class 1", "Class 2", ..., "Class 12"
  },
  section: {
    type: String,
    required: true,
    trim: true,
    // e.g., "A", "B", "C"
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
  classTeacher: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Teacher',
    required: true
  },
  students: [{
    name: { type: String, required: true },
    rollNumber: { type: String, required: true },
    admissionNumber: { type: String, required: true }
  }],
  totalStudents: {
    type: Number,
    default: 0
  },
  isActive: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true
});

// Compound index for unique class-section combination
classSchema.index({ className: 1, section: 1, academicYear: 1 }, { unique: true });

module.exports = mongoose.model('Class', classSchema);
