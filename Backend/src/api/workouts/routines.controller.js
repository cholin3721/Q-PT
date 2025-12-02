// Backend/src/api/workouts/routines.controller.js

const { sequelize } = require('../../config/db.config');

// 루틴 목록 조회 (내 루틴 + 공개 루틴)
exports.getRoutines = async (req, res) => {
  try {
    const userId = req.user.user_id;

    const [routines] = await sequelize.query(`
      SELECT 
        r.routine_id as routineId,
        r.routine_name as routineName,
        r.description,
        r.user_id = ? as isMyRoutine,
        COUNT(DISTINCT rs.exercise_id) as exerciseCount,
        COUNT(rs.routine_set_id) as totalSets
      FROM Routine r
      LEFT JOIN RoutineSet rs ON r.routine_id = rs.routine_id
      WHERE r.user_id = ?
      GROUP BY r.routine_id
      ORDER BY r.routine_name
    `, {
      replacements: [userId, userId],
    });

    return res.json(routines);
  } catch (error) {
    console.error('루틴 목록 조회 실패:', error);
    return res.status(500).json({ message: '루틴 목록 조회에 실패했습니다.' });
  }
};

// 루틴 상세 조회 (운동 목록 포함)
exports.getRoutineDetail = async (req, res) => {
  try {
    const { routineId } = req.params;
    const userId = req.user.user_id;

    // 루틴 기본 정보
    const [routines] = await sequelize.query(`
      SELECT 
        r.routine_id as routineId,
        r.routine_name as routineName,
        r.description,
        r.user_id = ? as isMyRoutine
      FROM Routine r
      WHERE r.routine_id = ?
        AND r.user_id = ?
    `, {
      replacements: [userId, routineId, userId],
    });

    if (routines.length === 0) {
      return res.status(404).json({ message: '루틴을 찾을 수 없습니다.' });
    }

    // 루틴에 포함된 세트들을 운동별로 그룹화
    const [sets] = await sequelize.query(`
      SELECT 
        rs.routine_set_id as routineSetId,
        rs.exercise_id as exerciseId,
        e.exercise_name as exerciseName,
        e.exercise_type as exerciseType,
        rs.display_order as displayOrder,
        rs.set_number as setNumber,
        rs.target_weight_kg as targetWeightKg,
        rs.target_reps as targetReps,
        rs.target_duration_minutes as targetDurationMinutes
      FROM RoutineSet rs
      JOIN Exercise e ON rs.exercise_id = e.exercise_id
      WHERE rs.routine_id = ?
      ORDER BY rs.display_order, rs.set_number
    `, {
      replacements: [routineId],
    });

    // 운동별로 그룹화 및 기본값 계산
    const exerciseMap = {};
    for (const set of sets) {
      const exerciseId = set.exerciseId;
      if (!exerciseMap[exerciseId]) {
        exerciseMap[exerciseId] = {
          exerciseId,
          exerciseName: set.exerciseName,
          exerciseType: set.exerciseType,
          displayOrder: set.displayOrder,
          defaultSets: 0,
          defaultWeightKg: set.targetWeightKg,
          defaultReps: set.targetReps,
          defaultDurationMinutes: set.targetDurationMinutes,
        };
      }
      exerciseMap[exerciseId].defaultSets++;
    }

    const exercises = Object.values(exerciseMap);

    return res.json({
      ...routines[0],
      exercises,
    });
  } catch (error) {
    console.error('루틴 상세 조회 실패:', error);
    return res.status(500).json({ message: '루틴 상세 조회에 실패했습니다.' });
  }
};

// 루틴 생성
exports.createRoutine = async (req, res) => {
  const transaction = await sequelize.transaction();

  try {
    const userId = req.user.user_id;
    const { routineName, description, isPublic, exercises } = req.body;

    // 루틴 생성
    const [result] = await sequelize.query(`
      INSERT INTO Routine (user_id, routine_name, description)
      VALUES (?, ?, ?)
    `, {
      replacements: [userId, routineName, description || null],
      transaction,
    });

    const routineId = result;

    // 세트 추가
    if (exercises && exercises.length > 0) {
      for (const exercise of exercises) {
        // 각 운동의 세트 개수만큼 삽입
        const defaultSets = exercise.defaultSets || 3;
        for (let i = 0; i < defaultSets; i++) {
          await sequelize.query(`
            INSERT INTO RoutineSet (
              routine_id, exercise_id, display_order, set_number,
              target_weight_kg, target_reps, target_duration_minutes
            ) VALUES (?, ?, ?, ?, ?, ?, ?)
          `, {
            replacements: [
              routineId,
              exercise.exerciseId,
              exercise.displayOrder,
              i + 1, // set_number
              exercise.defaultWeightKg || null,
              exercise.defaultReps || null,
              exercise.defaultDurationMinutes || null,
            ],
            transaction,
          });
        }
      }
    }

    await transaction.commit();

    return res.status(201).json({
      message: '루틴이 생성되었습니다.',
      routineId,
    });
  } catch (error) {
    await transaction.rollback();
    console.error('루틴 생성 실패:', error);
    return res.status(500).json({ message: '루틴 생성에 실패했습니다.' });
  }
};

// 루틴 삭제
exports.deleteRoutine = async (req, res) => {
  try {
    const { routineId } = req.params;
    const userId = req.user.user_id;

    const [result] = await sequelize.query(`
      DELETE FROM Routine
      WHERE routine_id = ? AND user_id = ?
    `, {
      replacements: [routineId, userId],
    });

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: '루틴을 찾을 수 없거나 삭제 권한이 없습니다.' });
    }

    return res.json({ message: '루틴이 삭제되었습니다.' });
  } catch (error) {
    console.error('루틴 삭제 실패:', error);
    return res.status(500).json({ message: '루틴 삭제에 실패했습니다.' });
  }
};

