
const orderService = require('../services/order.service');

exports.createOrder = async (req, res) => {
    const result = await orderService.createOrder(req.body);
    res.status(201).json(result);
};

exports.simulatePayment = async (req, res) => {
    const result = await orderService.simulatePayment(req.params.orderId);
    res.status(200).json(result);
};

exports.confirmOrder = async (req, res) => {
    const result = await orderService.confirmOrder(req.params.orderId);
    res.status(200).json(result);
};
  