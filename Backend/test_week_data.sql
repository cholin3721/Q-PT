USE q_pt;

-- 기존 최근 일주일 데이터 삭제 (2025-10-22 ~ 2025-10-28)
DELETE FROM PlannedSet WHERE plan_id IN (
  SELECT plan_id FROM WorkoutPlan 
  WHERE user_id = 1 
  AND plan_date BETWEEN '2025-10-22' AND '2025-10-28'
);

DELETE FROM WorkoutPlan 
WHERE user_id = 1 
AND plan_date BETWEEN '2025-10-22' AND '2025-10-28';

DELETE FROM LoggedFood WHERE meal_log_id IN (
  SELECT meal_log_id FROM MealLog 
  WHERE user_id = 1 
  AND meal_date BETWEEN '2025-10-22' AND '2025-10-28'
);

DELETE FROM MealLog 
WHERE user_id = 1 
AND meal_date BETWEEN '2025-10-22' AND '2025-10-28';

-- ===================================================================
-- 10월 22일 (화) - 좋은 날! 운동도 완벽, 식단도 균형잡힘 (2200kcal, 단백질 150g)
-- ===================================================================

-- 식단
INSERT INTO MealLog (user_id, meal_date, meal_type) VALUES (1, '2025-10-22', 1);  -- 아침
SET @meal_id = LAST_INSERT_ID();
INSERT INTO LoggedFood (meal_log_id, food_name, serving_size_grams, calories, protein, carbs, fat) VALUES
(@meal_id, '오트밀', 80, 300, 10, 54, 6),
(@meal_id, '바나나', 118, 105, 1, 27, 0),
(@meal_id, '아몬드', 30, 170, 6, 6, 15),
(@meal_id, '저지방우유', 200, 100, 8, 12, 2);

INSERT INTO MealLog (user_id, meal_date, meal_type) VALUES (1, '2025-10-22', 2);  -- 점심
SET @meal_id = LAST_INSERT_ID();
INSERT INTO LoggedFood (meal_log_id, food_name, serving_size_grams, calories, protein, carbs, fat) VALUES
(@meal_id, '현미밥', 210, 330, 7, 70, 3),
(@meal_id, '닭가슴살 구이', 100, 165, 31, 0, 4),
(@meal_id, '브로콜리', 150, 55, 4, 11, 1),
(@meal_id, '고구마', 100, 130, 2, 30, 0);

INSERT INTO MealLog (user_id, meal_date, meal_type) VALUES (1, '2025-10-22', 3);  -- 저녁
SET @meal_id = LAST_INSERT_ID();
INSERT INTO LoggedFood (meal_log_id, food_name, serving_size_grams, calories, protein, carbs, fat) VALUES
(@meal_id, '연어 구이', 150, 280, 40, 0, 13),
(@meal_id, '퀴노아', 100, 222, 8, 39, 4),
(@meal_id, '샐러드', 150, 80, 2, 8, 5);

INSERT INTO MealLog (user_id, meal_date, meal_type) VALUES (1, '2025-10-22', 4);  -- 간식
SET @meal_id = LAST_INSERT_ID();
INSERT INTO LoggedFood (meal_log_id, food_name, serving_size_grams, calories, protein, carbs, fat) VALUES
(@meal_id, '프로틴 셰이크', 30, 120, 24, 3, 2),
(@meal_id, '사과', 182, 95, 0, 25, 0);

-- 운동: 모든 세트 완료
INSERT INTO WorkoutPlan (user_id, plan_date, status) VALUES (1, '2025-10-22', 'completed');
SET @plan_id = LAST_INSERT_ID();

INSERT INTO PlannedSet (plan_id, exercise_id, display_order, set_number, status, target_weight_kg, target_reps, actual_weight_kg, actual_reps) VALUES
(@plan_id, 1, 1, 1, 'completed', 100, 10, 100, 10),
(@plan_id, 1, 1, 2, 'completed', 100, 10, 100, 10),
(@plan_id, 1, 1, 3, 'completed', 100, 10, 100, 11),
(@plan_id, 1, 1, 4, 'completed', 100, 10, 100, 10),
(@plan_id, 2, 2, 1, 'completed', 80, 12, 80, 12),
(@plan_id, 2, 2, 2, 'completed', 80, 12, 80, 12),
(@plan_id, 2, 2, 3, 'completed', 80, 12, 80, 13),
(@plan_id, 3, 3, 1, 'completed', 60, 10, 60, 10),
(@plan_id, 3, 3, 2, 'completed', 60, 10, 60, 10),
(@plan_id, 3, 3, 3, 'completed', 60, 10, 60, 11);

