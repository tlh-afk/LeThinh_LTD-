const express = require('express');
const router = express.Router();
const reminderController = require('../controllers/reminderController');
const { protect } = require('../middlewares/authMiddleware');

// All routes below are protected
router.use(protect);

// @route   POST api/reminders
// @desc    Create a new reminder for an event
router.post('/reminders', reminderController.createReminder);

// @route   GET api/events/:eventId/reminders
// @desc    Get all reminders for a specific event
router.get('/events/:eventId/reminders', reminderController.getRemindersForEvent);

module.exports = router;
