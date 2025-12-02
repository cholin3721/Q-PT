const multer = require('multer');
const path = require('path');

// 메모리 스토리지 설정 (파일을 디스크에 저장하지 않고 메모리에 버퍼로 저장)
const storage = multer.memoryStorage();

// 파일 필터 (이미지 파일만 허용)
const fileFilter = (req, file, cb) => {
  const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif'];
  
  if (allowedTypes.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(new Error('이미지 파일만 업로드 가능합니다. (jpg, jpeg, png, gif)'), false);
  }
};

// multer 설정
const upload = multer({
  storage: storage,
  fileFilter: fileFilter,
  limits: {
    fileSize: 10 * 1024 * 1024 // 10MB 제한
  }
});

module.exports = upload;




