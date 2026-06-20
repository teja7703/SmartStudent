const mongoose = require('mongoose');

const careerSchema = new mongoose.Schema(
  {
    careerName: {
      type: String,
      required: true,
    },

    category: {
      type: String,
      default: 'General',
    },

    description: {
      type: String,
      required: true,
    },

    overview: {
      type: String,
      default: '',
    },

    eligibility: {
      type: String,
      default: '',
    },

    requiredEducation: {
      type: String,
      default: '',
    },

    salaryRange: {
      type: String,
      default: '',
    },

    skills: {
      type: [String],
      default: [],
    },

    careerGrowth: {
      type: String,
      default: '',
    },

    recommendedCourses: {
      type: [String],
      default: [],
    },

    imageUrl: {
      type: String,
      default: '',
    },

    order: {
      type: Number,
      default: 0,
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('Career', careerSchema);