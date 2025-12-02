const express = require('express');
const cors = require('cors');
const { testConnection } = require('./config/db.config');

const app = express();

// 미들웨어 설정
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// 기능별 라우트 연결
const authRoutes = require('./api/auth/auth.routes');
const userRoutes = require('./api/users/users.routes');
const inbodyRoutes = require('./api/inbody/inbody.routes');
const goalRoutes = require('./api/goals/goals.routes');
const mealRoutes = require('./api/meals/meals.routes');
const workoutRoutes = require('./api/workouts/workouts.routes');
const routineRoutes = require('./api/workouts/routines.routes');
const aiRoutes = require('./api/ai/ai.routes');

app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/inbody', inbodyRoutes);
app.use('/api/goals', goalRoutes);
app.use('/api/meals', mealRoutes);
app.use('/api/workouts', workoutRoutes);
app.use('/api/routines', routineRoutes);
app.use('/api/ai', aiRoutes);

// 에러 핸들링 미들웨어
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ message: '서버 내부 오류가 발생했습니다.' });
});

// 404 핸들링
app.use((req, res) => {
  res.status(404).json({ message: '요청한 엔드포인트를 찾을 수 없습니다.' });
});

// 데이터베이스 연결 테스트
testConnection();

module.exports = app;