const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');

// Load environment variables
dotenv.config();

const app = express();

// Middlewares
app.use(cors());
app.use(express.json()); // for parsing application/json

// Simple route for testing
app.get('/', (req, res) => {
    res.json({ message: 'Welcome to the Calendar Management API.' });
});

// Import routes
const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');
const eventRoutes = require('./routes/eventRoutes');
const reminderRoutes = require('./routes/reminderRoutes');

// Use routes
app.use('/api/auth', authRoutes);
app.use('/api', userRoutes);
app.use('/api', eventRoutes);
app.use('/api', reminderRoutes);

module.exports = app;
