const { Sequelize } = require('sequelize');
require('dotenv').config();

// 데이터베이스 연결 설정
const sequelize = new Sequelize(
  process.env.DB_NAME || 'q_pt',
  process.env.DB_USER || 'root',
  process.env.DB_PASS || '',
  {
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 3306,
    dialect: 'mysql',
    logging: false, // SQL 로그 비활성화
    pool: {
      max: 5,
      min: 0,
      acquire: 30000,
      idle: 10000
    }
  }
);

// 연결 테스트
const testConnection = async () => {
  try {
    await sequelize.authenticate();
    console.log('데이터베이스 연결이 성공적으로 설정되었습니다.');
  } catch (error) {
    console.error('데이터베이스 연결에 실패했습니다:', error);
  }
};

module.exports = { sequelize, testConnection };