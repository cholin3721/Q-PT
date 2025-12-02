-- =================================================================
-- 기존 Routine/RoutineSet 테이블에 더미 데이터 추가
-- =================================================================

USE q_pt;

-- 기존 루틴 데이터 삭제 (있다면)
DELETE FROM RoutineSet WHERE routine_id IN (SELECT routine_id FROM Routine WHERE user_id = 1);
DELETE FROM Routine WHERE user_id = 1;

-- =================================================================
-- 상체 루틴 (Upper Body Strength)
-- =================================================================
INSERT INTO Routine (user_id, routine_name, description) VALUES
(1, 'Upper Body Strength', '가슴, 어깨, 팔 집중 루틴');
SET @upper_body_routine_id = LAST_INSERT_ID();

-- 상체 루틴 세트들
INSERT INTO RoutineSet (routine_id, exercise_id, display_order, set_number, target_weight_kg, target_reps) VALUES
-- 벤치프레스 (exercise_id = 1) - 4세트
(@upper_body_routine_id, 1, 1, 1, 60.0, 10),
(@upper_body_routine_id, 1, 1, 2, 60.0, 10),
(@upper_body_routine_id, 1, 1, 3, 60.0, 10),
(@upper_body_routine_id, 1, 1, 4, 60.0, 10),

-- 오버헤드 프레스 (exercise_id = 4) - 3세트
(@upper_body_routine_id, 4, 2, 1, 40.0, 8),
(@upper_body_routine_id, 4, 2, 2, 40.0, 8),
(@upper_body_routine_id, 4, 2, 3, 40.0, 8),

-- 랫풀다운 (exercise_id = 7) - 3세트
(@upper_body_routine_id, 7, 3, 1, 50.0, 12),
(@upper_body_routine_id, 7, 3, 2, 50.0, 12),
(@upper_body_routine_id, 7, 3, 3, 50.0, 12);

-- =================================================================
-- 하체 루틴 (Lower Body Power)
-- =================================================================
INSERT INTO Routine (user_id, routine_name, description) VALUES
(1, 'Lower Body Power', '하체 집중 파워 루틴');
SET @lower_body_routine_id = LAST_INSERT_ID();

-- 하체 루틴 세트들
INSERT INTO RoutineSet (routine_id, exercise_id, display_order, set_number, target_weight_kg, target_reps) VALUES
-- 스쿼트 (exercise_id = 3) - 4세트
(@lower_body_routine_id, 3, 1, 1, 80.0, 8),
(@lower_body_routine_id, 3, 1, 2, 80.0, 8),
(@lower_body_routine_id, 3, 1, 3, 80.0, 8),
(@lower_body_routine_id, 3, 1, 4, 80.0, 8),

-- 레그 프레스 (exercise_id = 8) - 3세트
(@lower_body_routine_id, 8, 2, 1, 120.0, 12),
(@lower_body_routine_id, 8, 2, 2, 120.0, 12),
(@lower_body_routine_id, 8, 2, 3, 120.0, 12);

-- 러닝 (exercise_id = 6) - 1세트 (유산소, duration 사용)
INSERT INTO RoutineSet (routine_id, exercise_id, display_order, set_number, target_duration_minutes) VALUES
(@lower_body_routine_id, 6, 3, 1, 20);

-- =================================================================
-- 확인
-- =================================================================
SELECT '=== Routines ===' as '';
SELECT * FROM Routine;

SELECT '=== Routine Sets with Exercise Names ===' as '';
SELECT 
    r.routine_name,
    e.exercise_name,
    rs.display_order,
    rs.set_number,
    rs.target_weight_kg,
    rs.target_reps,
    rs.target_duration_minutes
FROM RoutineSet rs
JOIN Routine r ON rs.routine_id = r.routine_id
JOIN Exercise e ON rs.exercise_id = e.exercise_id
ORDER BY r.routine_id, rs.display_order, rs.set_number;

SELECT '=== Summary ===' as '';
SELECT 
    r.routine_name,
    COUNT(DISTINCT rs.exercise_id) as exercise_count,
    COUNT(rs.routine_set_id) as total_sets
FROM Routine r
LEFT JOIN RoutineSet rs ON r.routine_id = rs.routine_id
GROUP BY r.routine_id;












