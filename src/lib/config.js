import 'dotenv/config';

const config = {
  database: {
    host: process.env.DATABASE_HOST,
    name: process.env.DATABASE_NAME,
    password: process.env.DATABASE_PASSWORD,
    port: process.env.DATABASE_PORT,
    username: process.env.DATABASE_USERNAME,
  },
};

export default config;
