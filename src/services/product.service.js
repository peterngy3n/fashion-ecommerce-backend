const { NotFoundException } = require('../errors/exception');
const prisma = require('../config/prisma.config');

const getProductByCategory = async (categoryIds) => {
    const products = await prisma.product.findMany({
        where: {
          category_id: {
            in: categoryIds.length > 0 ? categoryIds : undefined,
          },
          is_active: true,
        },
        include: {
          product_variants: {
            include: {
              variant_attribute_values: {
                include: {
                  attribute_value: {
                    include: {
                      attribute: true,
                    },
                  },
                },
              },
            },
          },
        },
        orderBy: {
          created_at: 'desc',
        },
    });

    if (products.length === 0) {
        throw new NotFoundException();
    }

    return products
};

const getAvailableFilters = async ({ categoryIds }) => {
    // Lấy các thuộc tính liên quan đến danh mục
    const attributes = await prisma.attribute.findMany({
      where: {
        category_id: { in: categoryIds },
      },
      include: {
        attribute_values: true,
      },
    });

    if (attributes.length === 0) {
        throw new NotFoundException('No attributes found for the selected categories');
    }
  
    return attributes.map(attr => ({
      attribute: {
        id: attr.id,
        name: attr.name,
      },
      values: attr.attribute_values.map(v => ({
        id: v.id,
        value: v.value,
      })),
    }));
};

const filterProducts = async ({ categoryIds, attributeValueIds, minPrice, maxPrice }) => {
    const whereVariant = {
      AND: [],
    };
  
    // Giá
    if (minPrice !== null || maxPrice !== null) {
      whereVariant.AND.push({
        price: {
          ...(minPrice !== null && { gte: minPrice }),
          ...(maxPrice !== null && { lte: maxPrice })
        }
      });
    }
  
    // Thuộc tính (size, màu...)
    if (attributeValueIds.length > 0) {
      for (const attrId of attributeValueIds) {
        whereVariant.AND.push({
          variant_attribute_values: {
            some: {
              attribute_value_id: attrId
            }
          }
        });
      }
    }
  
    const variants = await prisma.productVariant.findMany({
      where: whereVariant,
      include: {
        product: {
          include: {
            category: true
          }
        },
        variant_attribute_values: {
          include: {
            attribute_value: {
              include: {
                attribute: true
              }
            }
          }
        }
      }
    });
  
    // Lọc theo danh mục
    let filteredVariants = variants;
    if (categoryIds.length > 0) {
      filteredVariants = variants.filter(v =>
        categoryIds.includes(v.product.category_id)
      );
    }
  
    // Trả về danh sách sản phẩm (hoặc group theo product ID nếu cần)
    const products = filteredVariants.map(v => v.product);
  
    // Loại bỏ trùng (vì nhiều variant có thể cùng product)
    const uniqueProducts = Array.from(new Map(products.map(p => [p.id, p])).values());
    
    if (uniqueProducts.length === 0) {
        throw new NotFoundException('No products found for the given filters');
    }
    
    return uniqueProducts;
};

module.exports = {
  getProductByCategory,
  getAvailableFilters,
  filterProducts
};
