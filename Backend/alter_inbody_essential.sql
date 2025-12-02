-- InBody 테이블에 필수 컬럼 추가 (최소 버전)
-- 실행 전 백업 권장!

USE q_pt;

ALTER TABLE InBody
ADD COLUMN body_water DECIMAL(5, 2) COMMENT '체수분(L)',
ADD COLUMN protein DECIMAL(5, 2) COMMENT '단백질(kg)',
ADD COLUMN lean_body_mass DECIMAL(5, 2) COMMENT '제지방량(kg)',
ADD COLUMN visceral_fat_level INT COMMENT '내장지방레벨 (1-30)',
ADD COLUMN waist_hip_ratio DECIMAL(4, 2) COMMENT '복부지방률 (0.00-1.99)';

-- 추가된 컬럼 확인
DESCRIBE InBody;

-- 완료 메시지
SELECT '✅ InBody 테이블에 5개 필수 컬럼 추가 완료!' AS message;



