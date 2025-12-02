# 인바디 DB 구조 검증 및 분석

## 📊 현재 InBody 테이블 구조

```sql
CREATE TABLE InBody (
    inbody_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    test_date DATE NOT NULL,
    height DECIMAL(5, 2),                -- 최대 999.99
    weight DECIMAL(5, 2),                -- 최대 999.99
    muscle_mass DECIMAL(5, 2),           -- 최대 999.99
    fat_mass DECIMAL(5, 2),              -- 최대 999.99
    bmi DECIMAL(4, 2),                   -- 최대 99.99
    body_fat_percentage DECIMAL(4, 2),   -- 최대 99.99
    basal_metabolic_rate INT,            -- 최대 2,147,483,647
    segmental_analysis JSON,
    FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE CASCADE
);
```

---

## 🔍 컬럼별 상세 분석

### ✅ 1. `inbody_id` - PRIMARY KEY
- **타입**: BIGINT AUTO_INCREMENT
- **용도**: 고유 식별자
- **검증**: ✅ 문제없음

### ✅ 2. `user_id` - 사용자 연결
- **타입**: BIGINT NOT NULL
- **용도**: User 테이블과 연결
- **검증**: ✅ 문제없음
- **관계**: User(user_id) → ON DELETE CASCADE (사용자 삭제 시 인바디 기록도 삭제)

### ✅ 3. `test_date` - 측정 날짜
- **타입**: DATE NOT NULL
- **용도**: 인바디 측정 날짜
- **OCR 데이터**: 
  - test-inbody: "2015.05.04."
  - inbody-result-1: "2018.10.25."
- **검증**: ✅ DATE 형식으로 저장 가능
- **⚠️ 주의**: OCR에서 시간(09:46, 15:44)도 나오지만 현재는 날짜만 저장
  - **제안**: DATETIME으로 변경하면 시간까지 저장 가능
  ```sql
  test_date DATETIME NOT NULL  -- 2015-05-04 09:46:00
  ```

---

## 📏 신체 계측 컬럼

### ✅ 4. `height` - 신장
- **타입**: DECIMAL(5, 2)
- **범위**: 0.00 ~ 999.99 cm
- **OCR 데이터**:
  - test-inbody: 156.9 cm ✅
  - inbody-result-1: 173 cm ✅
- **검증**: ✅ 충분함 (일반적으로 100~220cm)

### ✅ 5. `weight` - 체중
- **타입**: DECIMAL(5, 2)
- **범위**: 0.00 ~ 999.99 kg
- **OCR 데이터**:
  - test-inbody: 59.1 kg ✅
  - inbody-result-1: 64.0 kg ✅
- **검증**: ✅ 충분함 (일반적으로 30~200kg)

### ✅ 6. `muscle_mass` - 골격근량
- **타입**: DECIMAL(5, 2)
- **범위**: 0.00 ~ 999.99 kg
- **OCR 데이터**:
  - test-inbody: 19.3 kg ✅
  - inbody-result-1: 측정 가능 ✅
- **검증**: ✅ 충분함 (일반적으로 10~50kg)

### ✅ 7. `fat_mass` - 체지방량
- **타입**: DECIMAL(5, 2)
- **범위**: 0.00 ~ 999.99 kg
- **OCR 데이터**:
  - test-inbody: 22.1 kg ✅
  - inbody-result-1: 22.1 kg ✅
- **검증**: ✅ 충분함 (일반적으로 5~100kg)

---

## ⚖️ 비만 지표 컬럼

### ✅ 8. `bmi` - BMI
- **타입**: DECIMAL(4, 2)
- **범위**: 0.00 ~ 99.99
- **OCR 데이터**:
  - test-inbody: 24.0 ✅
  - inbody-result-1: 21.4 ✅
- **검증**: ✅ 충분함 (일반적으로 15~50)

### ✅ 9. `body_fat_percentage` - 체지방률
- **타입**: DECIMAL(4, 2)
- **범위**: 0.00 ~ 99.99 %
- **OCR 데이터**:
  - test-inbody: 37.5 % ✅
  - inbody-result-1: 측정 가능 ✅
- **검증**: ✅ 충분함 (일반적으로 5~50%)

### ✅ 10. `basal_metabolic_rate` - 기초대사량
- **타입**: INT
- **범위**: -2,147,483,648 ~ 2,147,483,647
- **OCR 데이터**:
  - test-inbody: 1168 kcal ✅
  - inbody-result-1: 1275 kcal ✅
