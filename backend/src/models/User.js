const mongoose = require('mongoose');

const userSchema = new mongoose.Schema(
  {
    firebaseUid: {
      type: String,
      required: true,
      unique: true,
    },

    // Optional because phone-only users may not have an email.
    email: {
      type: String,
      unique: true,
      sparse: true,
    },

    // Optional because Google users may not have a phone number.
    phone: {
      type: String,
      unique: true,
      sparse: true,
    },

    name: {
      type: String,
      default: 'Student',
    },

    photoUrl: {
      type: String,
      default: '',
    },

    role: {
      type: String,
      enum: ['student', 'admin'],
      default: 'student',
    },

    points: {
      type: Number,
      default: 0,
    },

    streak: {
      type: Number,
      default: 0,
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('User', userSchema);