-- ===================================================================
-- 10월 23일 (수) - 보통 날: 운동은 했지만 식단 과다 (3000kcal, 지방 많음)
-- ===================================================================

INSERT INTO MealLog (user_id, meal_date, meal_type) VALUES (1, '2025-10-23', 1);
SET @meal_id = LAST_INSERT_ID();
INSERT INTO LoggedFood (meal_log_id, food_name, serving_size_grams, calories, protein, carbs, fat) VALUES
(@meal_id, '베이컨', 60, 270, 12, 1, 25),
(@meal_id, '계란 후라이', 100, 180, 13, 1, 14),
(@meal_id, '토스트', 60, 240, 8, 45, 3);

INSERT INTO MealLog (user_id, meal_date, meal_type) VALUES (1, '2025-10-23', 2);
SET @meal_id = LAST_INSERT_ID();
INSERT INTO LoggedFood (meal_log_id, food_name, serving_size_grams, calories, protein, carbs, fat) VALUES
(@meal_id, '피자', 400, 800, 32, 90, 36),
(@meal_id, '콜라', 350, 140, 0, 39, 0),
(@meal_id, '감자튀김', 150, 365, 4, 48, 17);

INSERT INTO MealLog (user_id, meal_date, meal_type) VALUES (1, '2025-10-23', 3);
SET @meal_id = LAST_INSERT_ID();
INSERT INTO LoggedFood (meal_log_id, food_name, serving_size_grams, calories, protein, carbs, fat) VALUES
(@meal_id, '삼겹살', 150, 518, 17, 0, 50),
(@meal_id, '소주', 300, 420, 0, 0, 0),
(@meal_id, '쌈밥', 200, 300, 6, 60, 3);

-- 운동: 대부분 완료했지만 마지막 세트 포기
INSERT INTO WorkoutPlan (user_id, plan_date, status) VALUES (1, '2025-10-23', 'active');
SET @plan_id = LAST_INSERT_ID();

INSERT INTO PlannedSet (plan_id, exercise_id, display_order, set_number, status, target_weight_kg, target_reps, actual_weight_kg, actual_reps) VALUES
(@plan_id, 4, 1, 1, 'completed', 70, 8, 70, 8),
(@plan_id, 4, 1, 2, 'completed', 70, 8, 70, 7),
(@plan_id, 4, 1, 3, 'skipped', 70, 8, NULL, NULL),
(@plan_id, 5, 2, 1, 'completed', 50, 12, 50, 12),
(@plan_id, 5, 2, 2, 'completed', 50, 12, 50, 10),
(@plan_id, 5, 2, 3, 'skipped', 50, 12, NULL, NULL);

-- ===================================================================
-- 10월 24일 (목) - 좋은 날! 하체 집중 + 균형 식단 (2100kcal, 단백질 140g)
-- ===================================================================

INSERT INTO MealLog (user_id, meal_date, meal_type) VALUES (1, '2025-10-24', 1);
SET @meal_id = LAST_INSERT_ID();
INSERT INTO LoggedFood (meal_log_id, food_name, serving_size_grams, calories, protein, carbs, fat) VALUES
(@meal_id, '그릭 요거트', 170, 100, 10, 6, 5),
(@meal_id, '블루베리', 150, 85, 1, 21, 0),
(@meal_id, '그래놀라', 50, 210, 5, 38, 6);

INSERT INTO MealLog (user_id, meal_date, meal_type) VALUES (1, '2025-10-24', 2);
SET @meal_id = LAST_INSERT_ID();
INSERT INTO LoggedFood (meal_log_id, food_name, serving_size_grams, calories, protein, carbs, fat) VALUES
(@meal_id, '현미밥', 210, 330, 7, 70, 3),
(@meal_id, '소고기 안심', 120, 250, 36, 0, 11),
(@meal_id, '시금치나물', 100, 35, 3, 5, 1),
(@meal_id, '된장찌개', 250, 120, 8, 10, 5);

INSERT INTO MealLog (user_id, meal_date, meal_type) VALUES (1, '2025-10-24', 3);
SET @meal_id = LAST_INSERT_ID();
INSERT INTO LoggedFood (meal_log_id, food_name, serving_size_grams, calories, protein, carbs, fat) VALUES
(@meal_id, '참치 샐러드', 200, 200, 30, 5, 8),
(@meal_id, '고구마', 100, 130, 2, 30, 0),
(@meal_id, '두부', 150, 144, 15, 3, 9);