- **검증**: ✅ 충분함 (일반적으로 1000~3000 kcal)

### 🔄 11. `segmental_analysis` - 부위별 분석
- **타입**: JSON
- **OCR 데이터**: 
  - "표준", "표준이하", "표준이상" 등
- **검증**: ✅ JSON으로 유연하게 저장 가능
- **제안 구조**:
```json
{
  "muscle": {
    "rightArm": "standard",
    "leftArm": "standard",
    "trunk": "above_standard",
    "rightLeg": "below_standard",
    "leftLeg": "below_standard"
  },
  "fat": {
    "rightArm": "standard",
    "leftArm": "standard",
    "trunk": "above_standard",
    "rightLeg": "below_standard",
    "leftLeg": "below_standard"
  }
}
```

---

## ❌ 현재 테이블에 **없는** OCR 추출 가능 데이터

### 🔬 체성분 상세 (매우 중요!)

#### ❌ 12. 체수분 (Body Water)
- **OCR 데이터**:
  - test-inbody: 27.2 L ✅
  - inbody-result-1: 31.4 L ✅
- **중요도**: ⭐⭐⭐⭐ (건강 지표로 중요)
- **추가 필요**:
```sql
body_water DECIMAL(5, 2) COMMENT '체수분(L)'
```

#### ❌ 13. 단백질 (Protein)
- **OCR 데이터**:
  - test-inbody: 7.1 kg ✅
  - inbody-result-1: 8.0 kg ✅
- **중요도**: ⭐⭐⭐⭐ (근육 생성 지표)
- **추가 필요**:
```sql
protein DECIMAL(5, 2) COMMENT '단백질(kg)'
```

#### ❌ 14. 무기질 (Minerals)
- **OCR 데이터**:
  - test-inbody: 2.74 kg ✅
  - inbody-result-1: 2.60 kg ✅
- **중요도**: ⭐⭐⭐ (골밀도 관련)
- **추가 필요**:
```sql
minerals DECIMAL(5, 2) COMMENT '무기질(kg)'
```

#### ❌ 15. 제지방량 (Lean Body Mass)
- **OCR 데이터**:
  - test-inbody: 37.0 kg ✅
  - inbody-result-1: 41.9 kg ✅
- **중요도**: ⭐⭐⭐⭐ (근육+수분+무기질 총량)
- **추가 필요**:
```sql
lean_body_mass DECIMAL(5, 2) COMMENT '제지방량(kg)'
```

---

### 🏥 비만 관련 지표 (매우 중요!)

#### ❌ 16. 내장지방레벨 (Visceral Fat Level)
- **OCR 데이터**:
  - test-inbody: 13 ✅
  - inbody-result-1: 측정 가능 ✅
- **중요도**: ⭐⭐⭐⭐⭐ (건강 위험도 평가 핵심!)
- **추가 필요**:
```sql
visceral_fat_level INT COMMENT '내장지방레벨 (1-30)'
```

#### ❌ 17. 복부지방률 (Waist-Hip Ratio)
- **OCR 데이터**:
  - test-inbody: 0.98 ✅
  - inbody-result-1: 측정 가능 ✅
- **중요도**: ⭐⭐⭐⭐ (복부비만 판단)
- **추가 필요**:
```sql
waist_hip_ratio DECIMAL(4, 2) COMMENT '복부지방률'
```

---

### 🎯 목표 관련 데이터 (Goal 테이블과 연동 가능)

#### ❌ 18. 적정체중 (Ideal Weight)
- **OCR 데이터**:
  - test-inbody: 52.9 kg ✅
  - inbody-result-1: ❌ (이 양식에는 없음)
- **중요도**: ⭐⭐⭐ (목표 설정 참고)
- **저장 위치 선택**:
  1. InBody 테이블에 추가 (참고용)
  2. Goal 테이블에 자동 설정
```sql
-- 옵션 1: InBody 테이블
ideal_weight DECIMAL(5, 2) COMMENT '적정체중(kg)'

-- 옵션 2: Goal 테이블 활용 (현재 구조)
-- 이미 target_weight 컬럼 존재! ✅
```

#### ❌ 19. 체중조절 (Weight Control)
- **OCR 데이터**: test-inbody: 6.2 kg ✅
- **의미**: 현재 체중에서 조절해야 할 양
- **저장**: InBody에 참고용으로 저장
```sql
weight_control DECIMAL(5, 2) COMMENT '체중조절량(kg, +증량/-감량)'
```

