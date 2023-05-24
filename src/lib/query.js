import mysql from 'mysql2/promise';

import config from './config.js';

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

export default query;
