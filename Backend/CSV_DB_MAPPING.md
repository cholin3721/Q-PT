# CSV ↔ DB 구조 매핑 분석

## 📊 CSV 파일 정보
- **파일명:** `전국통합식품영양성분정보_음식_표준데이터.csv`
- **출처:** 식품의약품안전처
- **총 데이터:** 14,585개 식품
- **총 컬럼:** 51개
- **인코딩:** EUC-KR

---

## ✅ DB 테이블: `NutritionData`

```javascript
NutritionData {
  nutrition_data_id: BIGINT (PK, Auto Increment)
  food_name: STRING(100) (Unique)
  serving_size_grams: DECIMAL(10, 2) (기본값: 100.00)
  calories: DECIMAL(10, 2)
  protein: DECIMAL(10, 2)
  fat: DECIMAL(10, 2)
  carbs: DECIMAL(10, 2)
  sugars: DECIMAL(10, 2)
  sodium: DECIMAL(10, 2)
  cholesterol: DECIMAL(10, 2)
  trans_fat: DECIMAL(10, 2)
}
```

---

## 🔄 CSV → DB 컬럼 매핑

| CSV 컬럼 | 예시 값 | DB 컬럼 | 타입 | 변환 | 상태 |
|----------|---------|---------|------|------|------|
| **식품명** | 토스트(식빵) | `food_name` | STRING(100) | 그대로 | ✅ 매핑 가능 |
| **영양성분함량기준량** | 100ml, 100g | `serving_size_grams` | DECIMAL(10,2) | "100ml" → 100.00 | ⚠️ 단위 처리 필요 |
| **에너지(kcal)** | 84 | `calories` | DECIMAL(10,2) | 그대로 | ✅ 매핑 가능 |
| **단백질(g)** | 2.5 | `protein` | DECIMAL(10,2) | 그대로 | ✅ 매핑 가능 |
| **지방(g)** | 1.33 | `fat` | DECIMAL(10,2) | 그대로 | ✅ 매핑 가능 |
| **탄수화물(g)** | 15.55 | `carbs` | DECIMAL(10,2) | 그대로 | ✅ 매핑 가능 |
| **당류(g)** | 2.61 | `sugars` | DECIMAL(10,2) | 그대로 | ✅ 매핑 가능 |
| **나트륨(mg)** | 140 | `sodium` | DECIMAL(10,2) | 그대로 | ✅ 매핑 가능 |
| **콜레스테롤(mg)** | 0 | `cholesterol` | DECIMAL(10,2) | 그대로 | ✅ 매핑 가능 |
| **트랜스지방산(g)** | (빈값) | `trans_fat` | DECIMAL(10,2) | NULL 처리 | ✅ 매핑 가능 |

---

## 📝 CSV에만 있는 컬럼 (현재 DB에서 사용 안 함)

| 컬럼 | 설명 | 필요 여부 |
|------|------|-----------|
| 식품코드 | D402-145000000-0001 | ❌ 불필요 (내부 참조용) |
| 식품대분류명 | 빵 및 과자류 | 🤔 선택적 (카테고리 기능 시 유용) |
| 수분(g) | 10.1 | ❌ 불필요 |
| 회분(g) | (빈값) | ❌ 불필요 |
| 식이섬유(g) | 1 | 🤔 선택적 (건강 관리 시 유용) |
| 칼슘(mg) | 8 | 🤔 선택적 |
| 철(mg) | 0.17 | 🤔 선택적 |
| 인(mg) | 22 | ❌ 불필요 |
| 칼륨(mg) | 30 | 🤔 선택적 |
| 비타민 A | 0 | 🤔 선택적 |
| 비타민 C | 0.57 | 🤔 선택적 |
| 비타민 D | 0 | 🤔 선택적 |
| 포화지방산(g) | 0.78 | 🤔 선택적 (심혈관 건강 시 유용) |

---

## ✅ 결론: CSV와 DB 구조 호환성

