const { NotFoundException } = require('../errors/exception');
const prisma = require('../config/prisma.config');

const getAllCategories = async () => {
    const categories = await prisma.category.findMany({
        where: { is_active: true },
        orderBy: { sort_order: 'asc' },
    });

    if (categories.length === 0) {
        throw new NotFoundException();
    }

    return categories
};

module.exports = {
  getAllCategories,
};
