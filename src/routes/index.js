const express = require('express')
const router = express.Router()
//const {io} = require('../app')
//Booking route


const categoryRoute = require('./category.route')
const productRoute = require('./product.route')
const orderRoute = require('./order.route')


router.use('/categories', categoryRoute)
router.use('/products', productRoute)
router.use('/orders', orderRoute)

module.exports = router