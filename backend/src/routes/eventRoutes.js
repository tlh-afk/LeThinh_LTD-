const express = require('express');
const router = express.Router();
const eventController = require('../controllers/eventController');
const { protect, authorize } = require('../middlewares/authMiddleware');

// All routes below are protected
router.use(protect);

// @route   POST api/events
// @desc    Create a new event
router.post('/events', eventController.createEvent);

// @route   GET api/events
// @desc    Get all events for the logged-in user (and assigned events for STAFF)
router.get('/events', eventController.getEvents);

// @route   GET api/events/:id
// @desc    Get a single event by ID
router.get('/events/:id', eventController.getEventById);

// @route   PUT api/events/:id
// @desc    Update an event
router.put('/events/:id', eventController.updateEvent);

// @route   DELETE api/events/:id
// @desc    Soft delete an event
router.delete('/events/:id', eventController.deleteEvent);

// @route   POST api/events/:id/assign
// @desc    Assign an event to a STAFF (ADMIN only)
router.post('/events/:id/assign', authorize('ADMIN'), eventController.assignEvent);

module.exports = router;
