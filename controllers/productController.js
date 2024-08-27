const db = require('../db');

exports.getAllProducts = async (req, res) => {
  try {
    const [rows] = await db.execute('SELECT * FROM products');
    res.json(rows);
  } catch (err) {
    res.status(500).send('Server Error');
  }
};

exports.getProductById = async (req, res) => {
  try {
    const [rows] = await db.execute('SELECT * FROM products WHERE id = ?', [req.params.id]);
    if (rows.length) {
      res.json(rows[0]);
    } else {
      res.status(404).send('Product not found');
    }
  } catch (err) {
    res.status(500).send('Server Error');
  }
};

exports.createProduct = async (req, res) => {
  try {
    const { name, price } = req.body;
    const [result] = await db.execute('INSERT INTO products (name, price) VALUES (?, ?)', [name, price]);
    res.status(201).json({ id: result.insertId, name, price });
  } catch (err) {
    res.status(500).send('Server Error');
  }
};