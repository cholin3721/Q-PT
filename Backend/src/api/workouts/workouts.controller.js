const { 
  Exercise, 
  MuscleGroup, 
  ExerciseMuscleGroup, 
  WorkoutPlan, 
  PlannedSet 
} = require('../../models');

exports.getExercises = async (req, res) => {
  try {
    const userId = req.user.user_id;
    const { search } = req.query;

    let whereClause = {};
    if (search) {
      whereClause.exercise_name = {
        [require('sequelize').Op.like]: `%${search}%`
      };
    }

    const exercises = await Exercise.findAll({
      where: {
        [require('sequelize').Op.or]: [
          { user_id: null }, // 시스템 기본 운동
          { user_id: userId } // 사용자 추가 운동
        ],
        ...whereClause
      },
      include: [{
        model: MuscleGroup,
        as: 'muscleGroups',
        through: { attributes: [] },
        attributes: ['muscle_group_id', 'name']
      }],
      order: [['exercise_name', 'ASC']]
    });

    const formattedExercises = exercises.map(exercise => ({
      exerciseId: exercise.exercise_id,
      exerciseName: exercise.exercise_name,
      exerciseType: exercise.exercise_type,
      muscleGroups: exercise.muscleGroups.map(mg => ({
        muscleGroupId: mg.muscle_group_id,
        name: mg.name
      }))
    }));

    res.json(formattedExercises);
  } catch (error) {
    console.error('운동 라이브러리 조회 오류:', error);
    res.status(500).json({ message: '운동 라이브러리 조회 중 오류가 발생했습니다.' });
  }
};

exports.addExercise = async (req, res) => {
  try {
    const userId = req.user.user_id;
    const { exerciseName, exerciseType, muscleGroupIds } = req.body;

    // 새 운동 생성
    const exercise = await Exercise.create({
      exercise_name: exerciseName,
      exercise_type: exerciseType,
      user_id: userId
    });

    // 운동 부위 연결
    if (muscleGroupIds && muscleGroupIds.length > 0) {
      const exerciseMuscleGroups = muscleGroupIds.map(muscleGroupId => ({
        exercise_id: exercise.exercise_id,
        muscle_group_id: muscleGroupId
      }));
      await ExerciseMuscleGroup.bulkCreate(exerciseMuscleGroups);
    }

    res.status(201).json({
      exerciseId: exercise.exercise_id,
      exerciseName: exercise.exercise_name,
      exerciseType: exercise.exercise_type
    });
  } catch (error) {
    console.error('운동 등록 오류:', error);
    res.status(500).json({ message: '운동 등록 중 오류가 발생했습니다.' });
  }
};

exports.createPlan = async (req, res) => {
  try {
    const userId = req.user.user_id;
    const { planDate, memo, sets } = req.body;

    // 운동 계획 생성
    const workoutPlan = await WorkoutPlan.create({
      user_id: userId,
      plan_date: planDate,
      memo: memo,
      status: 'planned'
    });

    // 운동 세트 생성
    if (sets && sets.length > 0) {
      const plannedSets = sets.map((set, index) => ({
        plan_id: workoutPlan.plan_id,
        exercise_id: set.exerciseId,
        display_order: index + 1,
        set_number: set.setNumber,
        target_weight_kg: set.targetWeightKg,
        target_reps: set.targetReps,
        target_duration_minutes: set.targetDurationMinutes,
        target_intensity: set.targetIntensity,
        status: 'pending'
      }));

      await PlannedSet.bulkCreate(plannedSets);
    }

    res.status(201).json({
      planId: workoutPlan.plan_id,
      planDate: workoutPlan.plan_date,
      status: workoutPlan.status,
      memo: workoutPlan.memo
    });
  } catch (error) {
    console.error('운동 계획 생성 오류:', error);
    res.status(500).json({ message: '운동 계획 생성 중 오류가 발생했습니다.' });
  }
};