INSERT INTO MealLog (user_id, meal_date, meal_type) VALUES (1, '2025-10-24', 4);
SET @meal_id = LAST_INSERT_ID();
INSERT INTO LoggedFood (meal_log_id, food_name, serving_size_grams, calories, protein, carbs, fat) VALUES
(@meal_id, '프로틴바', 60, 200, 20, 20, 7),
(@meal_id, '저지방우유', 200, 100, 8, 12, 2);

-- 운동: 하체 집중, 모든 세트 완료
INSERT INTO WorkoutPlan (user_id, plan_date, status) VALUES (1, '2025-10-24', 'completed');
SET @plan_id = LAST_INSERT_ID();

INSERT INTO PlannedSet (plan_id, exercise_id, display_order, set_number, status, target_weight_kg, target_reps, actual_weight_kg, actual_reps) VALUES
(@plan_id, 1, 1, 1, 'completed', 120, 8, 120, 8),
(@plan_id, 1, 1, 2, 'completed', 120, 8, 120, 8),
(@plan_id, 1, 1, 3, 'completed', 120, 8, 120, 9),
(@plan_id, 1, 1, 4, 'completed', 120, 8, 120, 8),
(@plan_id, 6, 2, 1, 'completed', 80, 12, 80, 12),
(@plan_id, 6, 2, 2, 'completed', 80, 12, 80, 12),
(@plan_id, 6, 2, 3, 'completed', 80, 12, 80, 12),
(@plan_id, 7, 3, 1, 'completed', NULL, NULL, NULL, NULL),
(@plan_id, 7, 3, 2, 'completed', NULL, NULL, NULL, NULL);

UPDATE PlannedSet SET target_duration_minutes = 20, target_intensity = 'moderate' 
WHERE plan_id = @plan_id AND exercise_id = 7;

-- ===================================================================
-- 10월 25일 (금) - 나쁜 날: 운동 안함, 식단 부실 (1200kcal, 단백질 40g)
-- ===================================================================

INSERT INTO MealLog (user_id, meal_date, meal_type) VALUES (1, '2025-10-25', 1);
SET @meal_id = LAST_INSERT_ID();
INSERT INTO LoggedFood (meal_log_id, food_name, serving_size_grams, calories, protein, carbs, fat) VALUES
(@meal_id, '커피', 240, 5, 0, 1, 0),
(@meal_id, '크루아상', 60, 231, 5, 26, 12);

INSERT INTO MealLog (user_id, meal_date, meal_type) VALUES (1, '2025-10-25', 2);
SET @meal_id = LAST_INSERT_ID();
INSERT INTO LoggedFood (meal_log_id, food_name, serving_size_grams, calories, protein, carbs, fat) VALUES
(@meal_id, '컵라면', 65, 380, 8, 56, 14),
(@meal_id, '김밥', 300, 450, 12, 78, 10);

INSERT INTO MealLog (user_id, meal_date, meal_type) VALUES (1, '2025-10-25', 3);
SET @meal_id = LAST_INSERT_ID();
INSERT INTO LoggedFood (meal_log_id, food_name, serving_size_grams, calories, protein, carbs, fat) VALUES
(@meal_id, '치즈버거', 200, 354, 15, 33, 19);

-- 운동: 계획만 세우고 실행 안함
INSERT INTO WorkoutPlan (user_id, plan_date, status) VALUES (1, '2025-10-25', 'planned');
SET @plan_id = LAST_INSERT_ID();

INSERT INTO PlannedSet (plan_id, exercise_id, display_order, set_number, status, target_weight_kg, target_reps) VALUES
(@plan_id, 2, 1, 1, 'pending', 80, 10),
(@plan_id, 2, 1, 2, 'pending', 80, 10),
(@plan_id, 2, 1, 3, 'pending', 80, 10),
(@plan_id, 3, 2, 1, 'pending', 60, 10),
(@plan_id, 3, 2, 2, 'pending', 60, 10);

-- ===================================================================
-- 10월 26일 (토) - 좋은 날! 상체 + 유산소, 식단 완벽 (2300kcal, 단백질 160g)
-- ===================================================================

INSERT INTO MealLog (user_id, meal_date, meal_type) VALUES (1, '2025-10-26', 1);
SET @meal_id = LAST_INSERT_ID();
INSERT INTO LoggedFood (meal_log_id, food_name, serving_size_grams, calories, protein, carbs, fat) VALUES
(@meal_id, '계란 스크램블', 150, 220, 18, 2, 16),
(@meal_id, '통밀빵', 60, 160, 8, 28, 2),
(@meal_id, '아보카도', 100, 160, 2, 9, 15);

