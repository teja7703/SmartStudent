const StudyMaterial = require('../models/StudyMaterial');

const createStudyMaterial = async (req, res) => {
  try {
    const studyMaterial = await StudyMaterial.create(req.body);

    res.status(201).json({
      success: true,
      data: studyMaterial,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

const getStudyMaterials = async (req, res) => {
  try {
    const {
      academicLevel,
      subject,
      chapter,
      language,
      search,
      page = 1,
      limit = 100,
    } = req.query;

    const filter = {};

    if (academicLevel) filter.academicLevel = academicLevel;
    if (subject) filter.subject = subject;
    if (chapter) filter.chapter = chapter;
    if (language) filter.language = language;

    if (search) {
      filter.chapter = { $regex: search, $options: 'i' };
    }

    const skip = (page - 1) * limit;

    const materials = await StudyMaterial.find(filter)
      .sort({ order: 1, createdAt: 1 })
      .skip(skip)
      .limit(Number(limit));

    const totalRecords =
      await StudyMaterial.countDocuments(filter);

    res.status(200).json({
      success: true,
      page: Number(page),
      limit: Number(limit),
      totalRecords,
      data: materials,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

const getStudyMaterialById = async (req, res) => {
  try {
    const material =
      await StudyMaterial.findById(req.params.id);

    if (!material) {
      return res.status(404).json({
        success: false,
        message: 'Study material not found',
      });
    }

    res.status(200).json({
      success: true,
      data: material,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

const deleteStudyMaterial = async (req, res) => {
  try {
    await StudyMaterial.findByIdAndDelete(req.params.id);

    res.status(200).json({
      success: true,
      message: 'Study material deleted',
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

module.exports = {
  createStudyMaterial,
  getStudyMaterials,
  getStudyMaterialById,
  deleteStudyMaterial,
};