const mysql = require('mysql2');

// 2. 접속할 데이터베이스 정보를 설정합니다.
const connection = mysql.createConnection({
  host: 'localhost',      // DB 호스트
  user: 'root',           // DB 사용자 이름
  password: 'worldcup7!', // DB 비밀번호
  database: 'q_pt' // 접속할 데이터베이스 이름
});

// 3. 데이터베이스 연결을 시도합니다.
connection.connect(error => {
  // 연결 시 에러가 발생했다면
  if (error) {
    console.error('❌ 데이터베이스 연결에 실패했습니다:', error.stack);
    return;
  }

  // 연결에 성공했다면
  console.log('✅ MySQL 데이터베이스에 성공적으로 연결되었습니다.');
  console.log('연결 ID:', connection.threadId);
});

// 4. 확인 후 연결을 종료합니다.
connection.end();