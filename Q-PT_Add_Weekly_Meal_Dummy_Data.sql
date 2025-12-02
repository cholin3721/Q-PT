-- =================================================================
-- 최근 일주일 식단 더미 데이터
-- 사용자 ID: 1 (김철중)
-- =================================================================

USE q_pt;

-- 날짜 변수 설정 (오늘부터 6일 전까지)
SET @today = CURDATE();
SET @day1 = DATE_SUB(@today, INTERVAL 1 DAY);
SET @day2 = DATE_SUB(@today, INTERVAL 2 DAY);
SET @day3 = DATE_SUB(@today, INTERVAL 3 DAY);
SET @day4 = DATE_SUB(@today, INTERVAL 4 DAY);
SET @day5 = DATE_SUB(@today, INTERVAL 5 DAY);
SET @day6 = DATE_SUB(@today, INTERVAL 6 DAY);

-- ============================================
-- 오늘 식단
-- ============================================
INSERT INTO MealLog (user_id, meal_date, meal_type) VALUES
(1, @today, 1), -- 아침
(1, @today, 2), -- 점심
(1, @today, 4); -- 간식

SET @meal_id_today_1 = LAST_INSERT_ID();
SET @meal_id_today_2 = @meal_id_today_1 + 1;
SET @meal_id_today_3 = @meal_id_today_1 + 2;

INSERT INTO LoggedFood (meal_log_id, food_name, calories, protein, carbs, fat) VALUES
(@meal_id_today_1, '오트밀', 300, 10, 54, 6),
(@meal_id_today_1, '바나나', 90, 1, 23, 0.3),
(@meal_id_today_2, '닭가슴살', 165, 31, 0, 3.6),
(@meal_id_today_2, '현미밥', 220, 4.5, 46, 1.8),
(@meal_id_today_2, '브로콜리', 55, 4, 11, 0.6),
(@meal_id_today_3, '프로틴 쉐이크', 250, 30, 5, 10);

-- ============================================
-- 1일 전 식단
-- ============================================
INSERT INTO MealLog (user_id, meal_date, meal_type) VALUES
(1, @day1, 1), -- 아침
(1, @day1, 2), -- 점심
(1, @day1, 3); -- 저녁

SET @meal_id_day1_1 = LAST_INSERT_ID();
SET @meal_id_day1_2 = @meal_id_day1_1 + 1;
SET @meal_id_day1_3 = @meal_id_day1_1 + 2;

INSERT INTO LoggedFood (meal_log_id, food_name, calories, protein, carbs, fat) VALUES
(@meal_id_day1_1, '계란 스크램블', 200, 18, 2, 14),
(@meal_id_day1_1, '통밀빵', 150, 5, 28, 2),
(@meal_id_day1_2, '소고기 볶음', 400, 35, 5, 28),
(@meal_id_day1_2, '현미밥', 220, 4.5, 46, 1.8),
(@meal_id_day1_2, '시금치 나물', 30, 3, 4, 0.5),
(@meal_id_day1_3, '연어 구이', 350, 40, 0, 20),
(@meal_id_day1_3, '고구마', 180, 4, 41, 0.3),
(@meal_id_day1_3, '샐러드', 50, 2, 10, 0.5);

-- ============================================
-- 2일 전 식단
-- ============================================
INSERT INTO MealLog (user_id, meal_date, meal_type) VALUES
(1, @day2, 1),
(1, @day2, 2),
(1, @day2, 3),
(1, @day2, 4);

SET @meal_id_day2_1 = LAST_INSERT_ID();
SET @meal_id_day2_2 = @meal_id_day2_1 + 1;
SET @meal_id_day2_3 = @meal_id_day2_1 + 2;
SET @meal_id_day2_4 = @meal_id_day2_1 + 3;

INSERT INTO LoggedFood (meal_log_id, food_name, calories, protein, carbs, fat) VALUES
(@meal_id_day2_1, '그릭 요거트', 150, 15, 8, 8),
(@meal_id_day2_1, '블루베리', 60, 1, 15, 0.5),
(@meal_id_day2_2, '참치 샐러드', 300, 35, 10, 12),
(@meal_id_day2_2, '통밀 파스타', 350, 12, 70, 3),
(@meal_id_day2_3, '닭가슴살 스테이크', 250, 45, 0, 8),
(@meal_id_day2_3, '구운 야채', 100, 3, 20, 1),
(@meal_id_day2_3, '현미밥', 220, 4.5, 46, 1.8),
(@meal_id_day2_4, '견과류 믹스', 200, 6, 8, 18);

-- ============================================
-- 3일 전 식단
-- ============================================
INSERT INTO MealLog (user_id, meal_date, meal_type) VALUES
(1, @day3, 1),
(1, @day3, 2),
(1, @day3, 3);

SET @meal_id_day3_1 = LAST_INSERT_ID();
SET @meal_id_day3_2 = @meal_id_day3_1 + 1;
SET @meal_id_day3_3 = @meal_id_day3_1 + 2;

