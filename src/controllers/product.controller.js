const productService = require('../services/product.service');

module.exports.getProductsByCategories = async (req, res) => {
    const {categoryIds} = req.body

    const products = await productService.getProductByCategory(categoryIds);

    res.status(200).json({
        success: true,
        data: products,
    });
};

module.exports.filterProducts = async (req, res) => {
    const {
        categoryIds,
        attributeValueIds,
        minPrice,
        maxPrice
      } = req.query;
  
      const products = await productService.filterProducts({
        categoryIds: categoryIds ? categoryIds.split(',') : [],
        attributeValueIds: attributeValueIds ? attributeValueIds.split(',') : [],
        minPrice: minPrice ? parseFloat(minPrice) : null,
        maxPrice: maxPrice ? parseFloat(maxPrice) : null
      });
  
      res.json({ success: true, data: products });
};

exports.getAvailableFilters = async (req, res) => {
    const categoryIds = req.query.category_ids?.split(',') || [];
    const filters = await productService.getAvailableFilters({ categoryIds });

    res.json({ success: true, data: filters });
};

