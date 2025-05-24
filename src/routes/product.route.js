const express = require('express');
const router = express.Router();
const {asyncHandler} = require('../middleware/asyncFunction');
const productController = require('../controllers/product.controller');

router.get('/category', asyncHandler(productController.getProductsByCategories));

router.get('/filter', asyncHandler(productController.filterProducts));

router.get('/attribute', asyncHandler(productController.getAvailableFilters));


module.exports = router;