INSERT INTO LoggedFood (meal_log_id, food_name, calories, protein, carbs, fat) VALUES
(@meal_id_day3_1, '프로틴 팬케이크', 280, 25, 30, 8),
(@meal_id_day3_1, '딸기', 50, 1, 12, 0.5),
(@meal_id_day3_2, '소고기 덮밥', 550, 38, 60, 18),
(@meal_id_day3_2, '김치', 20, 1, 4, 0.2),
(@meal_id_day3_3, '닭가슴살 샐러드', 350, 40, 15, 10),
(@meal_id_day3_3, '고구마', 180, 4, 41, 0.3);

-- ============================================
-- 4일 전 식단
-- ============================================
INSERT INTO MealLog (user_id, meal_date, meal_type) VALUES
(1, @day4, 1),
(1, @day4, 2),
(1, @day4, 4);

SET @meal_id_day4_1 = LAST_INSERT_ID();
SET @meal_id_day4_2 = @meal_id_day4_1 + 1;
SET @meal_id_day4_3 = @meal_id_day4_1 + 2;

INSERT INTO LoggedFood (meal_log_id, food_name, calories, protein, carbs, fat) VALUES
(@meal_id_day4_1, '스크램블 에그', 180, 15, 2, 12),
(@meal_id_day4_1, '통밀 토스트', 140, 5, 26, 2),
(@meal_id_day4_1, '아보카도', 160, 2, 9, 15),
(@meal_id_day4_2, '새우 볶음밥', 450, 28, 65, 10),
(@meal_id_day4_2, '미역국', 40, 2, 6, 0.5),
(@meal_id_day4_3, '프로틴 바', 220, 20, 22, 8);

-- ============================================
-- 5일 전 식단
-- ============================================
INSERT INTO MealLog (user_id, meal_date, meal_type) VALUES
(1, @day5, 1),
(1, @day5, 2),
(1, @day5, 3),
(1, @day5, 4);

SET @meal_id_day5_1 = LAST_INSERT_ID();
SET @meal_id_day5_2 = @meal_id_day5_1 + 1;
SET @meal_id_day5_3 = @meal_id_day5_1 + 2;
SET @meal_id_day5_4 = @meal_id_day5_1 + 3;

INSERT INTO LoggedFood (meal_log_id, food_name, calories, protein, carbs, fat) VALUES
(@meal_id_day5_1, '오트밀', 300, 10, 54, 6),
(@meal_id_day5_1, '사과', 80, 0.5, 21, 0.3),
(@meal_id_day5_2, '닭가슴살', 165, 31, 0, 3.6),
(@meal_id_day5_2, '퀴노아', 220, 8, 39, 3.5),
(@meal_id_day5_2, '야채 샐러드', 80, 3, 15, 1),
(@meal_id_day5_3, '연어 스테이크', 380, 42, 0, 22),
(@meal_id_day5_3, '구운 감자', 160, 4, 37, 0.2),
(@meal_id_day5_3, '아스파라거스', 40, 4, 8, 0.2),
(@meal_id_day5_4, '그릭 요거트', 150, 15, 8, 8);

-- ============================================
-- 6일 전 식단
-- ============================================
INSERT INTO MealLog (user_id, meal_date, meal_type) VALUES
(1, @day6, 1),
(1, @day6, 2),
(1, @day6, 3);

SET @meal_id_day6_1 = LAST_INSERT_ID();
SET @meal_id_day6_2 = @meal_id_day6_1 + 1;
SET @meal_id_day6_3 = @meal_id_day6_1 + 2;

INSERT INTO LoggedFood (meal_log_id, food_name, calories, protein, carbs, fat) VALUES
(@meal_id_day6_1, '프로틴 스무디', 280, 30, 25, 6),
(@meal_id_day6_1, '통밀 머핀', 180, 6, 32, 4),
(@meal_id_day6_2, '소고기 스테이크', 450, 42, 0, 30),
(@meal_id_day6_2, '현미밥', 220, 4.5, 46, 1.8),
(@meal_id_day6_2, '양배추 샐러드', 50, 2, 10, 0.5),
(@meal_id_day6_3, '닭가슴살 샌드위치', 400, 38, 45, 12),
(@meal_id_day6_3, '방울토마토', 30, 1.5, 7, 0.3);

-- ============================================
-- 확인 쿼리
-- ============================================
SELECT '✅ 최근 7일 식단 더미 데이터가 추가되었습니다!' as message;

-- 날짜별 총 칼로리 확인
SELECT 
    ml.meal_date,
    COUNT(DISTINCT ml.meal_log_id) as meal_count,
    SUM(lf.calories) as total_calories,
    SUM(lf.protein) as total_protein,
    SUM(lf.carbs) as total_carbs,
    SUM(lf.fat) as total_fat
FROM MealLog ml
JOIN LoggedFood lf ON ml.meal_log_id = lf.meal_log_id
WHERE ml.user_id = 1 
    AND ml.meal_date >= DATE_SUB(CURDATE(), INTERVAL 6 DAY)
GROUP BY ml.meal_date
ORDER BY ml.meal_date DESC;