### 🎯 핵심 매핑 상태
| 항목 | 상태 | 비고 |
|------|------|------|
| **필수 영양 정보** | ✅ 완벽 호환 | calories, protein, fat, carbs |
| **추가 영양 정보** | ✅ 완벽 호환 | sugars, sodium, cholesterol, trans_fat |
| **음식 이름** | ✅ 완벽 호환 | food_name |
| **제공량** | ⚠️ 변환 필요 | "100ml" → 100.00 |
| **데이터 개수** | ✅ 충분 | 14,585개 식품 |

### 📋 필요한 작업

#### 1. `serving_size_grams` 변환 로직
```javascript
// CSV: "100ml", "100g", "230.3" 등
// DB: DECIMAL(10, 2)

function parseServingSize(csvValue) {
  // "100ml" → 100.00
  // "100g" → 100.00
  // "230.3" → 230.30
  const match = csvValue.match(/(\d+\.?\d*)/);
  return match ? parseFloat(match[1]) : 100.00;
}
```

#### 2. NULL 값 처리
```javascript
// CSV에서 빈 값이나 0인 경우 NULL로 저장
function parseNutrient(value) {
  return value && value !== '' ? parseFloat(value) : null;
}
```

#### 3. 음식 이름 중복 처리
```javascript
// DB: food_name은 UNIQUE 제약
// CSV에서 같은 이름이 있을 경우 → 식품코드를 suffix로 추가
// 예: "토스트(식빵)" → "토스트(식빵)_D402145"
```

---

## 🚀 CSV 임포트 스크립트 필요

### 추천 구조
```javascript
// Backend/import-nutrition-data.js

const fs = require('fs');
const iconv = require('iconv-lite');
const { NutritionData } = require('./src/models');

async function importCSV() {
  // 1. CSV 파일 읽기 (EUC-KR)
  // 2. 각 행 파싱
  // 3. DB에 bulk insert
  // 4. 중복 체크 및 에러 처리
}
```

---

## 💡 DB 스키마 개선 제안 (선택적)

### Option 1: 추가 영양소 컬럼 (고급 기능용)
```sql
ALTER TABLE NutritionData
ADD COLUMN fiber DECIMAL(10, 2) COMMENT '식이섬유(g)',
ADD COLUMN calcium DECIMAL(10, 2) COMMENT '칼슘(mg)',
ADD COLUMN iron DECIMAL(10, 2) COMMENT '철(mg)',
ADD COLUMN potassium DECIMAL(10, 2) COMMENT '칼륨(mg)',
ADD COLUMN vitamin_a DECIMAL(10, 2) COMMENT '비타민A(μg)',
ADD COLUMN vitamin_c DECIMAL(10, 2) COMMENT '비타민C(mg)',
ADD COLUMN saturated_fat DECIMAL(10, 2) COMMENT '포화지방산(g)';
```

### Option 2: 카테고리 컬럼
```sql
ALTER TABLE NutritionData
ADD COLUMN category VARCHAR(50) COMMENT '식품 대분류',
ADD COLUMN sub_category VARCHAR(50) COMMENT '식품 중분류';
```

---

## 📌 다음 단계

1. **CSV 임포트 스크립트 작성** ✏️
   - EUC-KR 인코딩 처리
   - 컬럼 매핑 및 변환
   - Bulk insert (배치 처리)
   - 에러 로깅

2. **데이터 검증** 🧪
   - 임포트 후 샘플 데이터 확인
   - 영양소 합계 검증
   - NULL 값 비율 확인

3. **API 테스트** 🚀
   - 음식 검색 API
   - 자동완성 기능
   - 영양소 조회

---

## ⚙️ 현재 상태

- ✅ CSV 파일 존재 확인
- ✅ CSV 구조 분석 완료
- ✅ DB 스키마 확인 완료
- ✅ 매핑 호환성 검증 완료
- ⏳ CSV 임포트 스크립트 필요
- ⏳ 데이터 임포트 실행 대기

**결론: CSV와 DB 구조가 완벽하게 호환됩니다! 임포트 스크립트만 작성하면 바로 사용 가능합니다.** 🎉



