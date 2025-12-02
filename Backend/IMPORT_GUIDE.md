# 영양 데이터 임포트 가이드 📊

## 🎯 목적
CSV 파일(`전국통합식품영양성분정보_음식_표준데이터.csv`)의 14,585개 식품 데이터를 `NutritionData` 테이블에 임포트합니다.

---

## 📋 사전 준비

### 1. 패키지 설치
```bash
cd Backend
npm install iconv-lite
```

### 2. CSV 파일 확인
```
위치: 프로젝트 루트/전국통합식품영양성분정보_음식_표준데이터.csv
크기: 약 14,585줄
인코딩: EUC-KR
```

### 3. DB 연결 확인
`.env` 파일에 DB 설정이 올바른지 확인:
```env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=your_database
```

---

## 🚀 실행 방법

### 기본 실행
```bash
cd Backend
node import-nutrition-data.js
```

### 기존 데이터가 있는 경우

#### Option 1: 기존 데이터 유지하고 새 데이터만 추가
```bash
node import-nutrition-data.js
# → 중복은 자동으로 건너뜀 (ignoreDuplicates: true)
```

#### Option 2: 기존 데이터 삭제 후 전체 재임포트
임포트 스크립트에 아래 코드 추가 (주석 해제):
```javascript
// 5. 기존 데이터 확인 부분에 추가
if (existingCount > 0) {
  console.log('⚠️  기존 데이터 삭제 중...');
  await NutritionData.truncate(); // ← 이 줄 추가
  console.log('✅ 기존 데이터 삭제 완료\n');
}
```

---

## 📊 임포트 프로세스

```
1. CSV 파일 로드 (EUC-KR 인코딩)
   ↓
2. 헤더 파싱 및 컬럼 매핑
   ↓
3. 데이터 파싱 (14,585줄)
   - 중복 체크
   - 영양소 변환
   - NULL 처리
   ↓
4. DB 연결 확인
   ↓
5. 기존 데이터 확인
   ↓
6. Bulk Insert (500개씩 배치)
   ↓
7. 결과 확인 및 샘플 출력
```

---

## 🔄 컬럼 매핑

| CSV 컬럼 | DB 컬럼 | 변환 |
|----------|---------|------|
| 식품명 | `food_name` | 그대로 |
| 영양성분함량기준량 | `serving_size_grams` | 숫자만 추출 |
| 에너지(kcal) | `calories` | parseFloat |
| 단백질(g) | `protein` | parseFloat |
| 지방(g) | `fat` | parseFloat |
| 탄수화물(g) | `carbs` | parseFloat |
| 당류(g) | `sugars` | parseFloat |
| 나트륨(mg) | `sodium` | parseFloat |
| 콜레스테롤(mg) | `cholesterol` | parseFloat |
| 트랜스지방산(g) | `trans_fat` | parseFloat |

### 제공량 변환 예시
```javascript
"100ml" → 100.00
"100g"  → 100.00
"230.3" → 230.30
```

### NULL 처리
```javascript
빈 값 "" → null
0 → 0 (그대로 저장)
```

---

## ⏱️ 예상 소요 시간

- **데이터 파싱:** ~10초
- **DB 저장:** ~30초 (500개씩 배치)
- **총 소요 시간:** ~1분

---

## 📋 예상 출력

```
=== 영양 데이터 임포트 시작 ===

📂 CSV 파일 로드 중...
✅ 총 14,585개 라인 로드 완료

📋 컬럼 수: 51
✅ 컬럼 매핑 완료

🔄 데이터 파싱 중...
   처리 중... 1,000개
   처리 중... 2,000개
   ...
   처리 중... 14,000개
✅ 데이터 파싱 완료: 14,584개
⚠️  건너뛴 항목: 1개

🔌 DB 연결 확인 중...
✅ DB 연결 성공

📊 현재 DB에 저장된 데이터: 0개

💾 DB에 저장 중...
   저장 중... 500/14,584
   저장 중... 1,000/14,584
   ...
   저장 중... 14,500/14,584

✅ DB 저장 완료: 14,584개 저장됨

=== 임포트 완료 ===
📊 총 DB 데이터: 14,584개
✅ 새로 추가됨: 14,584개

=== 샘플 데이터 (첫 3개) ===

1. 토스트(식빵)
   - 제공량: 100g
   - 칼로리: 84 kcal
   - 단백질: 2.5g
   - 지방: 1.33g
   - 탄수화물: 15.55g

2. 트위스터 샌드위치
   - 제공량: 100g
   - 칼로리: 56 kcal
   - 단백질: 3.6g
   - 지방: 2.96g
   - 탄수화물: 3.3g

3. 파운드케이크
   - 제공량: 100g
   - 칼로리: 226 kcal
   - 단백질: 3.5g
   - 지방: 11.79g
   - 탄수화물: 26.67g

🎉 모든 작업이 완료되었습니다!

👋 DB 연결 종료
```

---

## 🔧 문제 해결

### 1. `iconv-lite` 모듈 오류
```bash
npm install iconv-lite
```

### 2. CSV 파일을 찾을 수 없음
```
❌ CSV 파일을 찾을 수 없습니다
```
→ CSV 파일이 프로젝트 루트에 있는지 확인

### 3. DB 연결 오류
```
❌ Unable to connect to the database
```
→ `.env` 파일의 DB 설정 확인
→ MySQL 서버가 실행 중인지 확인

### 4. 중복 데이터 오류
```
⚠️  중복 건너뜀: 토스트(식빵)
```
→ 정상 동작 (중복은 자동으로 건너뜀)

### 5. 메모리 부족 오류
Node.js 메모리 증가:
```bash
node --max-old-space-size=4096 import-nutrition-data.js
```

---

## ✅ 임포트 후 확인

### 1. 데이터 개수 확인
```sql
SELECT COUNT(*) FROM NutritionData;
-- 예상: 14,584개
```

### 2. 샘플 데이터 확인
```sql
SELECT * FROM NutritionData LIMIT 5;
```

### 3. 음식 검색 테스트
```sql
SELECT * FROM NutritionData 
WHERE food_name LIKE '%닭%' 
LIMIT 10;
```

### 4. 영양소 NULL 비율 확인
```sql
SELECT 
  COUNT(*) as total,
  SUM(CASE WHEN calories IS NULL THEN 1 ELSE 0 END) as null_calories,
  SUM(CASE WHEN protein IS NULL THEN 1 ELSE 0 END) as null_protein
FROM NutritionData;
```

---

## 🎉 완료 후

이제 다음 API가 작동합니다:

### 음식 검색 API
```javascript
GET /api/meals/search?q=닭
```

### 음식 상세 정보
```javascript
GET /api/meals/:food_name
```

### 자동완성
```javascript
GET /api/meals/autocomplete?q=치킨
```

---

## 📝 참고

- **데이터 출처:** 식품의약품안전처
- **데이터 기준일:** 2025-04-08
- **총 식품 수:** 14,585개
- **컬럼 수:** 51개 (사용: 10개)
- **인코딩:** EUC-KR
- **배치 크기:** 500개



