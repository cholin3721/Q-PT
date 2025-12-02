const express = require('express');
const router = express.Router();
const usersController = require('./users.controller');
const authMiddleware = require('../../middleware/auth.middleware');

router.get('/nickname/check', usersController.checkNickname);
router.put('/me/nickname', authMiddleware, usersController.setNickname);
router.get('/me', authMiddleware, usersController.getMyInfo);

module.exports = router;