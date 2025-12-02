const { AIFeedback, User, InBody, Goal, MealLog, LoggedFood, WorkoutPlan, PlannedSet, Exercise } = require('../../models');
const OpenAI = require('openai');

// OpenAI 클라이언트 초기화
const openai = process.env.OPENAI_API_KEY ? new OpenAI({
  apiKey: process.env.OPENAI_API_KEY
}) : null;

exports.requestFeedback = async (req, res) => {
  try {
    const userId = req.user.user_id;
    const { period } = req.body; // 'week' | 'month'

    // 사용자 최신 데이터 수집
    const user = await User.findByPk(userId);
    const latestInBody = await InBody.findOne({
      where: { user_id: userId },
      order: [['test_date', 'DESC']]
    });
    const activeGoal = await Goal.findOne({
      where: { user_id: userId, is_active: true }
    });

    // 기간 설정
    const daysAgo = period === 'month' ? 30 : 7;
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - daysAgo);

    // 최근 식단 데이터
    const recentMeals = await MealLog.findAll({
      where: {
        user_id: userId,
        meal_date: {
          [require('sequelize').Op.gte]: startDate
        }
      },
      include: [{
        model: LoggedFood,
        as: 'foods'
      }],
      order: [['meal_date', 'DESC']]
    });

    // 최근 운동 데이터
    const recentWorkouts = await WorkoutPlan.findAll({
      where: {
        user_id: userId,
        plan_date: {
          [require('sequelize').Op.gte]: startDate
        }
      },
      include: [{
        model: PlannedSet,
        as: 'sets',
        include: [{
          model: Exercise,
          as: 'exercise'
        }]
      }],
      order: [['plan_date', 'DESC']]
    });

    // 데이터 요약
    const nutritionSummary = summarizeNutrition(recentMeals);
    const workoutSummary = summarizeWorkouts(recentWorkouts);

    // 사용 가능한 운동 목록 가져오기 (사용자 등록 + 시스템 기본)
    const availableExercises = await Exercise.findAll({
      where: {
        [require('sequelize').Op.or]: [
          { user_id: null }, // 시스템 기본 운동
          { user_id: userId } // 사용자 등록 운동
        ]
      },
      attributes: ['exercise_id', 'exercise_name', 'exercise_type']
    });

    // OpenAI API 호출
    let feedbackContent = null;
    
    if (openai && (recentMeals.length > 0 || recentWorkouts.length > 0)) {
      try {
        feedbackContent = await generateAIFeedback({
          period,
          user: {
            nickname: user.nickname,
            inbody: latestInBody,
            goal: activeGoal
          },
          nutrition: nutritionSummary,
          workouts: workoutSummary,
          availableExercises
        });
      } catch (error) {
        console.error('⚠️  AI 피드백 생성 실패, Mock 데이터 사용:', error.message);
      }
    }
    
    // OpenAI 실패 또는 미사용 시 Mock 데이터
    if (!feedbackContent) {
      feedbackContent = {
        analysis: `지난 ${period === 'month' ? '한 달' : '일주일'}간의 데이터를 분석했습니다. 꾸준한 식단 기록과 운동이 필요합니다.`,
        recommendations: {
          nutrition: {
            protein: 120,
            carbs: 250,
            fat: 65,
            calories: 2000
          },
          exercises: [
            { name: '벤치프레스', type: 'weight', sets: 3, reps: 10, weight: 60, duration: null, intensity: null, reason: '가슴 근력 강화', isInDatabase: true },
            { name: '스쿼트', type: 'weight', sets: 4, reps: 12, weight: 80, duration: null, intensity: null, reason: '하체 근력 강화', isInDatabase: true },
            { name: '바벨로우', type: 'weight', sets: 3, reps: 10, weight: 50, duration: null, intensity: null, reason: '등 근력 강화', isInDatabase: true },
            { name: '러닝', type: 'cardio', sets: 1, reps: null, weight: null, duration: 30, intensity: 'moderate', reason: '심폐지구력 향상', isInDatabase: true }
          ]
        }
      };
    }

    // 피드백 저장
    const feedback = await AIFeedback.create({
      user_id: userId,
      feedback_content: feedbackContent
    });

    res.json({
      feedbackId: feedback.feedback_id,
      feedbackContent: feedback.feedback_content,
      createdAt: feedback.created_at
    });
  } catch (error) {
    console.error('❌ AI 피드백 요청 오류:', error);
    console.error('❌ 에러 스택:', error.stack);
    res.status(500).json({ 
      message: 'AI 피드백 요청 중 오류가 발생했습니다.',
      error: error.message 
    });
  }
};

