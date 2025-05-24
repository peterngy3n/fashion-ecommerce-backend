const categoryService = require('../services/category.service');

const getAllCategories = async (req, res) => {
    const categories = await categoryService.getAllCategories();
    res.status(200).json({
      success: true,
      data: categories,
    });
};

module.exports = {
  getAllCategories,
};
