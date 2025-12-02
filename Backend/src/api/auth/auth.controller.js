// 인증 컨트롤러 예시
exports.socialLogin = async (req, res) => {
  const { provider } = req.params;
  const { accessToken } = req.body;
  // 실제 구현에서는 provider별로 accessToken 검증 및 사용자 정보 처리
  // 예시 응답
  if (!accessToken) return res.status(401).json({ message: 'No accessToken' });
  // TODO: provider별 검증 및 JWT 발급
  return res.json({ jwt: 'sample.jwt.token', isNewUser: true });
};