INSERT INTO MealLog (user_id, meal_date, meal_type) VALUES (1, '2025-10-26', 2);
SET @meal_id = LAST_INSERT_ID();
INSERT INTO LoggedFood (meal_log_id, food_name, serving_size_grams, calories, protein, carbs, fat) VALUES
(@meal_id, '현미밥', 210, 330, 7, 70, 3),
(@meal_id, '연어 구이', 150, 280, 40, 0, 13),
(@meal_id, '아스파라거스', 150, 40, 4, 8, 0);

INSERT INTO MealLog (user_id, meal_date, meal_type) VALUES (1, '2025-10-26', 3);
SET @meal_id = LAST_INSERT_ID();
INSERT INTO LoggedFood (meal_log_id, food_name, serving_size_grams, calories, protein, carbs, fat) VALUES
(@meal_id, '닭가슴살 샐러드', 200, 250, 35, 15, 8),
(@meal_id, '퀴노아', 100, 222, 8, 39, 4);

INSERT INTO MealLog (user_id, meal_date, meal_type) VALUES (1, '2025-10-26', 4);
SET @meal_id = LAST_INSERT_ID();
INSERT INTO LoggedFood (meal_log_id, food_name, serving_size_grams, calories, protein, carbs, fat) VALUES
(@meal_id, '프로틴 셰이크', 30, 120, 24, 3, 2),
(@meal_id, '호두', 30, 185, 4, 4, 18),
(@meal_id, '사과', 182, 95, 0, 25, 0);

-- 운동: 상체 + 유산소 완벽 수행
INSERT INTO WorkoutPlan (user_id, plan_date, status) VALUES (1, '2025-10-26', 'completed');
SET @plan_id = LAST_INSERT_ID();

INSERT INTO PlannedSet (plan_id, exercise_id, display_order, set_number, status, target_weight_kg, target_reps, actual_weight_kg, actual_reps) VALUES
(@plan_id, 2, 1, 1, 'completed', 80, 10, 80, 10),
(@plan_id, 2, 1, 2, 'completed', 80, 10, 80, 10),
(@plan_id, 2, 1, 3, 'completed', 80, 10, 80, 11),
(@plan_id, 2, 1, 4, 'completed', 80, 10, 80, 10),
(@plan_id, 4, 2, 1, 'completed', 70, 8, 70, 8),
(@plan_id, 4, 2, 2, 'completed', 70, 8, 70, 8),
(@plan_id, 4, 2, 3, 'completed', 70, 8, 70, 9),
(@plan_id, 5, 3, 1, 'completed', 50, 12, 50, 12),
(@plan_id, 5, 3, 2, 'completed', 50, 12, 50, 12),
(@plan_id, 5, 3, 3, 'completed', 50, 12, 50, 13),
(@plan_id, 7, 4, 1, 'completed', NULL, NULL, NULL, NULL),
(@plan_id, 7, 4, 2, 'completed', NULL, NULL, NULL, NULL);

UPDATE PlannedSet SET target_duration_minutes = 30, target_intensity = 'moderate' 
WHERE plan_id = @plan_id AND exercise_id = 7;

-- ===================================================================
-- 10월 27일 (일) - 보통 날: 운동 적게, 식단 적당 (1800kcal, 단백질 100g)
-- ===================================================================

INSERT INTO MealLog (user_id, meal_date, meal_type) VALUES (1, '2025-10-27', 1);
SET @meal_id = LAST_INSERT_ID();
INSERT INTO LoggedFood (meal_log_id, food_name, serving_size_grams, calories, protein, carbs, fat) VALUES
(@meal_id, '토스트', 30, 120, 4, 23, 2),
(@meal_id, '계란', 50, 78, 6, 1, 5),
(@meal_id, '우유', 250, 150, 8, 12, 8);

INSERT INTO MealLog (user_id, meal_date, meal_type) VALUES (1, '2025-10-27', 2);
SET @meal_id = LAST_INSERT_ID();
INSERT INTO LoggedFood (meal_log_id, food_name, serving_size_grams, calories, protein, carbs, fat) VALUES
(@meal_id, '비빔밥', 400, 560, 20, 90, 12),
(@meal_id, '미역국', 200, 50, 2, 5, 2);

