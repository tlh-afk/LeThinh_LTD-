const pool = require('../config/db');

// @desc    Create a new reminder for an event
exports.createReminder = async (req, res) => {
    const { event_id, remind_at } = req.body;

    try {
        // Security check: Verify the user owns the event before adding a reminder
        const [events] = await pool.query('SELECT user_id FROM events WHERE id = ? AND deleted_at IS NULL', [event_id]);
        if (events.length === 0) {
            return res.status(404).json({ msg: 'Event not found' });
        }

        if (events[0].user_id !== req.user.id && req.user.role !== 'ADMIN') {
             return res.status(403).json({ msg: 'User not authorized to add a reminder to this event' });
        }

        const newReminder = { event_id, remind_at };
        const [result] = await pool.query('INSERT INTO reminders SET ?', newReminder);

        res.status(201).json({ id: result.insertId, ...newReminder });

    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};

// @desc    Get all reminders for a specific event
exports.getRemindersForEvent = async (req, res) => {
    const { eventId } = req.params;

    try {
        // Security check: Verify the user owns the event or is an admin/assigned staff
        const [events] = await pool.query('SELECT user_id FROM events WHERE id = ? AND deleted_at IS NULL', [eventId]);
        if (events.length === 0) {
            return res.status(404).json({ msg: 'Event not found' });
        }

        const [assignments] = await pool.query('SELECT staff_id FROM event_assignments WHERE event_id = ?', [eventId]);
        const isAssigned = assignments.some(a => a.staff_id === req.user.id);

        if (events[0].user_id !== req.user.id && req.user.role !== 'ADMIN' && !isAssigned) {
            return res.status(403).json({ msg: 'User not authorized to view reminders for this event' });
        }

        const [reminders] = await pool.query('SELECT * FROM reminders WHERE event_id = ?', [eventId]);
        res.json(reminders);

    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};
