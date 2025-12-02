# Q-PT Backend API

Q-PT (Quiet Personal Trainer) 백엔드 API 서버입니다.

## 설치 및 실행

### 1. 의존성 설치
```bash
npm install
```

### 2. 환경 변수 설정
`.env` 파일을 생성하고 다음 변수들을 설정하세요:

```env
# 데이터베이스 설정
DB_HOST=localhost
DB_PORT=3306
DB_NAME=q_pt
DB_USER=root
DB_PASS=

# JWT 설정
JWT_SECRET=your-super-secret-jwt-key-here

# 서버 설정
PORT=3000

# AI API 설정 (선택사항)
OPENAI_API_KEY=your-openai-api-key-here
GOOGLE_VISION_API_KEY=your-google-vision-api-key-here
```

### 3. 데이터베이스 설정
MySQL 데이터베이스에 `Q-PT_Create_Query.sql` 파일을 실행하여 테이블을 생성하세요.

### 4. 서버 실행
```bash
# 개발 모드
npm run dev

# 프로덕션 모드
npm start
```

## API 엔드포인트

### 인증 (Authentication)
- `POST /api/auth/login/{provider}` - 소셜 로그인

### 사용자 (Users)
- `GET /api/users/nickname/check` - 닉네임 중복 확인
- `PUT /api/users/me/nickname` - 닉네임 설정
- `GET /api/users/me` - 내 정보 조회

### 인바디 (InBody)
- `POST /api/inbody/ocr` - InBody 결과지 OCR 분석
- `POST /api/inbody` - InBody 정보 등록
- `GET /api/inbody` - InBody 이력 조회

### 목표 (Goals)
- `POST /api/goals` - 목표 설정/수정
- `GET /api/goals/active` - 현재 목표 조회

### 식단 관리 (Meals)
- `POST /api/meals/image-analysis` - 음식 사진 AI 분석
- `POST /api/meals` - 식단 기록
- `GET /api/meals` - 일별 식단 조회

### 운동 플래너 (Workout)
- `GET /api/workouts/exercises` - 운동 라이브러리 조회
- `POST /api/workouts/exercises` - 사용자 운동 등록
- `POST /api/workouts/workout-plans` - 일일 운동 계획 생성
- `GET /api/workouts/workout-plans` - 특정 날짜 운동 계획 조회
- `PUT /api/workouts/workout-plans/sets/{setId}` - 운동 세트 수행 결과 기록

### AI 트레이너 (AI Trainer)
- `POST /api/ai/feedback` - AI 피드백 요청
- `GET /api/ai/feedback` - 과거 AI 피드백 조회

## 기술 스택

- **Backend**: Node.js, Express.js
- **Database**: MySQL
- **ORM**: Sequelize
- **Authentication**: JWT
- **AI**: OpenAI API (예정)

## 프로젝트 구조

```
Backend/
├── src/
│   ├── api/           # API 라우트 및 컨트롤러
│   ├── config/        # 데이터베이스 설정
│   ├── middleware/    # 인증 미들웨어
│   └── models/        # Sequelize 모델
├── index.js           # 서버 진입점
└── package.json
```
