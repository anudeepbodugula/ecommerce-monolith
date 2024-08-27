const express = require('express');
const router = express.Router();
const orderController = require('../controllers/orderController');

// Route to place an order
router.post('/orders', orderController.placeOrder);

// Route to get order details by ID
router.get('/orders/:id', orderController.getOrderById);

module.exports = router;