exports.getPlans = async (req, res) => {
  try {
    const userId = req.user.user_id;
    const { date } = req.query;

    if (!date) {
      return res.status(400).json({ message: '날짜를 입력해주세요.' });
    }

    const workoutPlan = await WorkoutPlan.findOne({
      where: { user_id: userId, plan_date: date },
      include: [{
        model: PlannedSet,
        as: 'sets',
        include: [{
          model: Exercise,
          as: 'exercise',
          attributes: ['exercise_id', 'exercise_name', 'exercise_type']
        }],
        order: [['display_order', 'ASC'], ['set_number', 'ASC']]
      }]
    });

    if (!workoutPlan) {
      return res.status(404).json({ message: '해당 날짜의 운동 계획이 없습니다.' });
    }

    const formattedSets = workoutPlan.sets.map(set => ({
      setId: set.set_id,
      exerciseId: set.exercise_id,
      exerciseName: set.exercise.exercise_name,
      exerciseType: set.exercise.exercise_type,
      displayOrder: set.display_order,
      setNumber: set.set_number,
      status: set.status,
      failureReason: set.failure_reason,
      targetWeightKg: set.target_weight_kg,
      actualWeightKg: set.actual_weight_kg,
      targetReps: set.target_reps,
      actualReps: set.actual_reps,
      targetDurationMinutes: set.target_duration_minutes,
      actualDurationMinutes: set.actual_duration_minutes,
      targetIntensity: set.target_intensity,
      actualIntensity: set.actual_intensity
    }));

    res.json({
      planId: workoutPlan.plan_id,
      planDate: workoutPlan.plan_date,
      status: workoutPlan.status,
      memo: workoutPlan.memo,
      sets: formattedSets
    });
  } catch (error) {
    console.error('운동 계획 조회 오류:', error);
    res.status(500).json({ message: '운동 계획 조회 중 오류가 발생했습니다.' });
  }
};

exports.updateSet = async (req, res) => {
  try {
    const { setId } = req.params;
    const { status, actualWeightKg, actualReps, actualDurationMinutes, actualIntensity, failureReason } = req.body;

    const plannedSet = await PlannedSet.findByPk(setId);
    if (!plannedSet) {
      return res.status(404).json({ message: '운동 세트를 찾을 수 없습니다.' });
    }

    // 세트 정보 업데이트
    await PlannedSet.update({
      status,
      actual_weight_kg: actualWeightKg,
      actual_reps: actualReps,
      actual_duration_minutes: actualDurationMinutes,
      actual_intensity: actualIntensity,
      failure_reason: failureReason
    }, {
      where: { set_id: setId }
    });

    const updatedSet = await PlannedSet.findByPk(setId);

    res.json({
      setId: updatedSet.set_id,
      status: updatedSet.status,
      actualWeightKg: updatedSet.actual_weight_kg,
      actualReps: updatedSet.actual_reps,
      actualDurationMinutes: updatedSet.actual_duration_minutes,
      actualIntensity: updatedSet.actual_intensity,
      failureReason: updatedSet.failure_reason
    });
  } catch (error) {
    console.error('운동 세트 업데이트 오류:', error);
    res.status(500).json({ message: '운동 세트 업데이트 중 오류가 발생했습니다.' });
  }
};

// 운동 계획에 세트 추가
exports.addSetToPlan = async (req, res) => {
  try {
    const { planId } = req.params;
    const { exerciseId, targetWeightKg, targetReps, targetDurationMinutes, targetIntensity } = req.body;

    // 운동 계획 존재 확인
    const workoutPlan = await WorkoutPlan.findByPk(planId);
    if (!workoutPlan) {
      return res.status(404).json({ message: '운동 계획을 찾을 수 없습니다.' });
    }

    // 해당 운동의 현재 세트 개수 확인
    const existingSets = await PlannedSet.findAll({
      where: { 
        plan_id: planId, 
        exercise_id: exerciseId 
      },
      order: [['set_number', 'DESC']]
    });

    const nextSetNumber = existingSets.length > 0 ? existingSets[0].set_number + 1 : 1;
    const maxDisplayOrder = await PlannedSet.max('display_order', { where: { plan_id: planId } }) || 0;

    // 새 세트 추가
    const newSet = await PlannedSet.create({
      plan_id: planId,
      exercise_id: exerciseId,
      display_order: maxDisplayOrder + 1,
      set_number: nextSetNumber,
      target_weight_kg: targetWeightKg,
      target_reps: targetReps,
      target_duration_minutes: targetDurationMinutes,
      target_intensity: targetIntensity,
      status: 'pending'
    });

    // 운동 정보 포함해서 반환
    const exercise = await Exercise.findByPk(exerciseId);

    res.status(201).json({
      setId: newSet.set_id,
      exerciseId: newSet.exercise_id,
      exerciseName: exercise.exercise_name,
      exerciseType: exercise.exercise_type,
      displayOrder: newSet.display_order,
      setNumber: newSet.set_number,
      status: newSet.status,
      targetWeightKg: newSet.target_weight_kg,
      targetReps: newSet.target_reps,
      targetDurationMinutes: newSet.target_duration_minutes,
      targetIntensity: newSet.target_intensity
    });
  } catch (error) {
    console.error('세트 추가 오류:', error);
    res.status(500).json({ message: '세트 추가 중 오류가 발생했습니다.' });
  }
};