#### ❌ 20. 지방조절 (Fat Control)
- **OCR 데이터**: test-inbody: -10.0 kg ✅
- **의미**: 감량해야 할 체지방량
- **저장**: InBody에 참고용으로 저장
```sql
fat_control DECIMAL(5, 2) COMMENT '지방조절량(kg)'
```

#### ❌ 21. 근육조절 (Muscle Control)
- **OCR 데이터**: test-inbody: +3.8 kg ✅
- **의미**: 증량해야 할 근육량
- **저장**: InBody에 참고용으로 저장
```sql
muscle_control DECIMAL(5, 2) COMMENT '근육조절량(kg)'
```

#### ❌ 22. 권장섭취열량 (Recommended Calories)
- **OCR 데이터**: test-inbody: 1397 kcal ✅
- **중요도**: ⭐⭐⭐⭐ (식단 관리 핵심!)
- **추가 필요**:
```sql
recommended_calories INT COMMENT '권장섭취열량(kcal/일)'
```

---

### 🆕 특수 데이터 (BWA2.0S 전용)

#### ❌ 23. 세포내수분 (Intracellular Water)
- **OCR 데이터**: inbody-result-1: 18.4 L ✅
- **중요도**: ⭐⭐⭐ (전문 분석용)
```sql
intracellular_water DECIMAL(5, 2) COMMENT '세포내수분(L)'
```

#### ❌ 24. 세포외수분 (Extracellular Water)
- **OCR 데이터**: inbody-result-1: 13.0 L ✅
- **중요도**: ⭐⭐⭐ (전문 분석용)
```sql
extracellular_water DECIMAL(5, 2) COMMENT '세포외수분(L)'
```

#### ❌ 25. 골무기질량 (Bone Mineral Content)
- **OCR 데이터**: inbody-result-1: 2.16 kg ✅
- **중요도**: ⭐⭐ (골밀도 관련)
```sql
bone_mineral_content DECIMAL(5, 2) COMMENT '골무기질량(kg)'
```

---

## 🔗 다른 테이블과의 연동 검증

### ✅ Goal 테이블과의 연계

**현재 Goal 테이블**:
```sql
CREATE TABLE Goal (
    goal_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    target_weight DECIMAL(5, 2),        -- ✅ 적정체중 자동 설정 가능
    target_fat_mass DECIMAL(5, 2),      -- ✅ 지방조절 자동 설정 가능
    target_muscle_mass DECIMAL(5, 2),   -- ✅ 근육조절 자동 설정 가능
    is_active BOOLEAN DEFAULT TRUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

**연동 방법**:
```javascript
// 인바디 등록 시 자동으로 Goal 생성
const currentWeight = 59.1;
const weightControl = 6.2;  // OCR에서 추출

Goal.create({
  user_id: userId,
  target_weight: currentWeight + weightControl,  // 59.1 - 6.2 = 52.9
  target_fat_mass: currentFatMass + fatControl,  // 22.1 - 10.0 = 12.1
  target_muscle_mass: currentMuscle + muscleControl  // 19.3 + 3.8 = 23.1
});
```

**✅ 검증 결과**: Goal 테이블 구조 완벽! 인바디 데이터로 자동 설정 가능!

---

### ⚠️ MealLog / NutritionData 테이블과의 연계

**권장섭취열량 활용**:
```javascript
// 인바디에서 권장 섭취열량 가져오기
const recommendedCalories = 1397;  // kcal/일

// 하루 식사 로그의 총 칼로리와 비교
SELECT SUM(lf.calories) as total_calories
FROM MealLog ml
JOIN LoggedFood lf ON ml.meal_log_id = lf.meal_log_id
WHERE ml.user_id = ? AND ml.meal_date = ?

