# InBody 테이블 마이그레이션 가이드

## 📋 개요
InBody 테이블에 필수 컬럼 5개를 추가하는 마이그레이션입니다.

## 🆕 추가되는 컬럼

| 컬럼명 | 타입 | 설명 | 중요도 |
|--------|------|------|--------|
| body_water | DECIMAL(5,2) | 체수분(L) | ⭐⭐⭐⭐ |
| protein | DECIMAL(5,2) | 단백질(kg) | ⭐⭐⭐⭐ |
| lean_body_mass | DECIMAL(5,2) | 제지방량(kg) | ⭐⭐⭐⭐ |
| visceral_fat_level | INT | 내장지방레벨 (1-30) | ⭐⭐⭐⭐⭐ |
| waist_hip_ratio | DECIMAL(4,2) | 복부지방률 | ⭐⭐⭐⭐ |

## 🚀 마이그레이션 실행 방법

### 1단계: 백업 (필수!)
```sql
-- 데이터베이스 백업
mysqldump -u root -p q_pt > backup_qpt_before_migration.sql

-- 또는 InBody 테이블만 백업
mysqldump -u root -p q_pt InBody > backup_inbody_before_migration.sql
```

### 2단계: SQL 실행
```bash
# MySQL 접속
mysql -u root -p q_pt

# 또는 파일로 실행
mysql -u root -p q_pt < alter_inbody_essential.sql
```

### 3단계: 확인
```sql
-- 컬럼 추가 확인
DESCRIBE InBody;

-- 기존 데이터 확인 (NULL 값이 정상)
SELECT 
    inbody_id, 
    user_id, 
    height, 
    weight,
    body_water,
    protein,
    lean_body_mass,
    visceral_fat_level,
    waist_hip_ratio
FROM InBody 
LIMIT 5;
```

## ✅ 예상 결과

### 변경 전 (8개 컬럼)
```
+-------------------------+--------------+------+
| Field                   | Type         | Null |
+-------------------------+--------------+------+
| inbody_id               | bigint       | NO   |
| user_id                 | bigint       | NO   |
| test_date               | date         | NO   |
| height                  | decimal(5,2) | YES  |
| weight                  | decimal(5,2) | YES  |
| muscle_mass             | decimal(5,2) | YES  |
| fat_mass                | decimal(5,2) | YES  |
| bmi                     | decimal(4,2) | YES  |
| body_fat_percentage     | decimal(4,2) | YES  |
| basal_metabolic_rate    | int          | YES  |
| segmental_analysis      | json         | YES  |
+-------------------------+--------------+------+
```

### 변경 후 (13개 컬럼)
```
+-------------------------+--------------+------+
| Field                   | Type         | Null |
+-------------------------+--------------+------+
| inbody_id               | bigint       | NO   |
| user_id                 | bigint       | NO   |
| test_date               | date         | NO   |
| height                  | decimal(5,2) | YES  |
| weight                  | decimal(5,2) | YES  |
| muscle_mass             | decimal(5,2) | YES  |
| fat_mass                | decimal(5,2) | YES  |
| bmi                     | decimal(4,2) | YES  |
| body_fat_percentage     | decimal(4,2) | YES  |
| basal_metabolic_rate    | int          | YES  |
| segmental_analysis      | json         | YES  |
| body_water              | decimal(5,2) | YES  | ← 🆕
| protein                 | decimal(5,2) | YES  | ← 🆕
| lean_body_mass          | decimal(5,2) | YES  | ← 🆕
| visceral_fat_level      | int          | YES  | ← 🆕
| waist_hip_ratio         | decimal(4,2) | YES  | ← 🆕
+-------------------------+--------------+------+
```

## 🔄 롤백 방법 (문제 발생 시)

```sql
-- 추가한 컬럼 삭제
ALTER TABLE InBody
DROP COLUMN body_water,
DROP COLUMN protein,
DROP COLUMN lean_body_mass,
DROP COLUMN visceral_fat_level,
DROP COLUMN waist_hip_ratio;

-- 또는 백업 복원
mysql -u root -p q_pt < backup_inbody_before_migration.sql
```

## ⚠️ 주의사항

1. **기존 데이터는 영향 없음**
   - 새로운 컬럼은 모두 NULL 허용
   - 기존 InBody 레코드의 새 컬럼은 NULL

2. **앱 재시작 필요**
   - Sequelize 모델이 업데이트됨
   - Node.js 서버 재시작 필요

3. **API 호환성**
   - 기존 API는 정상 작동 (새 필드는 NULL 반환)
   - OCR 기능만 새 필드 사용

## 📊 데이터 활용 예시

### 변경 전 (44.4% 활용)
```json
{
  "height": 156.9,
  "weight": 59.1,
  "muscleMass": 19.3,
  "fatMass": 22.1,
  "bmi": 24.0,
  "bodyFatPercentage": 37.5,
  "basalMetabolicRate": 1168
}
```

### 변경 후 (72.2% 활용) ✨
```json
{
  "height": 156.9,
  "weight": 59.1,
  "muscleMass": 19.3,
  "fatMass": 22.1,
  "bmi": 24.0,
  "bodyFatPercentage": 37.5,
  "basalMetabolicRate": 1168,
  "bodyWater": 27.2,           // 🆕
  "protein": 7.1,              // 🆕
  "leanBodyMass": 37.0,        // 🆕
  "visceralFatLevel": 13,      // 🆕
  "waistHipRatio": 0.98        // 🆕
}
```

## 🎯 건강 지표 활용

### 내장지방레벨 (가장 중요!)
```javascript
if (visceralFatLevel < 10) {
  return "정상";
} else if (visceralFatLevel < 15) {
  return "주의";
} else {
  return "위험"; // 건강 위험 경고!
}
```

### 체수분 비율
```javascript
const waterPercentage = (bodyWater / weight) * 100;
// 정상 범위: 남성 50-65%, 여성 45-60%
```

### 단백질 비율
```javascript
const proteinPercentage = (protein / weight) * 100;
// 근육 생성 상태 평가
```

## 📝 체크리스트

- [ ] 데이터베이스 백업 완료
- [ ] SQL 파일 실행
- [ ] DESCRIBE InBody로 컬럼 확인
- [ ] Sequelize 모델 업데이트 확인
- [ ] Node.js 서버 재시작
- [ ] API 테스트 (기존 기능 정상 작동 확인)
- [ ] OCR 테스트 (새 필드 저장 확인)

## 🚀 완료 후 다음 단계

1. ✅ DB 마이그레이션 완료
2. ⏭️ API 컨트롤러에 파싱 로직 적용
3. ⏭️ OCR 엔드포인트 테스트
4. ⏭️ 프론트엔드 UI 업데이트

---

**마이그레이션 준비 완료!** 🎉



