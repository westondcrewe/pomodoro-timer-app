const express = require('express');
const { body, validationResult } = require('express-validator');
const auth = require('../middleware/auth');
const PomodoroSession = require('../models/PomodoroSession');
const UserStats = require('../models/UserStats');
const router = express.Router();

// @route   POST /api/sessions
// @desc    Create a new Pomodoro session
// @access  Private
router.post('/', [
  auth,
  body('startTime').isISO8601().withMessage('Start time must be a valid date'),
  body('duration').isInt({ min: 1 }).withMessage('Duration must be a positive integer'),
  body('mode').isIn(['work', 'break', 'longBreak']).withMessage('Invalid mode')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { startTime, duration, mode, notes } = req.body;

    const session = new PomodoroSession({
      userId: req.user._id,
      startTime: new Date(startTime),
      duration,
      mode,
      notes
    });

    await session.save();

    res.status(201).json({
      message: 'Session created successfully',
      session
    });

  } catch (error) {
    console.error('Create session error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// @route   PUT /api/sessions/:id
// @desc    Update a Pomodoro session (complete it)
// @access  Private
router.put('/:id', [
  auth,
  body('endTime').isISO8601().withMessage('End time must be a valid date'),
  body('completed').isBoolean().withMessage('Completed must be a boolean')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { endTime, completed, notes } = req.body;

    const session = await PomodoroSession.findOne({
      _id: req.params.id,
      userId: req.user._id
    });

    if (!session) {
      return res.status(404).json({ message: 'Session not found' });
    }

    session.endTime = new Date(endTime);
    session.completed = completed;
    if (notes) session.notes = notes;

    await session.save();

    // Update user stats if session is completed
    if (completed) {
      await updateUserStats(req.user._id, session);
    }

    res.json({
      message: 'Session updated successfully',
      session
    });

  } catch (error) {
    console.error('Update session error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// @route   GET /api/sessions
// @desc    Get user's Pomodoro sessions
// @access  Private
router.get('/', auth, async (req, res) => {
  try {
    const { page = 1, limit = 10, mode, completed } = req.query;
    
    const query = { userId: req.user._id };
    if (mode) query.mode = mode;
    if (completed !== undefined) query.completed = completed === 'true';

    const sessions = await PomodoroSession.find(query)
      .sort({ startTime: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .exec();

    const total = await PomodoroSession.countDocuments(query);

    res.json({
      sessions,
      totalPages: Math.ceil(total / limit),
      currentPage: page,
      total
    });

  } catch (error) {
    console.error('Get sessions error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// @route   GET /api/sessions/:id
// @desc    Get a specific Pomodoro session
// @access  Private
router.get('/:id', auth, async (req, res) => {
  try {
    const session = await PomodoroSession.findOne({
      _id: req.params.id,
      userId: req.user._id
    });

    if (!session) {
      return res.status(404).json({ message: 'Session not found' });
    }

    res.json(session);

  } catch (error) {
    console.error('Get session error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// @route   DELETE /api/sessions/:id
// @desc    Delete a Pomodoro session
// @access  Private
router.delete('/:id', auth, async (req, res) => {
  try {
    const session = await PomodoroSession.findOneAndDelete({
      _id: req.params.id,
      userId: req.user._id
    });

    if (!session) {
      return res.status(404).json({ message: 'Session not found' });
    }

    res.json({ message: 'Session deleted successfully' });

  } catch (error) {
    console.error('Delete session error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Helper function to update user stats
async function updateUserStats(userId, session) {
  try {
    let userStats = await UserStats.findOne({ userId });
    
    if (!userStats) {
      userStats = new UserStats({ userId });
    }

    // Update basic stats
    if (session.mode === 'work') {
      userStats.totalWorkSessions += 1;
      userStats.totalWorkTime += session.duration;
    } else if (session.mode === 'break') {
      userStats.totalBreakTime += session.duration;
    } else if (session.mode === 'longBreak') {
      userStats.totalLongBreakTime += session.duration;
    }

    userStats.totalRounds += session.rounds || 0;
    userStats.lastActiveDate = new Date();

    // Calculate average session length
    if (userStats.totalWorkSessions > 0) {
      userStats.averageSessionLength = Math.round(userStats.totalWorkTime / userStats.totalWorkSessions);
    }

    await userStats.save();
  } catch (error) {
    console.error('Update user stats error:', error);
  }
}

module.exports = router; 