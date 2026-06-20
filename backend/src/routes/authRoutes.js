const express = require('express');

const {
  loginUser,
  updateProfile,
} = require('../controllers/authController');

const router = express.Router();

router.post('/login', loginUser);
router.put('/profile', updateProfile);

module.exports = router;