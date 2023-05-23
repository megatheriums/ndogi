const mysql = require('mysql2/promise');

const config = require('./config');

let connection;

const query = async (databaseQuery, parameters) => {
  if (!connection) {
    connection = await mysql.createConnection({
      database: config.database.name,
      host: config.database.host,
      multipleStatements: true,
      password: config.database.password,
      port: config.database.port,
      user: config.database.username,
    });
  }

  const [rows] = await connection.query(databaseQuery, parameters);

  return rows;
};

module.exports = query;