// total_calories vs recommendedCalories 비교
```

**✅ 검증 결과**: 별도 컬럼 추가 없이 연동 가능! InBody에 recommended_calories만 추가하면 됨!

---

## 📊 최종 검증 결과

### ✅ 현재 테이블로 저장 가능한 데이터 (8개)
| 컬럼 | OCR 추출 | 저장 가능 | 타입 적합 |
|------|---------|---------|----------|
| height | ✅ | ✅ | ✅ DECIMAL(5,2) |
| weight | ✅ | ✅ | ✅ DECIMAL(5,2) |
| muscle_mass | ✅ | ✅ | ✅ DECIMAL(5,2) |
| fat_mass | ✅ | ✅ | ✅ DECIMAL(5,2) |
| bmi | ✅ | ✅ | ✅ DECIMAL(4,2) |
| body_fat_percentage | ✅ | ✅ | ✅ DECIMAL(4,2) |
| basal_metabolic_rate | ✅ | ✅ | ✅ INT |
| segmental_analysis | ✅ | ✅ | ✅ JSON |

**현재 저장률**: 8/18 = 44.4%

### ❌ 추가해야 하는 중요 데이터 (10개)

#### 🔥 필수 추가 (5개) - 건강 관리 핵심
1. **body_water** - 체수분
2. **protein** - 단백질
3. **lean_body_mass** - 제지방량
4. **visceral_fat_level** - 내장지방레벨 ⭐⭐⭐⭐⭐
5. **waist_hip_ratio** - 복부지방률

#### ⭐ 권장 추가 (5개) - 목표 설정 및 식단 관리
6. **recommended_calories** - 권장섭취열량 (식단 관리 필수!)
7. **ideal_weight** - 적정체중 (참고용)
8. **weight_control** - 체중조절량
9. **fat_control** - 지방조절량
10. **muscle_control** - 근육조절량

#### 🆕 선택 추가 (3개) - 전문 분석용
11. **minerals** - 무기질
12. **intracellular_water** - 세포내수분
13. **extracellular_water** - 세포외수분

---

## 🚀 권장 DB 개선 SQL

### 옵션 1: 필수 + 권장 (추천!)
```sql
ALTER TABLE InBody
ADD COLUMN body_water DECIMAL(5, 2) COMMENT '체수분(L)',
ADD COLUMN protein DECIMAL(5, 2) COMMENT '단백질(kg)',
ADD COLUMN lean_body_mass DECIMAL(5, 2) COMMENT '제지방량(kg)',
ADD COLUMN visceral_fat_level INT COMMENT '내장지방레벨',
ADD COLUMN waist_hip_ratio DECIMAL(4, 2) COMMENT '복부지방률',
ADD COLUMN recommended_calories INT COMMENT '권장섭취열량(kcal)',
ADD COLUMN ideal_weight DECIMAL(5, 2) COMMENT '적정체중(kg)',
ADD COLUMN weight_control DECIMAL(5, 2) COMMENT '체중조절량(kg)',
ADD COLUMN fat_control DECIMAL(5, 2) COMMENT '지방조절량(kg)',
ADD COLUMN muscle_control DECIMAL(5, 2) COMMENT '근육조절량(kg)';
```

### 옵션 2: 필수만 (최소)
```sql
ALTER TABLE InBody
ADD COLUMN body_water DECIMAL(5, 2) COMMENT '체수분(L)',
ADD COLUMN protein DECIMAL(5, 2) COMMENT '단백질(kg)',
ADD COLUMN lean_body_mass DECIMAL(5, 2) COMMENT '제지방량(kg)',
ADD COLUMN visceral_fat_level INT COMMENT '내장지방레벨',
ADD COLUMN waist_hip_ratio DECIMAL(4, 2) COMMENT '복부지방률';
```

---

## 💡 검증 결론

### ✅ **현재 DB 구조 평가**

**장점**:
- ✅ 기본 신체 계측 데이터 모두 커버
- ✅ DECIMAL 크기 적절 (충분한 범위)
- ✅ Goal 테이블과 연동 가능한 구조
- ✅ JSON 타입으로 유연한 확장 가능

**단점**:
- ❌ 중요 건강 지표 누락 (내장지방레벨, 복부지방률)
- ❌ 체성분 상세 데이터 없음 (체수분, 단백질)
- ❌ 식단 관리용 권장열량 없음
- ❌ 목표 설정 참고값 없음

### 🎯 **최종 권장 사항**

1. **즉시 추가**: 필수 5개 (내장지방레벨, 복부지방률, 체수분, 단백질, 제지방량)
2. **곧 추가**: 권장 5개 (권장섭취열량, 조절량 데이터)
3. **선택 추가**: 전문 분석용 3개 (세포내외수분, 무기질)

**개선 후 저장률**: 18/18 = 100% ✅

---

## 📋 다음 단계

1. ✅ DB 스키마 검증 완료
2. ⏭️ ALTER TABLE 실행 (컬럼 추가)
3. ⏭️ Sequelize 모델 업데이트
4. ⏭️ API 컨트롤러에 파싱 로직 적용
5. ⏭️ Goal 자동 생성 로직 추가

**준비 완료! 스키마 개선 후 100% 데이터 활용 가능합니다!** 🎉



