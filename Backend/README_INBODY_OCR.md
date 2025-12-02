# 인바디 OCR 기능 사용 가이드

## 개요
네이버 클로바 OCR API를 사용하여 인바디 결과지 이미지에서 자동으로 데이터를 추출하는 기능입니다.

## 네이버 클로바 OCR API 설정 방법

### 1. 네이버 클라우드 플랫폼 가입
1. [네이버 클라우드 플랫폼](https://www.ncloud.com/) 접속
2. 회원가입 및 로그인

### 2. CLOVA OCR 서비스 신청
1. 콘솔 > AI·NAVER API > CLOVA OCR 선택
2. "이용 신청하기" 클릭
3. General OCR 또는 Template OCR 선택 (General OCR 권장)

### 3. API 키 발급
1. CLOVA OCR 콘솔에서 "도메인 생성" 클릭
2. 도메인 이름 입력 (예: qpt-inbody-ocr)
3. OCR 타입 선택: General
4. 생성 완료 후 다음 정보 확인:
   - **Invoke URL**: API Gateway URL
   - **Secret Key**: 인증용 시크릿 키

### 4. 환경 변수 설정
`.env` 파일에 다음 내용 추가:
```env
NAVER_CLOVA_OCR_URL=https://your-ocr-api-url.apigw.ntruss.com/custom/v1/xxxxx/xxxxxxxxxxxxxxxx
NAVER_CLOVA_OCR_SECRET=your_secret_key_here
```

## API 사용 방법

### 엔드포인트
```
POST /api/inbody/ocr
```

### 헤더
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: multipart/form-data
```

### 요청 (Form Data)
```
image: [이미지 파일] (jpg, jpeg, png, gif / 최대 10MB)
```

### 응답 예시
```json
{
  "testDate": "2024-11-18",
  "height": 175.0,
  "weight": 75.5,
  "muscleMass": 35.2,
  "fatMass": 15.8,
  "bmi": 24.6,
  "bodyFatPercentage": 20.9,
  "basalMetabolicRate": 1650,
  "segmentalAnalysis": {}
}
```

## curl 테스트 예시
```bash
curl -X POST http://localhost:3000/api/inbody/ocr \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -F "image=@/path/to/inbody-result.jpg"
```

## Postman 테스트 방법
1. Method: POST
2. URL: `http://localhost:3000/api/inbody/ocr`
3. Headers:
   - `Authorization: Bearer YOUR_JWT_TOKEN`
4. Body:
   - form-data 선택
   - Key: `image` (Type: File)
   - Value: 인바디 이미지 파일 선택

## 지원되는 인바디 데이터
- ✅ 신장 (Height)
- ✅ 체중 (Weight)
- ✅ 골격근량 (Skeletal Muscle Mass)
- ✅ 체지방량 (Body Fat Mass)
- ✅ BMI (Body Mass Index)
- ✅ 체지방률 (Percent Body Fat)
- ✅ 기초대사량 (Basal Metabolic Rate)

## 주의사항
1. 이미지는 가능한 밝고 선명해야 합니다.
2. 인바디 결과지 전체가 포함되어야 합니다.
3. 흐릿하거나 각도가 심하게 기울어진 이미지는 정확도가 떨어질 수 있습니다.
4. OCR 결과는 사용자가 확인 후 수정할 수 있도록 UI를 구성하는 것을 권장합니다.

## 비용
- 네이버 클로바 OCR: 월 1,000건까지 무료
- 이후 건당 약 10원 (문서 크기에 따라 다름)

## 문제 해결

### API 설정 오류
```json
{
  "message": "네이버 클로바 OCR API 설정이 없습니다. .env 파일을 확인하세요.",
  "hint": "NAVER_CLOVA_OCR_URL과 NAVER_CLOVA_OCR_SECRET을 .env 파일에 설정하세요."
}
```
→ `.env` 파일에 API URL과 Secret Key가 올바르게 설정되어 있는지 확인

### 이미지 업로드 오류
```json
{
  "message": "이미지 파일을 업로드해주세요."
}
```
→ Form Data에서 `image` 필드에 파일이 첨부되었는지 확인

### 파일 형식 오류
```json
{
  "message": "이미지 파일만 업로드 가능합니다. (jpg, jpeg, png, gif)"
}
```
→ 지원되는 이미지 형식인지 확인

## 향후 개선 계획
- [ ] 부위별 근육 분석 (Segmental Analysis) 파싱 추가
- [ ] 측정 날짜 자동 인식
- [ ] OCR 신뢰도(confidence) 기반 검증
- [ ] 이미지 전처리 (회전 보정, 노이즈 제거)




