const express = require('express');
const router = express.Router();
const inbodyController = require('./inbody.controller');
const authMiddleware = require('../../middleware/auth.middleware');
const upload = require('../../middleware/upload.middleware');

// OCR: 이미지 업로드 + 인증 필요
router.post('/ocr', authMiddleware, upload.single('image'), inbodyController.ocr);

// 인바디 데이터 등록
router.post('/', authMiddleware, inbodyController.register);

// 인바디 이력 조회
router.get('/', authMiddleware, inbodyController.list);

module.exports = router;