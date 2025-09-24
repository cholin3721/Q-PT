-- =================================================================
-- 경고: 아래 코드는 테이블의 모든 데이터를 삭제합니다.
-- =================================================================
SET FOREIGN_KEY_CHECKS = 0; -- 외래 키 제약 조건 비활성화

-- 데이터 초기화
TRUNCATE TABLE User;
TRUNCATE TABLE InBody;
TRUNCATE TABLE Goal;
TRUNCATE TABLE AIFeedback;
TRUNCATE TABLE MealLog;
TRUNCATE TABLE LoggedFood;
TRUNCATE TABLE WorkoutPlan;
TRUNCATE TABLE PlannedSet;
TRUNCATE TABLE Routine;
TRUNCATE TABLE RoutineSet;
TRUNCATE TABLE IntervalPhase;
-- TRUNCATE TABLE MuscleGroup; -- 마스터 데이터는 유지하거나 필요시 초기화
-- TRUNCATE TABLE Exercise;
-- TRUNCATE TABLE ExerciseMuscleGroup;

SET FOREIGN_KEY_CHECKS = 1; -- 외래 키 제약 조건 활성화

-- =================================================================
-- 1. 마스터 데이터 및 사용자 생성
-- =================================================================

-- 운동 부위 (이미 있다면 이 부분은 건너뛰세요)
INSERT INTO MuscleGroup (name) VALUES ('가슴'), ('등'), ('어깨'), ('하체'), ('팔'), ('복근')
ON DUPLICATE KEY UPDATE name=name; -- 중복 시 무시

-- 기본 운동 (이미 있다면 이 부분은 건너뛰세요)
INSERT INTO Exercise (exercise_name, exercise_type) VALUES
('벤치프레스', 'weight'), ('데드리프트', 'weight'), ('스쿼트', 'weight'), ('오버헤드 프레스', 'weight'), ('바벨 로우', 'weight'), ('러닝', 'cardio'), ('랫풀다운', 'weight'), ('레그 프레스', 'weight')
ON DUPLICATE KEY UPDATE exercise_name=exercise_name; -- 중복 시 무시

-- 운동-부위 연결 (이미 있다면 이 부분은 건너뛰세요)
INSERT IGNORE INTO ExerciseMuscleGroup (exercise_id, muscle_group_id) VALUES
(1, 1), (1, 3), (1, 5), -- 벤치프레스: 가슴, 어깨, 팔
(2, 2), (2, 4),         -- 데드리프트: 등, 하체
(3, 4),                 -- 스쿼트: 하체
(4, 3), (4, 5),         -- 오버헤드 프레스: 어깨, 팔
(5, 2), (5, 5),         -- 바벨 로우: 등, 팔
(6, 4),                 -- 러닝: 하체
(7, 2),                 -- 랫풀다운: 등
(8, 4);                 -- 레그 프레스: 하체


-- 사용자(김철중) 생성
INSERT INTO User (provider, provider_id, nickname, email) VALUES ('google', '123456789012345678901', '김철중', 'cholin3721@example.com');
SET @user_id = LAST_INSERT_ID();

-- 인바디 및 목표 데이터 생성
INSERT INTO InBody (user_id, test_date, height, weight, muscle_mass, fat_mass) VALUES (@user_id, CURDATE() - INTERVAL 3 DAY, 175.0, 75.0, 35.0, 15.0);
INSERT INTO Goal (user_id, target_weight, target_muscle_mass, target_fat_mass) VALUES (@user_id, 72.0, 37.0, 12.0);


-- =================================================================
-- 2. 3일치 데이터 생성
-- =================================================================

-- ---------- DAY 1 (2일 전) ----------
-- 식단 기록
INSERT INTO MealLog (user_id, meal_date, meal_type) VALUES (@user_id, CURDATE() - INTERVAL 2 DAY, 1);
SET @meal_log_id = LAST_INSERT_ID();
INSERT INTO LoggedFood (meal_log_id, food_name, calories, protein, fat, carbs) VALUES (@meal_log_id, '닭가슴살 샐러드', 350, 40, 15, 10);

INSERT INTO MealLog (user_id, meal_date, meal_type) VALUES (@user_id, CURDATE() - INTERVAL 2 DAY, 2);
SET @meal_log_id = LAST_INSERT_ID();
INSERT INTO LoggedFood (meal_log_id, food_name, calories, protein, fat, carbs) VALUES (@meal_log_id, '현미밥과 소고기', 550, 35, 18, 50);

