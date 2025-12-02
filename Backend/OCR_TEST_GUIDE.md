# 인바디 OCR API 테스트 가이드

## 🎯 완료된 작업

### 1. DB 마이그레이션 ✅
- `body_water` (체수분)
- `protein` (단백질)
- `lean_body_mass` (제지방량)
- `visceral_fat_level` (내장지방레벨)
- `waist_hip_ratio` (복부지방률)

### 2. API 컨트롤러 업데이트 ✅
- 개선된 파싱 로직 적용
- 섹션 기반 파싱 (체성분분석 ~ 신체변화)
- 정확한 키워드 및 유닛 매칭
- 새로운 5개 컬럼 지원

### 3. Sequelize 모델 업데이트 ✅
- `InBody` 모델에 5개 필수 컬럼 추가

---

## 🧪 테스트 방법

### 1️⃣ 백엔드 서버 실행
```bash
cd Backend
node index.js
```

**기대 출력:**
```
Server running on port 3000
Database connection established
```

### 2️⃣ OCR API 테스트 (새 터미널)
```bash
cd Backend
node test-ocr-api.js
```

**기대 결과:**
```
=== 인바디 OCR API 엔드포인트 테스트 ===

✅ 테스트 이미지: Backend/test-inbody.jpg
📏 파일 크기: 599.94 KB

🔐 로그인 중...
✅ 로그인 성공
🎫 토큰: eyJhbGciOiJIUzI1NiI...

📤 OCR API 호출 중...
✅ OCR 처리 완료!

=== 추출된 인바디 데이터 ===
{
  "testDate": "2025-11-19",
  "height": 156.9,
  "weight": 59.1,
  "muscleMass": 23.1,
  "fatMass": 14.4,
  "bmi": 24.0,
  "bodyFatPercentage": 24.3,
  "basalMetabolicRate": 1245,
  "bodyWater": 30.6,
  "protein": 8.2,
  "leanBodyMass": 44.7,
  "visceralFatLevel": 12,
  "waistHipRatio": 0.95,
  "segmentalAnalysis": {}
}

✅ 결과 저장: Backend/test-ocr-api-result.json

=== 데이터 검증 ===
✅ height: 156.9 (기대: > 100cm)
✅ weight: 59.1 (기대: > 20kg)
✅ muscleMass: 23.1 (기대: > 5kg)
✅ fatMass: 14.4 (기대: > 0kg)
✅ bmi: 24.0 (기대: 10~60)
✅ bodyFatPercentage: 24.3 (기대: 0~100%)
✅ basalMetabolicRate: 1245 (기대: 500~5000kcal)
✅ bodyWater: 30.6 (기대: > 10L)
✅ protein: 8.2 (기대: > 3kg)
✅ leanBodyMass: 44.7 (기대: > 10kg)
✅ visceralFatLevel: 12 (기대: 1~30)
✅ waistHipRatio: 0.95 (기대: 0.5~1.5)

📊 추출 성공률: 12/12 (100.0%)
```

---

## 🔧 문제 해결

### 서버가 실행되지 않는 경우
```
❌ 오류 발생: connect ECONNREFUSED 127.0.0.1:3000
```

**해결:** 백엔드 서버를 먼저 실행하세요
```bash
cd Backend
node index.js
```

### 로그인 실패
```
❌ 오류 발생: Request failed with status code 401
```

**해결:** 테스트 사용자를 생성하거나, `test-ocr-api.js` 파일에서 로그인 정보를 수정하세요
```javascript
const loginResponse = await axios.post('http://localhost:3000/api/auth/login', {
  email: 'your-email@example.com',  // 실제 사용자 이메일로 변경
  password: 'your-password'          // 실제 비밀번호로 변경
});
```

### Clova OCR API 설정 오류
```
❌ 네이버 클로바 OCR API 설정이 없습니다.
```

**해결:** `.env` 파일에 API 키를 설정하세요
```env
NAVER_CLOVA_OCR_URL=https://your-clova-ocr-url
NAVER_CLOVA_OCR_SECRET=your-clova-ocr-secret
```

---

## 📊 개선된 파싱 로직 특징

### 1. 섹션 기반 파싱
- **체성분분석** ~ **신체변화** 구간만 파싱
- 히스토리 데이터와 혼동 방지

### 2. 정확한 키워드 매칭
- 유닛과 함께 매칭 (`(kg)`, `(L)`, `cm`)
- 값 범위 검증 (예: 신장 100~250cm)

### 3. 다양한 포맷 지원
- `156.9cm` (단위 붙은 형태)
- `체중 (kg) 59.1` (키워드 + 단위 + 값)
- `골격근량 (kg) 23.1` (띄어쓰기 변형)

### 4. 특수 값 처리
- 내장지방레벨: 기준선(10) 제외하고 실제값 추출
- 복부지방률: "높음" 키워드 다음의 0.9x 값 추출

---

## 🎉 다음 단계

1. **프론트엔드 통합**
   - Flutter 앱에서 이미지 업로드 기능 구현
   - OCR 결과를 화면에 표시

2. **자동 목표 설정**
   - 인바디 데이터를 기반으로 Goal 자동 생성
   - 적정체중, 지방조절, 근육조절 활용

3. **다양한 인바디 양식 지원**
   - test3.jpg ~ test7.jpg 테스트
   - 키워드 매핑 추가 (예: "체지방" vs "체지방량")

4. **오류 처리 개선**
   - OCR 실패 시 사용자 피드백
   - 파싱 실패 필드별 안내



