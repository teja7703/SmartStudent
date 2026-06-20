const mongoose = require('mongoose');

const storySchema = new mongoose.Schema(
  {
    name: {
      type: String,
      default: '',
    },

    title: {
      type: String,
      required: true,
    },

    category: {
      type: String,
      required: true,
    },

    summary: {
      type: String,
      default: '',
    },

    successLesson: {
      type: String,
      default: '',
    },

    quote: {
      type: String,
      default: '',
    },

    imageUrl: {
      type: String,
      default: '',
    },

    readTime: {
      type: Number,
      default: 4,
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('Story', storySchema);
