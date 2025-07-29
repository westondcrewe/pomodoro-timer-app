const mongoose = require('mongoose');

const pomodoroSessionSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  startTime: {
    type: Date,
    required: true
  },
  endTime: {
    type: Date
  },
  duration: {
    type: Number, // in seconds
    required: true
  },
  mode: {
    type: String,
    enum: ['work', 'break', 'longBreak'],
    required: true
  },
  completed: {
    type: Boolean,
    default: false
  },
  rounds: {
    type: Number,
    default: 0
  },
  notes: {
    type: String,
    trim: true,
    maxlength: 500
  }
}, {
  timestamps: true
});

// Index for efficient queries
pomodoroSessionSchema.index({ userId: 1, startTime: -1 });
pomodoroSessionSchema.index({ startTime: -1 });

module.exports = mongoose.model('PomodoroSession', pomodoroSessionSchema);