INSERT INTO MealLog (user_id, meal_date, meal_type) VALUES (1, '2025-10-27', 3);
SET @meal_id = LAST_INSERT_ID();
INSERT INTO LoggedFood (meal_log_id, food_name, serving_size_grams, calories, protein, carbs, fat) VALUES
(@meal_id, '닭가슴살 샌드위치', 250, 420, 35, 45, 12),
(@meal_id, '샐러드', 150, 80, 2, 8, 5);

INSERT INTO MealLog (user_id, meal_date, meal_type) VALUES (1, '2025-10-27', 4);
SET @meal_id = LAST_INSERT_ID();
INSERT INTO LoggedFood (meal_log_id, food_name, serving_size_grams, calories, protein, carbs, fat) VALUES
(@meal_id, '바나나', 118, 105, 1, 27, 0),
(@meal_id, '프로틴바', 60, 200, 20, 20, 7);

-- 운동: 가벼운 운동만
INSERT INTO WorkoutPlan (user_id, plan_date, status) VALUES (1, '2025-10-27', 'completed');
SET @plan_id = LAST_INSERT_ID();

INSERT INTO PlannedSet (plan_id, exercise_id, display_order, set_number, status, target_weight_kg, target_reps, actual_weight_kg, actual_reps) VALUES
(@plan_id, 3, 1, 1, 'completed', 50, 12, 50, 12),
(@plan_id, 3, 1, 2, 'completed', 50, 12, 50, 12),
(@plan_id, 7, 2, 1, 'completed', NULL, NULL, NULL, NULL);

UPDATE PlannedSet SET target_duration_minutes = 20, target_intensity = 'easy' 
WHERE plan_id = @plan_id AND exercise_id = 7;

-- ===================================================================
-- 10월 28일 (월) - 오늘, 나쁜 날: 식단만 있고 운동 안함 (2500kcal, 지방 많음, 단백질 60g)
-- ===================================================================

INSERT INTO MealLog (user_id, meal_date, meal_type) VALUES (1, '2025-10-28', 1);
SET @meal_id = LAST_INSERT_ID();
INSERT INTO LoggedFood (meal_log_id, food_name, serving_size_grams, calories, protein, carbs, fat) VALUES
(@meal_id, '도넛', 75, 250, 3, 30, 14),
(@meal_id, '카페라떼', 360, 190, 7, 19, 9);

INSERT INTO MealLog (user_id, meal_date, meal_type) VALUES (1, '2025-10-28', 2);
SET @meal_id = LAST_INSERT_ID();
INSERT INTO LoggedFood (meal_log_id, food_name, serving_size_grams, calories, protein, carbs, fat) VALUES
(@meal_id, '햄버거', 250, 540, 25, 45, 29),
(@meal_id, '감자튀김', 150, 365, 4, 48, 17),
(@meal_id, '콜라', 350, 140, 0, 39, 0);

INSERT INTO MealLog (user_id, meal_date, meal_type) VALUES (1, '2025-10-28', 3);
SET @meal_id = LAST_INSERT_ID();
INSERT INTO LoggedFood (meal_log_id, food_name, serving_size_grams, calories, protein, carbs, fat) VALUES
(@meal_id, '짜장면', 600, 700, 18, 98, 24),
(@meal_id, '탕수육', 150, 350, 12, 38, 16);

-- 운동: 없음

-- 확인 쿼리
SELECT '=== 일주일 식단 요약 ===' as '구분';
SELECT 
    m.meal_date as '날짜',
    ROUND(SUM(f.calories), 0) as '총 칼로리',
    ROUND(SUM(f.protein), 0) as '단백질(g)',
    ROUND(SUM(f.carbs), 0) as '탄수화물(g)',
    ROUND(SUM(f.fat), 0) as '지방(g)'
FROM MealLog m 
JOIN LoggedFood f ON m.meal_log_id = f.meal_log_id 
WHERE m.user_id = 1 AND m.meal_date BETWEEN '2025-10-22' AND '2025-10-28'
GROUP BY m.meal_date
ORDER BY m.meal_date;

SELECT '=== 일주일 운동 요약 ===' as '구분';
SELECT 
    wp.plan_date as '날짜',
    wp.status as '상태',
    COUNT(ps.set_id) as '총 세트 수',
    SUM(CASE WHEN ps.status = 'completed' THEN 1 ELSE 0 END) as '완료 세트 수'
FROM WorkoutPlan wp 
LEFT JOIN PlannedSet ps ON wp.plan_id = ps.plan_id
WHERE wp.user_id = 1 AND wp.plan_date BETWEEN '2025-10-22' AND '2025-10-28'
GROUP BY wp.plan_date, wp.status
ORDER BY wp.plan_date;