// 영양소 데이터 요약
function summarizeNutrition(meals) {
  let totalCalories = 0, totalProtein = 0, totalCarbs = 0, totalFat = 0;
  let daysWithMeals = new Set();

  meals.forEach(meal => {
    daysWithMeals.add(meal.meal_date);
    meal.foods.forEach(food => {
      totalCalories += parseFloat(food.calories) || 0;
      totalProtein += parseFloat(food.protein) || 0;
      totalCarbs += parseFloat(food.carbs) || 0;
      totalFat += parseFloat(food.fat) || 0;
    });
  });

  const numDays = daysWithMeals.size || 1;

  return {
    avgDailyCalories: Math.round(totalCalories / numDays),
    avgDailyProtein: Math.round(totalProtein / numDays),
    avgDailyCarbs: Math.round(totalCarbs / numDays),
    avgDailyFat: Math.round(totalFat / numDays),
    totalMeals: meals.length,
    daysTracked: numDays
  };
}

// 운동 데이터 요약
function summarizeWorkouts(workouts) {
  let totalSets = 0, completedSets = 0;
  const exerciseFrequency = {};

  workouts.forEach(workout => {
    workout.sets.forEach(set => {
      totalSets++;
      if (set.status === 'completed') {
        completedSets++;
      }
      
      const exerciseName = set.exercise?.exercise_name || 'Unknown';
      exerciseFrequency[exerciseName] = (exerciseFrequency[exerciseName] || 0) + 1;
    });
  });

  return {
    totalWorkouts: workouts.length,
    totalSets,
    completedSets,
    completionRate: totalSets > 0 ? Math.round((completedSets / totalSets) * 100) : 0,
    topExercises: Object.entries(exerciseFrequency)
      .sort(([, a], [, b]) => b - a)
      .slice(0, 5)
      .map(([name, count]) => ({ name, count }))
  };
}

// OpenAI를 통한 AI 피드백 생성
async function generateAIFeedback(data) {
  const { period, user, nutrition, workouts, availableExercises } = data;
  
  const exerciseList = availableExercises.map(ex => `${ex.exercise_name} (${ex.exercise_type})`).join(', ');
  
  const prompt = `당신은 전문 피트니스 트레이너입니다. 다음 사용자의 ${period === 'month' ? '한 달' : '일주일'}간 데이터를 분석하여 피드백을 제공해주세요.

사용자 정보:
- 닉네임: ${user.nickname}
- 체중: ${user.inbody?.weight || 'N/A'}kg
- 체지방률: ${user.inbody?.body_fat_percentage || 'N/A'}%
- 근육량: ${user.inbody?.muscle_mass || 'N/A'}kg
- 목표: ${user.goal?.goal_type || 'N/A'}

영양 섭취 현황 (일평균):
- 칼로리: ${nutrition.avgDailyCalories}kcal
- 단백질: ${nutrition.avgDailyProtein}g
- 탄수화물: ${nutrition.avgDailyCarbs}g
- 지방: ${nutrition.avgDailyFat}g
- 기록한 날: ${nutrition.daysTracked}일

운동 현황:
- 총 운동 횟수: ${workouts.totalWorkouts}회
- 완료한 세트: ${workouts.completedSets}/${workouts.totalSets} (${workouts.completionRate}%)
- 주요 운동: ${workouts.topExercises.map(e => e.name).join(', ')}

사용자가 등록한 운동 목록:
${exerciseList}

다음 JSON 형식으로 응답해주세요. 
**중요 규칙**:
1. 근력운동(weight)을 최소 3개 이상 반드시 포함하세요.
2. 총 운동 개수, 세트 수, 무게, 반복수는 사용자 수준에 맞게 자유롭게 최적으로 설계하세요.
3. 필요하다면 유산소 운동(cardio)도 추가하세요.
4. 위 목록의 운동(isInDatabase: true)과 새 운동(isInDatabase: false)을 자유롭게 조합하세요.

응답 형식:
{
  "analysis": "150자 이내의 전반적인 분석 (긍정적이고 구체적으로)",
  "recommendations": {
    "nutrition": {
      "protein": 추천 일일 단백질(g),
      "carbs": 추천 일일 탄수화물(g),
      "fat": 추천 일일 지방(g),
      "calories": 추천 일일 칼로리(kcal)
    },
    "exercises": [
      {
        "name": "운동명",
        "type": "weight" 또는 "cardio",
        "sets": 추천세트수,
        "reps": 추천반복수 (weight만, cardio는 null),
        "weight": 추천무게kg (weight만, cardio는 null),
        "duration": 추천시간분 (cardio만, weight는 null),
        "intensity": "low/moderate/high" (cardio만, weight는 null),
        "reason": "추천 이유 (20자 이내)",
        "isInDatabase": true 또는 false
      }
    ]
  }
}

예시:
{"name": "벤치프레스", "type": "weight", "sets": 4, "reps": 10, "weight": 65, "duration": null, "intensity": null, "reason": "가슴 근력", "isInDatabase": true}
{"name": "러닝", "type": "cardio", "sets": 1, "reps": null, "weight": null, "duration": 25, "intensity": "moderate", "reason": "심폐 향상", "isInDatabase": true}`;

  try {
    const completion = await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [{ role: "user", content: prompt }],
      response_format: { type: "json_object" },
      temperature: 0.7
    });

    return JSON.parse(completion.choices[0].message.content);
  } catch (error) {
    console.error('⚠️  OpenAI API 호출 오류:', error.message);
    console.log('📝 Mock 데이터로 fallback합니다...');
    
    // OpenAI API 실패 시 Mock 데이터 반환
    return null;
  }
}

