-- =================================================================
-- 최근 7일 운동 데이터 테스트용 더미 데이터
-- =================================================================

USE q_pt;

-- 기존 운동 데이터 삭제
DELETE FROM PlannedSet WHERE plan_id IN (SELECT plan_id FROM WorkoutPlan WHERE user_id = 1);
DELETE FROM WorkoutPlan WHERE user_id = 1;

-- =================================================================
-- DAY 1: 3일 전 (가슴, 어깨) - 완료
-- =================================================================
INSERT INTO WorkoutPlan (user_id, plan_date, status, memo) 
VALUES (1, CURDATE() - INTERVAL 3 DAY, 'completed', '가슴과 어깨 집중 운동');
SET @plan_id = LAST_INSERT_ID();

-- 벤치프레스 (exercise_id = 1)
INSERT INTO PlannedSet (plan_id, exercise_id, display_order, set_number, status, target_weight_kg, actual_weight_kg, target_reps, actual_reps) VALUES
(@plan_id, 1, 1, 1, 'completed', 60.0, 60.0, 10, 10),
(@plan_id, 1, 1, 2, 'completed', 60.0, 60.0, 10, 10),
(@plan_id, 1, 1, 3, 'completed', 60.0, 60.0, 10, 9),
(@plan_id, 1, 1, 4, 'completed', 60.0, 60.0, 10, 8);

-- 오버헤드 프레스 (exercise_id = 4)
INSERT INTO PlannedSet (plan_id, exercise_id, display_order, set_number, status, target_weight_kg, actual_weight_kg, target_reps, actual_reps) VALUES
(@plan_id, 4, 2, 1, 'completed', 40.0, 40.0, 8, 8),
(@plan_id, 4, 2, 2, 'completed', 40.0, 40.0, 8, 8),
(@plan_id, 4, 2, 3, 'completed', 40.0, 40.0, 8, 7);

-- =================================================================
-- DAY 2: 어제 (등, 팔) - 완료
-- =================================================================
INSERT INTO WorkoutPlan (user_id, plan_date, status, memo) 
VALUES (1, CURDATE() - INTERVAL 1 DAY, 'completed', '등과 팔 운동');
SET @plan_id = LAST_INSERT_ID();

-- 랫풀다운 (exercise_id = 7)
INSERT INTO PlannedSet (plan_id, exercise_id, display_order, set_number, status, target_weight_kg, actual_weight_kg, target_reps, actual_reps) VALUES
(@plan_id, 7, 1, 1, 'completed', 50.0, 50.0, 12, 12),
(@plan_id, 7, 1, 2, 'completed', 50.0, 50.0, 12, 11),
(@plan_id, 7, 1, 3, 'completed', 50.0, 50.0, 12, 10),
(@plan_id, 7, 1, 4, 'completed', 50.0, 50.0, 12, 10);

-- 바벨 로우 (exercise_id = 5)
INSERT INTO PlannedSet (plan_id, exercise_id, display_order, set_number, status, target_weight_kg, actual_weight_kg, target_reps, actual_reps) VALUES
(@plan_id, 5, 2, 1, 'completed', 55.0, 55.0, 10, 10),
(@plan_id, 5, 2, 2, 'completed', 55.0, 55.0, 10, 9),
(@plan_id, 5, 2, 3, 'skipped', 55.0, NULL, 10, NULL);

-- =================================================================
-- DAY 3: 오늘 (하체) - 진행중
-- =================================================================
INSERT INTO WorkoutPlan (user_id, plan_date, status, memo) 
VALUES (1, CURDATE(), 'active', '하체의 날');
SET @plan_id = LAST_INSERT_ID();

-- 스쿼트 (exercise_id = 3)
INSERT INTO PlannedSet (plan_id, exercise_id, display_order, set_number, status, target_weight_kg, actual_weight_kg, target_reps, actual_reps) VALUES
(@plan_id, 3, 1, 1, 'completed', 80.0, 80.0, 8, 8),
(@plan_id, 3, 1, 2, 'completed', 80.0, 80.0, 8, 8),
(@plan_id, 3, 1, 3, 'pending', 80.0, NULL, 8, NULL),
(@plan_id, 3, 1, 4, 'pending', 80.0, NULL, 8, NULL);

-- 레그 프레스 (exercise_id = 8)
INSERT INTO PlannedSet (plan_id, exercise_id, display_order, set_number, status, target_weight_kg, actual_weight_kg, target_reps, actual_reps) VALUES
(@plan_id, 8, 2, 1, 'pending', 120.0, NULL, 12, NULL),
(@plan_id, 8, 2, 2, 'pending', 120.0, NULL, 12, NULL),
(@plan_id, 8, 2, 3, 'pending', 120.0, NULL, 12, NULL);

-- 러닝 (exercise_id = 6, cardio)
INSERT INTO PlannedSet (plan_id, exercise_id, display_order, set_number, status, target_duration_minutes, actual_duration_minutes) VALUES
(@plan_id, 6, 3, 1, 'pending', 20, NULL);

-- =================================================================
-- 결과 확인
-- =================================================================
SELECT '=== WorkoutPlan ===' as '';
SELECT plan_id, plan_date, status, memo FROM WorkoutPlan WHERE user_id = 1 ORDER BY plan_date DESC;

SELECT '=== PlannedSet with Exercise Names ===' as '';
SELECT 
    wp.plan_date,
    wp.status as plan_status,
    e.exercise_name,
    ps.set_number,
    ps.status as set_status,
    ps.target_weight_kg,
    ps.actual_weight_kg,
    ps.target_reps,
    ps.actual_reps,
    ps.target_duration_minutes,
    ps.actual_duration_minutes
FROM PlannedSet ps
JOIN WorkoutPlan wp ON ps.plan_id = wp.plan_id
JOIN Exercise e ON ps.exercise_id = e.exercise_id
WHERE wp.user_id = 1
ORDER BY wp.plan_date DESC, ps.display_order, ps.set_number;

SELECT '=== Summary ===' as '';
SELECT 
    COUNT(DISTINCT wp.plan_id) as total_workout_days,
    COUNT(ps.set_id) as total_sets,
    SUM(CASE WHEN ps.status = 'completed' THEN 1 ELSE 0 END) as completed_sets,
    SUM(CASE WHEN ps.status = 'pending' THEN 1 ELSE 0 END) as pending_sets,
    SUM(CASE WHEN ps.status = 'skipped' THEN 1 ELSE 0 END) as skipped_sets
FROM WorkoutPlan wp
JOIN PlannedSet ps ON wp.plan_id = ps.plan_id
WHERE wp.user_id = 1 
AND wp.plan_date >= CURDATE() - INTERVAL 7 DAY;


