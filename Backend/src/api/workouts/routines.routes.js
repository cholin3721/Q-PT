// Backend/src/api/workouts/routines.routes.js

const express = require('express');
const router = express.Router();
const routinesController = require('./routines.controller');
const authMiddleware = require('../../middleware/auth.middleware');

// 모든 루틴 라우트에 인증 미들웨어 적용
router.use(authMiddleware);

// 루틴 목록 조회
router.get('/', routinesController.getRoutines);

// 루틴 상세 조회
router.get('/:routineId', routinesController.getRoutineDetail);

// 루틴 생성
router.post('/', routinesController.createRoutine);

// 루틴 삭제
router.delete('/:routineId', routinesController.deleteRoutine);

module.exports = router;












