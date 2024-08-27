const mysql = require('mysql2');

// Create a connection pool to the MySQL database
const pool = mysql.createPool({
  host: 'localhost',
  user: 'root',             // Your MySQL username
  password: 'yourpassword', // Your MySQL password
  database: 'ecommerce'     // The name of your database
});

// Export a promise-based connection
module.exports = pool.promise();