-- 운동 기록 (가슴, 어깨)
INSERT INTO WorkoutPlan (user_id, plan_date, status, memo) VALUES (@user_id, CURDATE() - INTERVAL 2 DAY, 'completed', '가슴과 어깨 운동 집중');
SET @plan_id = LAST_INSERT_ID();
-- 벤치프레스
INSERT INTO PlannedSet (plan_id, exercise_id, set_number, status, target_weight_kg, actual_weight_kg, target_reps, actual_reps) VALUES
(@plan_id, 1, 1, 'completed', 60.0, 60.0, 10, 10),
(@plan_id, 1, 2, 'completed', 60.0, 60.0, 10, 10),
(@plan_id, 1, 3, 'completed', 60.0, 60.0, 10, 9);
-- 오버헤드 프레스
INSERT INTO PlannedSet (plan_id, exercise_id, set_number, status, target_weight_kg, actual_weight_kg, target_reps, actual_reps) VALUES
(@plan_id, 4, 1, 'completed', 40.0, 40.0, 8, 8),
(@plan_id, 4, 2, 'completed', 40.0, 40.0, 8, 7);


-- ---------- DAY 2 (1일 전, 어제) ----------
-- 식단 기록
INSERT INTO MealLog (user_id, meal_date, meal_type) VALUES (@user_id, CURDATE() - INTERVAL 1 DAY, 1);
SET @meal_log_id = LAST_INSERT_ID();
INSERT INTO LoggedFood (meal_log_id, food_name, calories, protein, fat, carbs) VALUES (@meal_log_id, '프로틴 쉐이크', 250, 30, 5, 15);

INSERT INTO MealLog (user_id, meal_date, meal_type) VALUES (@user_id, CURDATE() - INTERVAL 1 DAY, 2);
SET @meal_log_id = LAST_INSERT_ID();
INSERT INTO LoggedFood (meal_log_id, food_name, calories, protein, fat, carbs) VALUES (@meal_log_id, '일반식 백반', 700, 40, 25, 80);

INSERT INTO MealLog (user_id, meal_date, meal_type) VALUES (@user_id, CURDATE() - INTERVAL 1 DAY, 3);
SET @meal_log_id = LAST_INSERT_ID();
INSERT INTO LoggedFood (meal_log_id, food_name, calories, protein, fat, carbs) VALUES (@meal_log_id, '고구마와 계란', 400, 20, 10, 40);

-- 운동 기록 (등, 팔)
INSERT INTO WorkoutPlan (user_id, plan_date, status, memo) VALUES (@user_id, CURDATE() - INTERVAL 1 DAY, 'completed', '등 운동 위주');
SET @plan_id = LAST_INSERT_ID();
-- 랫풀다운
INSERT INTO PlannedSet (plan_id, exercise_id, set_number, status, target_weight_kg, actual_weight_kg, target_reps, actual_reps) VALUES
(@plan_id, 7, 1, 'completed', 50.0, 50.0, 12, 12),
(@plan_id, 7, 2, 'completed', 50.0, 50.0, 12, 11),
(@plan_id, 7, 3, 'completed', 50.0, 50.0, 12, 10);
-- 바벨 로우
INSERT INTO PlannedSet (plan_id, exercise_id, set_number, status, target_weight_kg, actual_weight_kg, target_reps, actual_reps) VALUES
(@plan_id, 5, 1, 'completed', 55.0, 55.0, 10, 10),
(@plan_id, 5, 2, 'completed', 55.0, 55.0, 10, 9);


-- ---------- DAY 3 (오늘) ----------
-- 식단 기록
INSERT INTO MealLog (user_id, meal_date, meal_type) VALUES (@user_id, CURDATE(), 1);
SET @meal_log_id = LAST_INSERT_ID();
INSERT INTO LoggedFood (meal_log_id, food_name, calories, protein, fat, carbs) VALUES (@meal_log_id, '오트밀과 견과류', 450, 15, 20, 50);

-- 운동 기록 (하체, 진행중)
INSERT INTO WorkoutPlan (user_id, plan_date, status, memo) VALUES (@user_id, CURDATE(), 'active', '오늘은 하체 하는 날');
SET @plan_id = LAST_INSERT_ID();
-- 스쿼트
INSERT INTO PlannedSet (plan_id, exercise_id, set_number, status, target_weight_kg, actual_weight_kg, target_reps, actual_reps) VALUES
(@plan_id, 3, 1, 'completed', 80.0, 80.0, 8, 8),
(@plan_id, 3, 2, 'pending', 80.0, NULL, 8, NULL),
(@plan_id, 3, 3, 'pending', 80.0, NULL, 8, NULL);
-- 레그 프레스
INSERT INTO PlannedSet (plan_id, exercise_id, set_number, status, target_weight_kg, actual_weight_kg, target_reps, actual_reps) VALUES
(@plan_id, 8, 1, 'pending', 120.0, NULL, 12, NULL),
(@plan_id, 8, 2, 'pending', 120.0, NULL, 12, NULL);
-- 러닝
INSERT INTO PlannedSet (plan_id, exercise_id, set_number, status, target_duration_minutes) VALUES
(@plan_id, 6, 1, 'pending', 20);