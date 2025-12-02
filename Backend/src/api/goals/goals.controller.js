const { Goal, AIFeedback } = require('../../models');

exports.setGoal = async (req, res) => {
  try {
    const userId = req.user.user_id;
    const { targetWeight, targetMuscleMass, targetFatMass } = req.body;

    // 기존 활성 목표 비활성화
    await Goal.update(
      { is_active: false },
      { where: { user_id: userId, is_active: true } }
    );

    // 새 목표 생성
    const goal = await Goal.create({
      user_id: userId,
      target_weight: targetWeight,
      target_muscle_mass: targetMuscleMass,
      target_fat_mass: targetFatMass,
      is_active: true
    });

    res.status(201).json({
      goalId: goal.goal_id,
      targetWeight: goal.target_weight,
      targetMuscleMass: goal.target_muscle_mass,
      targetFatMass: goal.target_fat_mass,
      isActive: goal.is_active,
      createdAt: goal.created_at
    });
  } catch (error) {
    console.error('목표 설정 오류:', error);
    res.status(500).json({ message: '목표 설정 중 오류가 발생했습니다.' });
  }
};

exports.getActiveGoal = async (req, res) => {
  try {
    const userId = req.user.user_id;
    
    const goal = await Goal.findOne({
      where: { user_id: userId, is_active: true },
      order: [['created_at', 'DESC']]
    });

    if (!goal) {
      return res.status(404).json({ message: '활성화된 목표가 없습니다.' });
    }

    res.json({
      goalId: goal.goal_id,
      targetWeight: goal.target_weight,
      targetMuscleMass: goal.target_muscle_mass,
      targetFatMass: goal.target_fat_mass,
      targetCalories: goal.target_calories,
      targetProtein: goal.target_protein,
      targetCarbs: goal.target_carbs,
      targetFat: goal.target_fat,
      goalType: goal.goal_type,
      isActive: goal.is_active,
      createdAt: goal.created_at
    });
  } catch (error) {
    console.error('목표 조회 오류:', error);
    res.status(500).json({ message: '목표 조회 중 오류가 발생했습니다.' });
  }
};

// AI 추천 영양소를 목표로 설정
exports.applyAINutrition = async (req, res) => {
  try {
    const userId = req.user.user_id;
    const { feedbackId } = req.body;

    if (!feedbackId) {
      return res.status(400).json({ message: '피드백 ID가 필요합니다.' });
    }

    // AI 피드백 가져오기
    const feedback = await AIFeedback.findOne({
      where: { 
        feedback_id: feedbackId,
        user_id: userId 
      }
    });

    if (!feedback) {
      return res.status(404).json({ message: '피드백을 찾을 수 없습니다.' });
    }

    const nutrition = feedback.feedback_content?.recommendations?.nutrition;
    if (!nutrition) {
      return res.status(400).json({ message: '영양소 추천 데이터가 없습니다.' });
    }

    // 기존 활성 목표가 있는지 확인
    let goal = await Goal.findOne({
      where: { user_id: userId, is_active: true }
    });

    if (goal) {
      // 기존 목표 업데이트
      await goal.update({
        target_calories: nutrition.calories,
        target_protein: nutrition.protein,
        target_carbs: nutrition.carbs,
        target_fat: nutrition.fat
      });
    } else {
      // 새 목표 생성
      goal = await Goal.create({
        user_id: userId,
        target_calories: nutrition.calories,
        target_protein: nutrition.protein,
        target_carbs: nutrition.carbs,
        target_fat: nutrition.fat,
        is_active: true
      });
    }

    res.json({
      message: 'AI 추천 영양소가 목표로 설정되었습니다.',
      goalId: goal.goal_id,
      targetCalories: goal.target_calories,
      targetProtein: goal.target_protein,
      targetCarbs: goal.target_carbs,
      targetFat: goal.target_fat
    });
  } catch (error) {
    console.error('❌ AI 영양소 적용 오류:', error);
    res.status(500).json({ 
      message: 'AI 영양소 적용 중 오류가 발생했습니다.',
      error: error.message 
    });
  }
};

// 사용자가 영양소 목표 직접 수정
exports.updateNutritionGoal = async (req, res) => {
  try {
    const userId = req.user.user_id;
    const { targetCalories, targetProtein, targetCarbs, targetFat } = req.body;

    // 활성 목표 찾기
    let goal = await Goal.findOne({
      where: { user_id: userId, is_active: true }
    });

    if (!goal) {
      // 목표가 없으면 새로 생성
      goal = await Goal.create({
        user_id: userId,
        target_calories: targetCalories,
        target_protein: targetProtein,
        target_carbs: targetCarbs,
        target_fat: targetFat,
        is_active: true
      });
    } else {
      // 기존 목표 업데이트
      await goal.update({
        target_calories: targetCalories !== undefined ? targetCalories : goal.target_calories,
        target_protein: targetProtein !== undefined ? targetProtein : goal.target_protein,
        target_carbs: targetCarbs !== undefined ? targetCarbs : goal.target_carbs,
        target_fat: targetFat !== undefined ? targetFat : goal.target_fat
      });
    }

    res.json({
      message: '영양소 목표가 업데이트되었습니다.',
      goalId: goal.goal_id,
      targetCalories: goal.target_calories,
      targetProtein: goal.target_protein,
      targetCarbs: goal.target_carbs,
      targetFat: goal.target_fat
    });
  } catch (error) {
    console.error('❌ 영양소 목표 수정 오류:', error);
    res.status(500).json({ 
      message: '영양소 목표 수정 중 오류가 발생했습니다.',
      error: error.message 
    });
  }
};