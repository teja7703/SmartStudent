const mongoose = require('mongoose');
const User = require('../models/User');

const connectDB = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI);

    console.log('✅ MongoDB Connected Successfully');

    // Rebuild indexes so phone/email become sparse-unique (allows
    // phone-only users with no email and vice versa).
    try {
      await User.syncIndexes();
    } catch (indexError) {
      console.warn('⚠️  User index sync skipped:', indexError.message);
    }
  } catch (error) {
    console.error('❌ MongoDB Connection Failed');
    console.error(error.message);

    process.exit(1);
  }
};

module.exports = connectDB;