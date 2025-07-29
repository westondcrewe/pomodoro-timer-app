const mongoose = require('mongoose');

const userStatsSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    unique: true
  },
  totalWorkSessions: {
    type: Number,
    default: 0
  },
  totalWorkTime: {
    type: Number, // in seconds
    default: 0
  },
  totalBreakTime: {
    type: Number, // in seconds
    default: 0
  },
  totalLongBreakTime: {
    type: Number, // in seconds
    default: 0
  },
  totalRounds: {
    type: Number,
    default: 0
  },
  averageSessionLength: {
    type: Number, // in seconds
    default: 0
  },
  longestStreak: {
    type: Number, // consecutive days
    default: 0
  },
  currentStreak: {
    type: Number,
    default: 0
  },
  lastActiveDate: {
    type: Date
  },
  weeklyStats: [{
    week: String, // "YYYY-WW" format
    workSessions: Number,
    workTime: Number,
    breakTime: Number
  }],
  monthlyStats: [{
    month: String, // "YYYY-MM" format
    workSessions: Number,
    workTime: Number,
    breakTime: Number
  }]
}, {
  timestamps: true
});

module.exports = mongoose.model('UserStats', userStatsSchema);