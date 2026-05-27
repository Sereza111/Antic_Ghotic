const mysql = require('mysql2/promise');

let pool;

function getPool() {
  if (pool) return pool;

  const host = process.env.MYSQL_HOST;
  const user = process.env.MYSQL_USER;
  const password = process.env.MYSQL_PASSWORD;
  const database = process.env.MYSQL_DATABASE;
  const port = Number(process.env.MYSQL_PORT || 3306);

  if (!host || !user || !password || !database) {
    throw new Error(
      'Missing MySQL env: MYSQL_HOST, MYSQL_USER, MYSQL_PASSWORD, MYSQL_DATABASE',
    );
  }

  pool = mysql.createPool({
    host,
    port,
    user,
    password,
    database,
    waitForConnections: true,
    connectionLimit: 10,
    namedPlaceholders: true,
  });

  return pool;
}

module.exports = { getPool };
