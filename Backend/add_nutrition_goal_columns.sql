-- Goal 테이블에 영양소 목표 컬럼 추가
-- AI가 추천한 영양소를 목표로 설정하고, 사용자가 직접 수정할 수 있도록 함

USE q_pt;

-- 영양소 목표 컬럼 추가
ALTER TABLE Goal
ADD COLUMN target_calories INT COMMENT '목표 일일 칼로리(kcal)',
ADD COLUMN target_protein DECIMAL(6, 2) COMMENT '목표 일일 단백질(g)',
ADD COLUMN target_carbs DECIMAL(6, 2) COMMENT '목표 일일 탄수화물(g)',
ADD COLUMN target_fat DECIMAL(6, 2) COMMENT '목표 일일 지방(g)',
ADD COLUMN goal_type ENUM('weight_loss', 'muscle_gain', 'maintenance', 'custom') DEFAULT 'custom' COMMENT '목표 타입';

-- 확인
DESCRIBE Goal;












