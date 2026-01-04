const pool = require('../config/db');

// @desc    Create a new event
exports.createEvent = async (req, res) => {
    const { title, description, start_time, end_time } = req.body;
    const user_id = req.user.id;

    try {
        const newEvent = { user_id, title, description, start_time, end_time };
        const [result] = await pool.query('INSERT INTO events SET ?', newEvent);
        
        res.status(201).json({ id: result.insertId, ...newEvent });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};

// @desc    Get all events for the logged-in user
exports.getEvents = async (req, res) => {
    try {
        let events;
        // If user is STAFF, get their own events and events assigned to them
        if (req.user.role === 'STAFF') {
            const [staffEvents] = await pool.query(`
                SELECT e.*, 'owned' as type FROM events e WHERE e.user_id = ? AND e.deleted_at IS NULL
                UNION
                SELECT e.*, 'assigned' as type FROM events e 
                JOIN event_assignments ea ON e.id = ea.event_id
                WHERE ea.staff_id = ? AND e.deleted_at IS NULL
            `, [req.user.id, req.user.id]);
            events = staffEvents;
        } else {
        // For ADMIN and USER, get only their own events
            const [userEvents] = await pool.query('SELECT *, \'owned\' as type FROM events WHERE user_id = ? AND deleted_at IS NULL', [req.user.id]);
            events = userEvents;
        }

        res.json(events);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};

// @desc    Get a single event by ID
exports.getEventById = async (req, res) => {
    try {
        const [events] = await pool.query('SELECT * FROM events WHERE id = ? AND deleted_at IS NULL', [req.params.id]);

        if (events.length === 0) {
            return res.status(404).json({ msg: 'Event not found' });
        }

        const event = events[0];
        
        // Security check: Ensure the user owns the event or is an ADMIN or an assigned STAFF
        const [assignments] = await pool.query('SELECT staff_id FROM event_assignments WHERE event_id = ?', [req.params.id]);
        const isAssigned = assignments.some(a => a.staff_id === req.user.id);

        if (event.user_id !== req.user.id && req.user.role !== 'ADMIN' && !isAssigned) {
            return res.status(403).json({ msg: 'User not authorized to view this event' });
        }

        res.json(event);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};

// @desc    Update an event
exports.updateEvent = async (req, res) => {
    try {
        const [events] = await pool.query('SELECT user_id FROM events WHERE id = ? AND deleted_at IS NULL', [req.params.id]);
        if (events.length === 0) {
            return res.status(404).json({ msg: 'Event not found' });
        }
        
        // Authorization: only owner or ADMIN can update
        if (events[0].user_id !== req.user.id && req.user.role !== 'ADMIN') {
            return res.status(403).json({ msg: 'User not authorized to update this event' });
        }

        await pool.query('UPDATE events SET ? WHERE id = ?', [req.body, req.params.id]);
        res.json({ msg: 'Event updated successfully' });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};

// @desc    Soft delete an event
exports.deleteEvent = async (req, res) => {
    try {
        const [events] = await pool.query('SELECT user_id FROM events WHERE id = ? AND deleted_at IS NULL', [req.params.id]);
        if (events.length === 0) {
            return res.status(404).json({ msg: 'Event not found' });
        }

        // Authorization: only owner or ADMIN can delete
        if (events[0].user_id !== req.user.id && req.user.role !== 'ADMIN') {
            return res.status(403).json({ msg: 'User not authorized to delete this event' });
        }

        await pool.query('UPDATE events SET deleted_at = CURRENT_TIMESTAMP WHERE id = ?', [req.params.id]);
        res.json({ msg: 'Event soft deleted successfully' });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};

// @desc    Assign an event to a STAFF (ADMIN only)
exports.assignEvent = async (req, res) => {
    const { staff_id } = req.body;
    const event_id = req.params.id;
    const assigned_by = req.user.id;

    try {
        // Check if event exists
        const [events] = await pool.query('SELECT id FROM events WHERE id = ? AND deleted_at IS NULL', [event_id]);
        if (events.length === 0) {
            return res.status(404).json({ msg: 'Event not found' });
        }

        // Check if staff exists and has the role STAFF
        const [staffs] = await pool.query('SELECT id, role FROM users WHERE id = ? AND role = \'STAFF\' AND deleted_at IS NULL', [staff_id]);
        if (staffs.length === 0) {
            return res.status(404).json({ msg: 'Staff member not found or user is not a staff' });
        }

        const assignment = { event_id, staff_id, assigned_by };
        await pool.query('INSERT INTO event_assignments SET ?', assignment);

        res.status(201).json({ msg: 'Event assigned successfully' });

    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};
