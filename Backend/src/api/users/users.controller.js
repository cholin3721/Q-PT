const { User } = require('../../models');

exports.checkNickname = async (req, res) => {
  try {
    const { nickname } = req.query;
    
    if (!nickname) {
      return res.status(400).json({ message: '닉네임을 입력해주세요.' });
    }

    const existingUser = await User.findOne({ where: { nickname } });
    
    res.json({ isAvailable: !existingUser });
  } catch (error) {
    console.error('닉네임 중복 확인 오류:', error);
    res.status(500).json({ message: '서버 오류가 발생했습니다.' });
  }
};

exports.setNickname = async (req, res) => {
  try {
    const { nickname } = req.body;
    const userId = req.user.user_id;

    if (!nickname) {
      return res.status(400).json({ message: '닉네임을 입력해주세요.' });
    }

    // 닉네임 중복 확인
    const existingUser = await User.findOne({ where: { nickname } });
    if (existingUser && existingUser.user_id !== userId) {
      return res.status(409).json({ message: '이미 사용 중인 닉네임입니다.' });
    }

    // 닉네임 업데이트
    await User.update({ nickname }, { where: { user_id: userId } });
    
    const updatedUser = await User.findByPk(userId);
    res.json({
      userId: updatedUser.user_id,
      nickname: updatedUser.nickname,
      email: updatedUser.email
    });
  } catch (error) {
    console.error('닉네임 설정 오류:', error);
    res.status(500).json({ message: '서버 오류가 발생했습니다.' });
  }
};

exports.getMyInfo = async (req, res) => {
  try {
    const user = req.user;
    
    res.json({
      userId: user.user_id,
      provider: user.provider,
      nickname: user.nickname,
      email: user.email,
      createdAt: user.created_at
    });
  } catch (error) {
    console.error('내 정보 조회 오류:', error);
    res.status(500).json({ message: '서버 오류가 발생했습니다.' });
  }
};