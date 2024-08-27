const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.send('Welcome to the E-commerce Application!');
});

app.listen(port, () => {
  console.log(`App running at http://localhost:${port}`);
});