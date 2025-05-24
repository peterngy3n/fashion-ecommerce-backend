const express = require('express');
const router = express.Router();
const {asyncHandler} = require('../middleware/asyncFunction');
const categoryController = require('../controllers/category.controller');

router.get('/', asyncHandler(categoryController.getAllCategories));

module.exports = router;
