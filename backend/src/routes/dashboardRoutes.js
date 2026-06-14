const express = require('express');

const Story = require('../models/Story');
const Career = require('../models/Career');
const Quiz = require('../models/Quiz');
const StudyMaterial = require('../models/StudyMaterial');
const PreviousPaper = require('../models/PreviousPaper');

const router = express.Router();

router.get('/', async (req, res) => {
  try {
    const totalStories = await Story.countDocuments();
    const totalCareers = await Career.countDocuments();
    const totalQuizzes = await Quiz.countDocuments();
    const totalStudyMaterials =
      await StudyMaterial.countDocuments();
    const totalPreviousPapers =
      await PreviousPaper.countDocuments();

    res.status(200).json({
      success: true,
      data: {
        totalStories,
        totalCareers,
        totalQuizzes,
        totalStudyMaterials,
        totalPreviousPapers,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

module.exports = router;