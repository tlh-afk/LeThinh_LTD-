const pool = require('../config/db');

// @desc    Get all users (for ADMIN)
exports.getAllUsers = async (req, res) => {
    try {
        const [users] = await pool.query('SELECT id, email, role, created_at, updated_at, deleted_at FROM users WHERE deleted_at IS NULL');
        res.json(users);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};

// @desc    Get single user by ID (for ADMIN)
exports.getUserById = async (req, res) => {
    try {
        const [users] = await pool.query('SELECT id, email, role, created_at, updated_at FROM users WHERE id = ? AND deleted_at IS NULL', [req.params.id]);
        if (users.length === 0) {
            return res.status(404).json({ msg: 'User not found' });
        }
        res.json(users[0]);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};

// @desc    Update user (for ADMIN)
exports.updateUser = async (req, res) => {
    const { email, role } = req.body;
    try {
        const [users] = await pool.query('SELECT id FROM users WHERE id = ? AND deleted_at IS NULL', [req.params.id]);
        if (users.length === 0) {
            return res.status(404).json({ msg: 'User not found' });
        }

        const updatedFields = {};
        if (email) updatedFields.email = email;
        if (role) updatedFields.role = role;

        if (Object.keys(updatedFields).length === 0) {
            return res.status(400).json({ msg: 'No fields to update' });
        }

        await pool.query('UPDATE users SET ? WHERE id = ?', [updatedFields, req.params.id]);

        res.json({ msg: 'User updated successfully' });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};

// @desc    Soft delete user (for ADMIN)
exports.deleteUser = async (req, res) => {
    try {
        const [users] = await pool.query('SELECT id FROM users WHERE id = ? AND deleted_at IS NULL', [req.params.id]);
        if (users.length === 0) {
            return res.status(404).json({ msg: 'User not found' });
        }

        await pool.query('UPDATE users SET deleted_at = CURRENT_TIMESTAMP WHERE id = ?', [req.params.id]);

        res.json({ msg: 'User soft deleted successfully' });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};
