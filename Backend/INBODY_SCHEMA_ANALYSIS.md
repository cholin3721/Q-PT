# 인바디 DB 스키마 vs OCR 추출 가능 데이터 비교 분석

## 📊 현재 DB 스키마 (InBody 테이블)

```sql
CREATE TABLE InBody (
    inbody_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    test_date DATE NOT NULL,
    height DECIMAL(5, 2),              -- 신장
    weight DECIMAL(5, 2),              -- 체중
    muscle_mass DECIMAL(5, 2),         -- 골격근량
    fat_mass DECIMAL(5, 2),            -- 체지방량
    bmi DECIMAL(4, 2),                 -- BMI
    body_fat_percentage DECIMAL(4, 2), -- 체지방률
    basal_metabolic_rate INT,          -- 기초대사량
    segmental_analysis JSON            -- 부위별 분석
);
```

## 🔍 OCR에서 추출 가능한 데이터

### ✅ 현재 스키마에 있는 데이터 (잘 매칭됨)

| 필드명 | OCR 추출 가능 | 실제 값 예시 | 비고 |
|--------|--------------|-------------|------|
| `test_date` | ✅ | 2015.05.04. 09:46 | 날짜 + 시간 (현재는 날짜만 저장) |
| `height` | ✅ | 156.9cm | 신장 |
| `weight` | ✅ | 59.1kg | 체중 |
| `muscle_mass` | ✅ | 19.3kg | 골격근량 (Skeletal Muscle Mass) |
| `fat_mass` | ✅ | 22.1kg | 체지방량 (Body Fat Mass) |
| `bmi` | ✅ | 24.0 | BMI |
| `body_fat_percentage` | ✅ | 37.5% | 체지방률 (Percent Body Fat) |
| `basal_metabolic_rate` | ✅ | 1168 kcal | 기초대사량 |
| `segmental_analysis` | ✅ | 표준/표준이하/표준이상 | 부위별 근육 분석 (오른팔, 왼팔, 몸통, 오른다리, 왼다리) |

### 🆕 OCR에서 추출 가능하지만 현재 스키마에 없는 데이터

#### 1️⃣ **체성분 상세 데이터** (매우 유용!)
| 데이터 | OCR 값 | 중요도 | 추천 |
|--------|--------|--------|------|
| **체수분** (Body Water) | 27.2L | ⭐⭐⭐ | **추가 권장** |
| **단백질** (Protein) | 7.1kg | ⭐⭐⭐ | **추가 권장** |
| **무기질** (Minerals) | 2.74kg | ⭐⭐ | 추가 고려 |
| **제지방량** (Lean Body Mass) | 37.0kg | ⭐⭐⭐ | **추가 권장** |

#### 2️⃣ **비만 관련 지표** (건강 관리에 유용!)
| 데이터 | OCR 값 | 중요도 | 추천 |
|--------|--------|--------|------|
| **내장지방레벨** (Visceral Fat Level) | 13 | ⭐⭐⭐⭐ | **강력 추가 권장** |
| **복부지방률** (Waist-Hip Ratio) | 0.98 | ⭐⭐⭐ | **추가 권장** |
| **비만도** (Obesity Degree) | 112% | ⭐⭐ | 추가 고려 |
| **인바디점수** (InBody Score) | 66/100점 | ⭐⭐ | 추가 고려 |

#### 3️⃣ **목표 관련 데이터** (Goal 테이블과 연관)
| 데이터 | OCR 값 | 중요도 | 추천 |
|--------|--------|--------|------|
| **적정체중** (Ideal Weight) | 52.9kg | ⭐⭐⭐ | Goal 테이블에 자동 설정 가능 |
| **체중조절** (Weight Control) | 6.2kg | ⭐⭐⭐ | Goal 테이블에 자동 설정 가능 |
| **지방조절** (Fat Control) | -10.0kg | ⭐⭐⭐ | Goal 테이블에 자동 설정 가능 |
| **근육조절** (Muscle Control) | +3.8kg | ⭐⭐⭐ | Goal 테이블에 자동 설정 가능 |
| **권장섭취열량** (Recommended Calorie) | 1397 kcal | ⭐⭐⭐ | Goal 테이블에 추가 권장 |

#### 4️⃣ **기타 정보**
| 데이터 | OCR 값 | 중요도 | 추천 |
|--------|--------|--------|------|
| 회원 이름 | Jane Doe | ⭐ | User 테이블에 이미 있음 |
| 연령 | 51 | ⭐ | User 테이블에 추가 고려 |
| 성별 | 여성 | ⭐ | User 테이블에 추가 고려 |
| 검사 시간 | 09:46 | ⭐ | 필요시 추가 |
| 운동별 소비열량 | 골프 104kcal 등 | ⭐ | 불필요 (동적 계산 가능) |

---

## 🎯 권장 DB 스키마 개선안

### 옵션 1: 최소 개선 (가장 중요한 것만 추가)
```sql
ALTER TABLE InBody ADD COLUMN body_water DECIMAL(5, 2) COMMENT '체수분(L)';
ALTER TABLE InBody ADD COLUMN protein DECIMAL(5, 2) COMMENT '단백질(kg)';
ALTER TABLE InBody ADD COLUMN visceral_fat_level INT COMMENT '내장지방레벨';
ALTER TABLE InBody ADD COLUMN waist_hip_ratio DECIMAL(4, 2) COMMENT '복부지방률';
```