exports.getFeedbacks = async (req, res) => {
  try {
    const userId = req.user.user_id;

    const feedbacks = await AIFeedback.findAll({
      where: { user_id: userId },
      order: [['created_at', 'DESC']],
      attributes: ['feedback_id', 'feedback_content', 'created_at']
    });

    const formattedFeedbacks = feedbacks.map(feedback => ({
      feedbackId: feedback.feedback_id,
      feedbackContent: feedback.feedback_content,
      createdAt: feedback.created_at
    }));

    res.json(formattedFeedbacks);
  } catch (error) {
    console.error('AI 피드백 조회 오류:', error);
    res.status(500).json({ message: 'AI 피드백 조회 중 오류가 발생했습니다.' });
  }
};

// AI 추천 운동을 운동계획으로 등록
exports.applyRecommendedWorkout = async (req, res) => {
  const { sequelize } = require('../../config/db.config');
  const transaction = await sequelize.transaction();

  try {
    console.log('🎯 AI 운동계획 적용 시작');
    const userId = req.user.user_id;
    const { feedbackId, dates } = req.body; // dates: ['2024-01-15', '2024-01-17', ...]
    console.log('📥 요청 데이터:', { userId, feedbackId, dates });

    if (!feedbackId || !dates || !Array.isArray(dates) || dates.length === 0) {
      console.log('❌ 유효성 검증 실패: 피드백 ID 또는 날짜 배열 누락');
      await transaction.rollback();
      return res.status(400).json({ 
        message: '피드백 ID와 날짜 배열이 필요합니다.' 
      });
    }

    // 피드백 가져오기
    console.log('🔍 피드백 조회 중...', { feedbackId, userId });
    const feedback = await AIFeedback.findOne({
      where: { 
        feedback_id: feedbackId,
        user_id: userId 
      },
      transaction
    });
    console.log('📦 피드백 조회 결과:', feedback ? '찾음' : '없음');

    if (!feedback) {
      console.log('❌ 피드백을 찾을 수 없음');
      await transaction.rollback();
      return res.status(404).json({ message: '피드백을 찾을 수 없습니다.' });
    }

    console.log('🏋️ 추천 운동 확인 중...');
    const exercises = feedback.feedback_content?.recommendations?.exercises;
    console.log('📋 추천 운동 목록:', exercises);
    if (!exercises || !Array.isArray(exercises)) {
      console.log('❌ 추천 운동이 없거나 배열이 아님');
      await transaction.rollback();
      return res.status(400).json({ message: '추천 운동이 없습니다.' });
    }

    const createdPlans = [];
    console.log(`📅 총 ${dates.length}개 날짜에 계획 생성 시작`);

    for (const date of dates) {
      console.log(`\n🗓️  날짜 처리 중: ${date}`);
      // 해당 날짜에 이미 운동계획이 있는지 확인
      const existingPlan = await WorkoutPlan.findOne({
        where: { user_id: userId, plan_date: date },
        transaction
      });

      let workoutPlan;
      if (existingPlan) {
        console.log('✅ 기존 운동계획 발견');
        workoutPlan = existingPlan;
      } else {
        console.log('➕ 새 운동계획 생성 중...');
        // 새로운 운동계획 생성
        workoutPlan = await WorkoutPlan.create({
          user_id: userId,
          plan_date: date,
          status: 'planned',
          memo: 'AI 추천 운동계획'
        }, { transaction });
        console.log('✅ 운동계획 생성 완료:', workoutPlan.plan_id);
      }

      // 운동별로 처리
      console.log(`💪 ${exercises.length}개 운동 처리 시작`);
      for (let i = 0; i < exercises.length; i++) {
        const exercise = exercises[i];
        console.log(`\n  🏋️  운동 ${i+1}/${exercises.length}: ${exercise.name}`);
        console.log('     운동 데이터:', exercise);
        let exerciseId;

        // DB에 운동이 있는지 확인
        if (exercise.isInDatabase) {
          console.log('     🔍 DB에서 운동 검색 중...');
          const existingExercise = await Exercise.findOne({
            where: { exercise_name: exercise.name },
            transaction
          });
          
          if (existingExercise) {
            console.log('     ✅ 기존 운동 발견:', existingExercise.exercise_id);
            exerciseId = existingExercise.exercise_id;
          } else {
            console.log('     ⚠️  DB에 없어서 새로 생성');
            // DB에 있다고 했지만 실제로 없는 경우, 새로 생성
            const newExercise = await Exercise.create({
              exercise_name: exercise.name,
              exercise_type: exercise.type || 'weight',
              user_id: userId
            }, { transaction });
            console.log('     ✅ 새 운동 생성 완료:', newExercise.exercise_id);
            exerciseId = newExercise.exercise_id;
          }
        } else {
          console.log('     ➕ 새 운동 생성 중...');
          // 새 운동 생성
          const newExercise = await Exercise.create({
            exercise_name: exercise.name,
            exercise_type: exercise.type || (exercise.weight ? 'weight' : 'cardio'),
            user_id: userId
          }, { transaction });
          console.log('     ✅ 새 운동 생성 완료:', newExercise.exercise_id);
          exerciseId = newExercise.exercise_id;
        }

        // 각 세트 생성
        const sets = exercise.sets || 3;
        console.log(`     📊 ${sets}개 세트 생성 중...`);
        for (let setNum = 1; setNum <= sets; setNum++) {
          await PlannedSet.create({
            plan_id: workoutPlan.plan_id,
            exercise_id: exerciseId,
            display_order: i + 1,
            set_number: setNum,
            status: 'pending',
            target_weight_kg: exercise.weight || null,
            target_reps: exercise.reps || null,
            target_duration_minutes: exercise.duration || null,
            target_intensity: exercise.intensity || null
          }, { transaction });
        }
        console.log(`     ✅ ${sets}개 세트 생성 완료`);
      }

      createdPlans.push({
        planId: workoutPlan.plan_id,
        date: workoutPlan.plan_date
      });
      console.log(`✅ ${date} 날짜 처리 완료\n`);
    }

    console.log('💾 트랜잭션 커밋 중...');
    await transaction.commit();
    console.log('🎉 모든 운동계획 등록 완료!');

    res.json({
      message: 'AI 추천 운동계획이 성공적으로 등록되었습니다.',
      plans: createdPlans
    });

  } catch (error) {
    console.error('\n❌❌❌ AI 추천 운동계획 등록 오류 발생 ❌❌❌');
    console.error('에러 타입:', error.constructor.name);
    console.error('에러 메시지:', error.message);
    console.error('전체 에러:', error);
    console.error('스택 트레이스:', error.stack);
    
    await transaction.rollback();
    console.log('🔄 트랜잭션 롤백 완료');
    
    res.status(500).json({ 
      message: 'AI 추천 운동계획 등록 중 오류가 발생했습니다.',
      error: error.message,
      details: process.env.NODE_ENV === 'development' ? error.stack : undefined
    });
  }
};