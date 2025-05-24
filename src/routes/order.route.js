const express = require('express');
const router = express.Router();
const orderController = require('../controllers/order.controller');

router.post('/', orderController.createOrder);
router.post('/pay/:orderId', orderController.simulatePayment);
router.get('/confirm/:orderId', orderController.confirmOrder);

module.exports = router;
