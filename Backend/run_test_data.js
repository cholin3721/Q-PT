const mysql = require('mysql2/promise');
const fs = require('fs').promises;
require('dotenv').config();

async function runSQL() {
  const connection = await mysql.createConnection({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASS || '',
    database: process.env.DB_NAME || 'q_pt',
    multipleStatements: true
  });

  try {
    console.log('📊 테스트 데이터 삽입 시작...');
    const sql = await fs.readFile('./test_week_data.sql', 'utf8');
    
    await connection.query(sql);
    
    console.log('✅ 테스트 데이터 삽입 완료!');
    console.log('\n일주일 데이터 요약:');
    console.log('- 10/22 (화): 좋은 날 - 운동 완벽, 식단 균형 (2200kcal, 단백질 150g)');
    console.log('- 10/23 (수): 보통 날 - 운동 일부 포기, 식단 과다 (3000kcal, 지방 많음)');
    console.log('- 10/24 (목): 좋은 날 - 하체 집중, 식단 균형 (2100kcal, 단백질 140g)');
    console.log('- 10/25 (금): 나쁜 날 - 운동 안함, 식단 부실 (1200kcal, 단백질 40g)');
    console.log('- 10/26 (토): 좋은 날 - 상체+유산소, 식단 완벽 (2300kcal, 단백질 160g)');
    console.log('- 10/27 (일): 보통 날 - 가벼운 운동, 식단 적당 (1800kcal, 단백질 100g)');
    console.log('- 10/28 (월): 나쁜 날 - 운동 없음, 식단 불균형 (2500kcal, 지방 많음, 단백질 60g)');
    console.log('\n이제 앱에서 AI 피드백을 요청해보세요! 🚀');
    
  } catch (error) {
    console.error('❌ 오류 발생:', error.message);
  } finally {
    await connection.end();
  }
}

runSQL();












