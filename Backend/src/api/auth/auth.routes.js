const express = require('express');
const router = express.Router();
const authController = require('./auth.controller');

// 소셜 로그인
router.post('/login/:provider', authController.socialLogin);

module.exports = router;