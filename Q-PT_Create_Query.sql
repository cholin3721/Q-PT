create database q_pt;
use q_pt;

-- 사용자 계정 정보 테이블
CREATE TABLE User (
    user_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    provider ENUM('google', 'kakao') NOT NULL,
    provider_id VARCHAR(255) NOT NULL,
    nickname VARCHAR(50) UNIQUE,
    email VARCHAR(255) UNIQUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY provider_provider_id (provider, provider_id)
);

-- 인바디 기록 테이블
CREATE TABLE InBody (
    inbody_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    test_date DATE NOT NULL,
    height DECIMAL(5, 2),
    weight DECIMAL(5, 2),
    muscle_mass DECIMAL(5, 2),
    fat_mass DECIMAL(5, 2),
    bmi DECIMAL(4, 2),
    body_fat_percentage DECIMAL(4, 2),
    basal_metabolic_rate INT,
    segmental_analysis JSON,
    FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE CASCADE
);

-- 사용자 목표 설정 테이블
CREATE TABLE Goal (
    goal_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    target_weight DECIMAL(5, 2),
    target_fat_mass DECIMAL(5, 2),
    target_muscle_mass DECIMAL(5, 2),
    is_active BOOLEAN DEFAULT TRUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE CASCADE
);

-- AI 피드백 저장 테이블
CREATE TABLE AIFeedback (
    feedback_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    feedback_content JSON NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE CASCADE
);

-- 음식 영양 정보 마스터 테이블 (사전) [cite: 133]
CREATE TABLE NutritionData (
    nutrition_data_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    food_name VARCHAR(100) NOT NULL UNIQUE,
    serving_size_grams DECIMAL(10, 2) DEFAULT 100.00,
    calories DECIMAL(10, 2),
    protein DECIMAL(10, 2),
    fat DECIMAL(10, 2),
    carbs DECIMAL(10, 2),
    sugars DECIMAL(10, 2),
    sodium DECIMAL(10, 2),
    cholesterol DECIMAL(10, 2),
    trans_fat DECIMAL(10, 2)
);

-- 하루 식사 기록 테이블 (아침, 점심, 저녁 등)
CREATE TABLE MealLog (
    meal_log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    meal_date DATE NOT NULL,
    meal_type INT NOT NULL COMMENT 'n번째 식사',
    image_url VARCHAR(2048),
    FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE CASCADE
);

-- 기록된 개별 음식 정보 테이블
CREATE TABLE LoggedFood (
    logged_food_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    meal_log_id BIGINT NOT NULL,
    food_name VARCHAR(100) NOT NULL,
    serving_size_grams DECIMAL(10, 2),
    calories DECIMAL(10, 2),
    protein DECIMAL(10, 2),
    fat DECIMAL(10, 2),
    carbs DECIMAL(10, 2),
    FOREIGN KEY (meal_log_id) REFERENCES MealLog(meal_log_id) ON DELETE CASCADE
);

-- 운동 부위 마스터 테이블
CREATE TABLE MuscleGroup (
    muscle_group_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

-- 운동 종류 마스터 테이블 (사전)
CREATE TABLE Exercise (
    exercise_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    exercise_name VARCHAR(100) NOT NULL UNIQUE,
    exercise_type ENUM('weight', 'cardio') NOT NULL,
    user_id BIGINT COMMENT '사용자가 직접 추가한 경우 user_id 기록',
    FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE SET NULL
);

-- 운동과 운동 부위 연결 테이블 (N:M 관계)
CREATE TABLE ExerciseMuscleGroup (
    exercise_id BIGINT NOT NULL,
    muscle_group_id BIGINT NOT NULL,
    PRIMARY KEY (exercise_id, muscle_group_id),
    FOREIGN KEY (exercise_id) REFERENCES Exercise(exercise_id) ON DELETE CASCADE,
    FOREIGN KEY (muscle_group_id) REFERENCES MuscleGroup(muscle_group_id) ON DELETE CASCADE
);

-- 운동 루틴 템플릿 마스터 테이블
CREATE TABLE Routine (
    routine_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    routine_name VARCHAR(100) NOT NULL,
    description TEXT,
    FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE CASCADE
);

-- 루틴에 포함된 개별 운동 세트 템플릿 테이블
CREATE TABLE RoutineSet (
    routine_set_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    routine_id BIGINT NOT NULL,
    exercise_id BIGINT NOT NULL,
    display_order INT,
    set_number INT,
    target_weight_kg DECIMAL(6, 2),
    target_reps INT,
    target_duration_minutes INT,
    target_intensity VARCHAR(50),
    is_interval BOOLEAN DEFAULT FALSE,
    target_rounds INT,
    FOREIGN KEY (routine_id) REFERENCES Routine(routine_id) ON DELETE CASCADE,
    FOREIGN KEY (exercise_id) REFERENCES Exercise(exercise_id) ON DELETE CASCADE
);

-- 일일 운동 계획 테이블
CREATE TABLE WorkoutPlan (
    plan_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    plan_date DATE NOT NULL,
    status ENUM('planned', 'active', 'completed') DEFAULT 'planned',
    memo TEXT,
    UNIQUE KEY user_plan_date (user_id, plan_date),
    FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE CASCADE
);

-- 계획된 개별 운동 세트 및 실제 수행 기록 테이블
CREATE TABLE PlannedSet (
    set_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    plan_id BIGINT NOT NULL,
    exercise_id BIGINT NOT NULL,
    display_order INT,
    set_number INT NOT NULL,
    status ENUM('pending', 'completed', 'skipped') DEFAULT 'pending',
    failure_reason ENUM('FATIGUE', 'PAIN', 'LACK_OF_TIME'),
    target_weight_kg DECIMAL(6, 2),
    actual_weight_kg DECIMAL(6, 2),
    target_reps INT,
    actual_reps INT,
    target_duration_minutes INT,
    actual_duration_minutes INT,
    target_intensity VARCHAR(50),
    actual_intensity VARCHAR(50),
    FOREIGN KEY (plan_id) REFERENCES WorkoutPlan(plan_id) ON DELETE CASCADE,
    FOREIGN KEY (exercise_id) REFERENCES Exercise(exercise_id)
);

-- 인터벌 운동의 세부 단계 테이블
CREATE TABLE IntervalPhase (
    phase_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    set_id BIGINT NOT NULL,
    phase_order INT NOT NULL,
    target_duration_seconds INT,
    actual_duration_seconds INT,
    target_intensity VARCHAR(50),
    actual_intensity VARCHAR(50),
    FOREIGN KEY (set_id) REFERENCES PlannedSet(set_id) ON DELETE CASCADE
);

