-- 일주일치 테스트 데이터 추가 (기존 사용자 ID: 1 기준)

SET @user_id = 1;

-- =================================================================
-- DAY 4 (7일 전)
-- =================================================================
INSERT INTO MealLog (user_id, meal_date, meal_type) VALUES (@user_id, CURDATE() - INTERVAL 7 DAY, 1);
SET @meal_log_id = LAST_INSERT_ID();
INSERT INTO LoggedFood (meal_log_id, food_name, calories, protein, fat, carbs) VALUES (@meal_log_id, '아침식사', 400, 20, 15, 45);

INSERT INTO MealLog (user_id, meal_date, meal_type) VALUES (@user_id, CURDATE() - INTERVAL 7 DAY, 2);
SET @meal_log_id = LAST_INSERT_ID();
INSERT INTO LoggedFood (meal_log_id, food_name, calories, protein, fat, carbs) VALUES (@meal_log_id, '점심식사', 600, 35, 20, 60);

INSERT INTO MealLog (user_id, meal_date, meal_type) VALUES (@user_id, CURDATE() - INTERVAL 7 DAY, 3);
SET @meal_log_id = LAST_INSERT_ID();
INSERT INTO LoggedFood (meal_log_id, food_name, calories, protein, fat, carbs) VALUES (@meal_log_id, '저녁식사', 550, 30, 18, 55);

INSERT INTO WorkoutPlan (user_id, plan_date, status, memo) VALUES (@user_id, CURDATE() - INTERVAL 7 DAY, 'completed', '가슴 운동');
SET @plan_id = LAST_INSERT_ID();
INSERT INTO PlannedSet (plan_id, exercise_id, set_number, status, target_weight_kg, actual_weight_kg, target_reps, actual_reps) VALUES
(@plan_id, 1, 1, 'completed', 60.0, 60.0, 10, 10),
(@plan_id, 1, 2, 'completed', 60.0, 60.0, 10, 9),
(@plan_id, 1, 3, 'completed', 60.0, 60.0, 10, 8);

-- =================================================================
-- DAY 5 (6일 전)
-- =================================================================
INSERT INTO MealLog (user_id, meal_date, meal_type) VALUES (@user_id, CURDATE() - INTERVAL 6 DAY, 1);
SET @meal_log_id = LAST_INSERT_ID();
INSERT INTO LoggedFood (meal_log_id, food_name, calories, protein, fat, carbs) VALUES (@meal_log_id, '프로틴 쉐이크', 250, 30, 5, 20);

INSERT INTO MealLog (user_id, meal_date, meal_type) VALUES (@user_id, CURDATE() - INTERVAL 6 DAY, 2);
SET @meal_log_id = LAST_INSERT_ID();
INSERT INTO LoggedFood (meal_log_id, food_name, calories, protein, fat, carbs) VALUES (@meal_log_id, '닭가슴살 볶음밥', 650, 40, 15, 70);

INSERT INTO WorkoutPlan (user_id, plan_date, status, memo) VALUES (@user_id, CURDATE() - INTERVAL 6 DAY, 'completed', '등 운동');
SET @plan_id = LAST_INSERT_ID();
INSERT INTO PlannedSet (plan_id, exercise_id, set_number, status, target_weight_kg, actual_weight_kg, target_reps, actual_reps) VALUES
(@plan_id, 2, 1, 'completed', 100.0, 100.0, 5, 5),
(@plan_id, 2, 2, 'completed', 100.0, 100.0, 5, 5),
(@plan_id, 2, 3, 'completed', 100.0, 100.0, 5, 4);

-- =================================================================
-- DAY 6 (5일 전)
-- =================================================================
INSERT INTO MealLog (user_id, meal_date, meal_type) VALUES (@user_id, CURDATE() - INTERVAL 5 DAY, 1);
SET @meal_log_id = LAST_INSERT_ID();
INSERT INTO LoggedFood (meal_log_id, food_name, calories, protein, fat, carbs) VALUES (@meal_log_id, '오트밀', 350, 12, 8, 55);

INSERT INTO MealLog (user_id, meal_date, meal_type) VALUES (@user_id, CURDATE() - INTERVAL 5 DAY, 2);
SET @meal_log_id = LAST_INSERT_ID();
INSERT INTO LoggedFood (meal_log_id, food_name, calories, protein, fat, carbs) VALUES (@meal_log_id, '연어 스테이크', 700, 45, 25, 40);

