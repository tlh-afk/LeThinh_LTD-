const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const { protect, authorize } = require('../middlewares/authMiddleware');

// All routes below are protected and restricted to ADMIN
router.use(protect);
router.use(authorize('ADMIN'));

// @route   GET api/users
// @desc    Get all users
router.get('/users', userController.getAllUsers);

// @route   GET api/users/:id
// @desc    Get a single user by ID
router.get('/users/:id', userController.getUserById);

// @route   PUT api/users/:id
// @desc    Update a user
router.put('/users/:id', userController.updateUser);

// @route   DELETE api/users/:id
// @desc    Soft delete a user
router.delete('/users/:id', userController.deleteUser);

module.exports = router;
