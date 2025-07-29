const express = require('express');
const auth = require('../middleware/auth');
const UserStats = require('../models/UserStats');
const PomodoroSession = require('../models/PomodoroSession');
const router = express.Router();

// @route   GET /api/stats
// @desc    Get user's overall statistics
// @access  Private
router.get('/', auth, async (req, res) => {
  try {
    let userStats = await UserStats.findOne({ userId: req.user._id });
    
    if (!userStats) {
      userStats = new UserStats({ userId: req.user._id });
      await userStats.save();
    }

    res.json(userStats);

  } catch (error) {
    console.error('Get stats error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// @route   GET /api/stats/daily
// @desc    Get daily statistics for the last 7 days
// @access  Private
router.get('/daily', auth, async (req, res) => {
  try {
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

    const dailyStats = await PomodoroSession.aggregate([
      {
        $match: {
          userId: req.user._id,
          startTime: { $gte: sevenDaysAgo },
          completed: true
        }
      },
      {
        $group: {
          _id: {
            $dateToString: { format: "%Y-%m-%d", date: "$startTime" }
          },
          workSessions: {
            $sum: { $cond: [{ $eq: ["$mode", "work"] }, 1, 0] }
          },
          workTime: {
            $sum: { $cond: [{ $eq: ["$mode", "work"] }, "$duration", 0] }
          },
          breakTime: {
            $sum: { $cond: [{ $in: ["$mode", ["break", "longBreak"]] }, "$duration", 0] }
          },
          totalSessions: { $sum: 1 }
        }
      },
      {
        $sort: { _id: 1 }
      }
    ]);

    res.json(dailyStats);

  } catch (error) {
    console.error('Get daily stats error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// @route   GET /api/stats/weekly
// @desc    Get weekly statistics for the last 4 weeks
// @access  Private
router.get('/weekly', auth, async (req, res) => {
  try {
    const fourWeeksAgo = new Date();
    fourWeeksAgo.setDate(fourWeeksAgo.getDate() - 28);

    const weeklyStats = await PomodoroSession.aggregate([
      {
        $match: {
          userId: req.user._id,
          startTime: { $gte: fourWeeksAgo },
          completed: true
        }
      },
      {
        $group: {
          _id: {
            $dateToString: { format: "%Y-W%V", date: "$startTime" }
          },
          workSessions: {
            $sum: { $cond: [{ $eq: ["$mode", "work"] }, 1, 0] }
          },
          workTime: {
            $sum: { $cond: [{ $eq: ["$mode", "work"] }, "$duration", 0] }
          },
          breakTime: {
            $sum: { $cond: [{ $in: ["$mode", ["break", "longBreak"]] }, "$duration", 0] }
          },
          totalSessions: { $sum: 1 }
        }
      },
      {
        $sort: { _id: 1 }
      }
    ]);

    res.json(weeklyStats);

  } catch (error) {
    console.error('Get weekly stats error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// @route   GET /api/stats/monthly
// @desc    Get monthly statistics for the last 12 months
// @access  Private
router.get('/monthly', auth, async (req, res) => {
  try {
    const twelveMonthsAgo = new Date();
    twelveMonthsAgo.setMonth(twelveMonthsAgo.getMonth() - 12);

    const monthlyStats = await PomodoroSession.aggregate([
      {
        $match: {
          userId: req.user._id,
          startTime: { $gte: twelveMonthsAgo },
          completed: true
        }
      },
      {
        $group: {
          _id: {
            $dateToString: { format: "%Y-%m", date: "$startTime" }
          },
          workSessions: {
            $sum: { $cond: [{ $eq: ["$mode", "work"] }, 1, 0] }
          },
          workTime: {
            $sum: { $cond: [{ $eq: ["$mode", "work"] }, "$duration", 0] }
          },
          breakTime: {
            $sum: { $cond: [{ $in: ["$mode", ["break", "longBreak"]] }, "$duration", 0] }
          },
          totalSessions: { $sum: 1 }
        }
      },
      {
        $sort: { _id: 1 }
      }
    ]);

    res.json(monthlyStats);

  } catch (error) {
    console.error('Get monthly stats error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// @route   GET /api/stats/streak
// @desc    Get current and longest streaks
// @access  Private
router.get('/streak', auth, async (req, res) => {
  try {
    const sessions = await PomodoroSession.find({
      userId: req.user._id,
      mode: 'work',
      completed: true
    })
    .sort({ startTime: -1 })
    .select('startTime');

    let currentStreak = 0;
    let longestStreak = 0;
    let tempStreak = 0;
    let lastDate = null;

    for (const session of sessions) {
      const sessionDate = session.startTime.toDateString();
      
      if (!lastDate) {
        lastDate = sessionDate;
        tempStreak = 1;
        currentStreak = 1;
        longestStreak = 1;
        continue;
      }

      const daysDiff = Math.floor((new Date(lastDate) - new Date(sessionDate)) / (1000 * 60 * 60 * 24));

      if (daysDiff === 1) {
        tempStreak++;
        if (tempStreak > longestStreak) {
          longestStreak = tempStreak;
        }
        if (currentStreak === 0) {
          currentStreak = tempStreak;
        }
      } else if (daysDiff === 0) {
        // Same day, continue streak
        continue;
      } else {
        // Streak broken
        if (currentStreak === 0) {
          currentStreak = tempStreak;
        }
        tempStreak = 1;
      }

      lastDate = sessionDate;
    }

    res.json({
      currentStreak,
      longestStreak
    });

  } catch (error) {
    console.error('Get streak error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router; 