INSERT INTO WorkoutPlan (user_id, plan_date, status, memo) VALUES (@user_id, CURDATE() - INTERVAL 5 DAY, 'completed', '하체 운동');
SET @plan_id = LAST_INSERT_ID();
INSERT INTO PlannedSet (plan_id, exercise_id, set_number, status, target_weight_kg, actual_weight_kg, target_reps, actual_reps) VALUES
(@plan_id, 3, 1, 'completed', 80.0, 80.0, 8, 8),
(@plan_id, 3, 2, 'completed', 80.0, 80.0, 8, 8),
(@plan_id, 3, 3, 'completed', 80.0, 80.0, 8, 7),
(@plan_id, 8, 1, 'completed', 120.0, 120.0, 12, 12),
(@plan_id, 8, 2, 'completed', 120.0, 120.0, 12, 10);

-- =================================================================
-- DAY 7 (4일 전)
-- =================================================================
INSERT INTO MealLog (user_id, meal_date, meal_type) VALUES (@user_id, CURDATE() - INTERVAL 4 DAY, 1);
SET @meal_log_id = LAST_INSERT_ID();
INSERT INTO LoggedFood (meal_log_id, food_name, calories, protein, fat, carbs) VALUES (@meal_log_id, '그릭요거트', 200, 15, 5, 20);

INSERT INTO MealLog (user_id, meal_date, meal_type) VALUES (@user_id, CURDATE() - INTERVAL 4 DAY, 2);
SET @meal_log_id = LAST_INSERT_ID();
INSERT INTO LoggedFood (meal_log_id, food_name, calories, protein, fat, carbs) VALUES (@meal_log_id, '소고기 샐러드', 500, 35, 20, 30);

INSERT INTO WorkoutPlan (user_id, plan_date, status, memo) VALUES (@user_id, CURDATE() - INTERVAL 4 DAY, 'completed', '어깨 운동');
SET @plan_id = LAST_INSERT_ID();
INSERT INTO PlannedSet (plan_id, exercise_id, set_number, status, target_weight_kg, actual_weight_kg, target_reps, actual_reps) VALUES
(@plan_id, 4, 1, 'completed', 40.0, 40.0, 10, 10),
(@plan_id, 4, 2, 'completed', 40.0, 40.0, 10, 9),
(@plan_id, 4, 3, 'completed', 40.0, 40.0, 10, 8);

-- =================================================================
-- DAY 8 (3일 전)
-- =================================================================
INSERT INTO MealLog (user_id, meal_date, meal_type) VALUES (@user_id, CURDATE() - INTERVAL 3 DAY, 1);
SET @meal_log_id = LAST_INSERT_ID();
INSERT INTO LoggedFood (meal_log_id, food_name, calories, protein, fat, carbs) VALUES (@meal_log_id, '계란후라이', 300, 18, 15, 10);

INSERT INTO MealLog (user_id, meal_date, meal_type) VALUES (@user_id, CURDATE() - INTERVAL 3 DAY, 2);
SET @meal_log_id = LAST_INSERT_ID();
INSERT INTO LoggedFood (meal_log_id, food_name, calories, protein, fat, carbs) VALUES (@meal_log_id, '치킨 샐러드', 450, 40, 12, 35);

INSERT INTO MealLog (user_id, meal_date, meal_type) VALUES (@user_id, CURDATE() - INTERVAL 3 DAY, 3);
SET @meal_log_id = LAST_INSERT_ID();
INSERT INTO LoggedFood (meal_log_id, food_name, calories, protein, fat, carbs) VALUES (@meal_log_id, '현미밥 정식', 600, 30, 15, 70);

INSERT INTO WorkoutPlan (user_id, plan_date, status, memo) VALUES (@user_id, CURDATE() - INTERVAL 3 DAY, 'completed', '가슴+어깨');
SET @plan_id = LAST_INSERT_ID();
INSERT INTO PlannedSet (plan_id, exercise_id, set_number, status, target_weight_kg, actual_weight_kg, target_reps, actual_reps) VALUES
(@plan_id, 1, 1, 'completed', 65.0, 65.0, 10, 10),
(@plan_id, 1, 2, 'completed', 65.0, 65.0, 10, 9),
(@plan_id, 4, 1, 'completed', 42.5, 42.5, 8, 8);

-- =================================================================
-- 완료 메시지
-- =================================================================
SELECT '✅ 일주일치 테스트 데이터 추가 완료!' AS Result;
SELECT COUNT(*) AS '총 식단 기록 수' FROM MealLog WHERE user_id = @user_id;
SELECT COUNT(*) AS '총 운동 계획 수' FROM WorkoutPlan WHERE user_id = @user_id;


