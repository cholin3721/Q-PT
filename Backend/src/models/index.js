const { sequelize } = require('../config/db.config');

// 모델 정의
const User = require('./user.model')(sequelize);
const InBody = require('./inbody.model')(sequelize);
const Goal = require('./goal.model')(sequelize);
const { MealLog, LoggedFood, NutritionData } = require('./meal.model')(sequelize);
const { 
  MuscleGroup, 
  Exercise, 
  ExerciseMuscleGroup, 
  Routine, 
  RoutineSet, 
  WorkoutPlan, 
  PlannedSet, 
  IntervalPhase 
} = require('./workout.model')(sequelize);
const AIFeedback = require('./ai.model')(sequelize);

// 관계 설정
// User 관계
User.hasMany(InBody, { foreignKey: 'user_id', as: 'inbodies' });
User.hasMany(Goal, { foreignKey: 'user_id', as: 'goals' });
User.hasMany(MealLog, { foreignKey: 'user_id', as: 'mealLogs' });
User.hasMany(WorkoutPlan, { foreignKey: 'user_id', as: 'workoutPlans' });
User.hasMany(Routine, { foreignKey: 'user_id', as: 'routines' });
User.hasMany(Exercise, { foreignKey: 'user_id', as: 'customExercises' });
User.hasMany(AIFeedback, { foreignKey: 'user_id', as: 'feedbacks' });

// InBody 관계
InBody.belongsTo(User, { foreignKey: 'user_id', as: 'user' });

// Goal 관계
Goal.belongsTo(User, { foreignKey: 'user_id', as: 'user' });

// MealLog 관계
MealLog.belongsTo(User, { foreignKey: 'user_id', as: 'user' });
MealLog.hasMany(LoggedFood, { foreignKey: 'meal_log_id', as: 'foods' });

// LoggedFood 관계
LoggedFood.belongsTo(MealLog, { foreignKey: 'meal_log_id', as: 'mealLog' });

// Exercise 관계
Exercise.belongsTo(User, { foreignKey: 'user_id', as: 'user' });
Exercise.belongsToMany(MuscleGroup, { 
  through: ExerciseMuscleGroup, 
  foreignKey: 'exercise_id',
  otherKey: 'muscle_group_id',
  as: 'muscleGroups'
});

// MuscleGroup 관계
MuscleGroup.belongsToMany(Exercise, { 
  through: ExerciseMuscleGroup, 
  foreignKey: 'muscle_group_id',
  otherKey: 'exercise_id',
  as: 'exercises'
});

// Routine 관계
Routine.belongsTo(User, { foreignKey: 'user_id', as: 'user' });
Routine.hasMany(RoutineSet, { foreignKey: 'routine_id', as: 'sets' });

// RoutineSet 관계
RoutineSet.belongsTo(Routine, { foreignKey: 'routine_id', as: 'routine' });
RoutineSet.belongsTo(Exercise, { foreignKey: 'exercise_id', as: 'exercise' });

// WorkoutPlan 관계
WorkoutPlan.belongsTo(User, { foreignKey: 'user_id', as: 'user' });
WorkoutPlan.hasMany(PlannedSet, { foreignKey: 'plan_id', as: 'sets' });

// PlannedSet 관계
PlannedSet.belongsTo(WorkoutPlan, { foreignKey: 'plan_id', as: 'workoutPlan' });
PlannedSet.belongsTo(Exercise, { foreignKey: 'exercise_id', as: 'exercise' });
PlannedSet.hasMany(IntervalPhase, { foreignKey: 'set_id', as: 'phases' });

// IntervalPhase 관계
IntervalPhase.belongsTo(PlannedSet, { foreignKey: 'set_id', as: 'plannedSet' });

// AIFeedback 관계
AIFeedback.belongsTo(User, { foreignKey: 'user_id', as: 'user' });

// ExerciseMuscleGroup 관계
ExerciseMuscleGroup.belongsTo(Exercise, { foreignKey: 'exercise_id', as: 'exercise' });
ExerciseMuscleGroup.belongsTo(MuscleGroup, { foreignKey: 'muscle_group_id', as: 'muscleGroup' });

module.exports = {
  sequelize,
  User,
  InBody,
  Goal,
  MealLog,
  LoggedFood,
  NutritionData,
  MuscleGroup,
  Exercise,
  ExerciseMuscleGroup,
  Routine,
  RoutineSet,
  WorkoutPlan,
  PlannedSet,
  IntervalPhase,
  AIFeedback
};