### 옵션 2: 권장 개선 (유용한 데이터 모두 추가)
```sql
-- 체성분 상세
ALTER TABLE InBody ADD COLUMN body_water DECIMAL(5, 2) COMMENT '체수분(L)';
ALTER TABLE InBody ADD COLUMN protein DECIMAL(5, 2) COMMENT '단백질(kg)';
ALTER TABLE InBody ADD COLUMN minerals DECIMAL(5, 2) COMMENT '무기질(kg)';
ALTER TABLE InBody ADD COLUMN lean_body_mass DECIMAL(5, 2) COMMENT '제지방량(kg)';

-- 비만 관련
ALTER TABLE InBody ADD COLUMN visceral_fat_level INT COMMENT '내장지방레벨';
ALTER TABLE InBody ADD COLUMN waist_hip_ratio DECIMAL(4, 2) COMMENT '복부지방률';
ALTER TABLE InBody ADD COLUMN obesity_degree DECIMAL(5, 2) COMMENT '비만도(%)';
ALTER TABLE InBody ADD COLUMN inbody_score INT COMMENT '인바디점수';

-- 목표 설정 참고값 (읽기 전용)
ALTER TABLE InBody ADD COLUMN ideal_weight DECIMAL(5, 2) COMMENT '적정체중(kg)';
ALTER TABLE InBody ADD COLUMN weight_control DECIMAL(5, 2) COMMENT '체중조절(kg)';
ALTER TABLE InBody ADD COLUMN fat_control DECIMAL(5, 2) COMMENT '지방조절(kg)';
ALTER TABLE InBody ADD COLUMN muscle_control DECIMAL(5, 2) COMMENT '근육조절(kg)';
ALTER TABLE InBody ADD COLUMN recommended_calories INT COMMENT '권장섭취열량(kcal)';
```

### 옵션 3: Goal 테이블 개선 (인바디 목표값 활용)
```sql
-- Goal 테이블에 인바디 기반 권장값 추가
ALTER TABLE Goal ADD COLUMN based_on_inbody_id BIGINT COMMENT '참고한 인바디 기록 ID';
ALTER TABLE Goal ADD COLUMN recommended_calories INT COMMENT '권장 섭취 열량';
ALTER TABLE Goal ADD COLUMN FOREIGN KEY (based_on_inbody_id) REFERENCES InBody(inbody_id);
```

---

## 💡 최종 추천

### ⭐ 단계별 개선 전략

#### Phase 1: 필수 추가 (즉시 적용)
```sql
ALTER TABLE InBody ADD COLUMN body_water DECIMAL(5, 2) COMMENT '체수분(L)';
ALTER TABLE InBody ADD COLUMN protein DECIMAL(5, 2) COMMENT '단백질(kg)';
ALTER TABLE InBody ADD COLUMN visceral_fat_level INT COMMENT '내장지방레벨';
ALTER TABLE InBody ADD COLUMN waist_hip_ratio DECIMAL(4, 2) COMMENT '복부지방률';
ALTER TABLE InBody ADD COLUMN lean_body_mass DECIMAL(5, 2) COMMENT '제지방량(kg)';
```
**이유:** 이 5개 필드는 건강 관리에 매우 중요하고 OCR에서 쉽게 추출 가능

#### Phase 2: 목표 설정 연동 (선택적)
```sql
-- Goal 테이블에 인바디 참고 정보 추가
ALTER TABLE Goal ADD COLUMN based_on_inbody_id BIGINT;
ALTER TABLE Goal ADD COLUMN recommended_calories INT;
ALTER TABLE Goal ADD COLUMN FOREIGN KEY (based_on_inbody_id) REFERENCES InBody(inbody_id);
```
**이유:** 인바디 결과를 바탕으로 자동 목표 설정 가능

#### Phase 3: 추가 분석 지표 (나중에)
```sql
ALTER TABLE InBody ADD COLUMN minerals DECIMAL(5, 2);
ALTER TABLE InBody ADD COLUMN obesity_degree DECIMAL(5, 2);
ALTER TABLE InBody ADD COLUMN inbody_score INT;
```

---

## 📝 segmental_analysis JSON 구조 제안

현재 `segmental_analysis` 필드에 저장할 부위별 분석 데이터:

```json
{
  "muscle": {
    "rightArm": "standard",      // 표준
    "leftArm": "standard",       // 표준
    "trunk": "above_standard",   // 표준이상
    "rightLeg": "below_standard", // 표준이하
    "leftLeg": "below_standard"   // 표준이하
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

## 🚫 불필요한 데이터 (스키마에 추가 안 함)

| 데이터 | 이유 |
|--------|------|
| 운동별 소비열량 | 동적으로 계산 가능, 사용자마다 다름 |
| 회원번호 | 앱 자체 user_id 사용 |
| 이름, 성별, 연령 | User 테이블에 이미 있거나 추가 가능 |
| 검사 시간 | 날짜만으로 충분 |
| 인바디 기기 모델명 | 불필요 |

---

## ✅ 결론

### 현재 상태
- **기본 데이터 (8개)**: 모두 OCR에서 추출 가능 ✅
- **부위별 분석**: segmental_analysis JSON으로 저장 가능 ✅

### 개선 권장
1. **필수 추가 (5개)**: 체수분, 단백질, 내장지방레벨, 복부지방률, 제지방량
2. **선택 추가**: Goal 테이블에 인바디 연동 필드
3. **불필요**: 운동별 소비열량, 기기 정보 등

**다음 단계**: 
1. DB 스키마 개선 적용 여부 결정
2. OCR 파싱 로직 개선 (정확도 향상)




