const jwt = require('jsonwebtoken');
const { User } = require('../models');

const authMiddleware = async (req, res, next) => {
  try {
    // 테스트용: 토큰 검증 우회하고 고정 사용자 설정
    const user = await User.findByPk(1); // 김철중 사용자 (ID: 1)
    
    if (!user) {
      return res.status(401).json({ message: '사용자를 찾을 수 없습니다.' });
    }

    req.user = user;
    next();
  } catch (error) {
    return res.status(500).json({ message: '서버 오류가 발생했습니다.' });
  }
};

module.exports = authMiddleware;