// 서버 진입점: app.js를 불러와 실행
require('dotenv').config();
const app = require('./src/app');
const port = process.env.PORT || 3000;

app.listen(port, () => {
  console.log(`Q-PT API 서버가 http://localhost:${port} 에서 실행 중입니다.`);
  console.log('환경 변수 확인:');
  console.log(`- DB_HOST: ${process.env.DB_HOST || 'localhost'}`);
  console.log(`- DB_NAME: ${process.env.DB_NAME || 'q_pt'}`);
  console.log(`- JWT_SECRET: ${process.env.JWT_SECRET ? '✅ 설정됨' : '⚠️  기본값 사용'}`);
  console.log(`- OPENAI_API_KEY: ${process.env.OPENAI_API_KEY ? '✅ 설정됨 (AI 기능 활성화)' : '⚠️  미설정 (Mock 데이터 사용)'}`);
});