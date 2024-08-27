const db = require('../db');

exports.placeOrder = async (req, res) => {
  try {
    const { product_id, quantity } = req.body;
    await db.execute('INSERT INTO orders (product_id, quantity) VALUES (?, ?)', [product_id, quantity]);
    res.status(201).json({ product_id, quantity });
  } catch (err) {
    res.status(500).send('Server Error');
  }
};

exports.getOrderById = async (req, res) => {
  try {
    const [rows] = await db.execute('SELECT * FROM orders WHERE id = ?', [req.params.id]);
    if (rows.length) {
      res.json(rows[0]);
    } else {
      res.status(404).send('Order not found');
    }
  } catch (err) {
    res.status(500).send('Server Error');
  }
};