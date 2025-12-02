const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const MuscleGroup = sequelize.define('MuscleGroup', {
    muscle_group_id: {
      type: DataTypes.BIGINT,
      primaryKey: true,
      autoIncrement: true
    },
    name: {
      type: DataTypes.STRING(50),
      allowNull: false,
      unique: true
    }
  }, {
    tableName: 'MuscleGroup',
    timestamps: false
  });

  const Exercise = sequelize.define('Exercise', {
    exercise_id: {
      type: DataTypes.BIGINT,
      primaryKey: true,
      autoIncrement: true
    },
    exercise_name: {
      type: DataTypes.STRING(100),
      allowNull: false,
      unique: true
    },
    exercise_type: {
      type: DataTypes.ENUM('weight', 'cardio'),
      allowNull: false
    },
    user_id: {
      type: DataTypes.BIGINT,
      allowNull: true,
      references: {
        model: 'User',
        key: 'user_id'
      }
    }
  }, {
    tableName: 'Exercise',
    timestamps: false
  });

  const ExerciseMuscleGroup = sequelize.define('ExerciseMuscleGroup', {
    exercise_id: {
      type: DataTypes.BIGINT,
      primaryKey: true,
      references: {
        model: 'Exercise',
        key: 'exercise_id'
      }
    },
    muscle_group_id: {
      type: DataTypes.BIGINT,
      primaryKey: true,
      references: {
        model: 'MuscleGroup',
        key: 'muscle_group_id'
      }
    }
  }, {
    tableName: 'ExerciseMuscleGroup',
    timestamps: false
  });

  const Routine = sequelize.define('Routine', {
    routine_id: {
      type: DataTypes.BIGINT,
      primaryKey: true,
      autoIncrement: true
    },
    user_id: {
      type: DataTypes.BIGINT,
      allowNull: false,
      references: {
        model: 'User',
        key: 'user_id'
      }
    },
    routine_name: {
      type: DataTypes.STRING(100),
      allowNull: false
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: true
    }
  }, {
    tableName: 'Routine',
    timestamps: false
  });

  const RoutineSet = sequelize.define('RoutineSet', {
    routine_set_id: {
      type: DataTypes.BIGINT,
      primaryKey: true,
      autoIncrement: true
    },
    routine_id: {
      type: DataTypes.BIGINT,
      allowNull: false,
      references: {
        model: 'Routine',
        key: 'routine_id'
      }
    },
    exercise_id: {
      type: DataTypes.BIGINT,
      allowNull: false,
      references: {
        model: 'Exercise',
        key: 'exercise_id'
      }
    },
    display_order: {
      type: DataTypes.INTEGER,
      allowNull: true
    },
    set_number: {
      type: DataTypes.INTEGER,
      allowNull: true
    },
    target_weight_kg: {
      type: DataTypes.DECIMAL(6, 2),
      allowNull: true
    },
    target_reps: {
      type: DataTypes.INTEGER,
      allowNull: true
    },
    target_duration_minutes: {
      type: DataTypes.INTEGER,
      allowNull: true
    },
    target_intensity: {
      type: DataTypes.STRING(50),
      allowNull: true
    },
    is_interval: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    },
    target_rounds: {
      type: DataTypes.INTEGER,
      allowNull: true
    }
  }, {
    tableName: 'RoutineSet',
    timestamps: false
  });

  const WorkoutPlan = sequelize.define('WorkoutPlan', {
    plan_id: {
      type: DataTypes.BIGINT,
      primaryKey: true,
      autoIncrement: true
    },
    user_id: {
      type: DataTypes.BIGINT,
      allowNull: false,
      references: {
        model: 'User',
        key: 'user_id'
      }
    },
    plan_date: {
      type: DataTypes.DATEONLY,
      allowNull: false
    },
    status: {
      type: DataTypes.ENUM('planned', 'active', 'completed'),
      defaultValue: 'planned'
    },
    memo: {
      type: DataTypes.TEXT,
      allowNull: true
    }
  }, {
    tableName: 'WorkoutPlan',
    timestamps: false,
    indexes: [
      {
        unique: true,
        fields: ['user_id', 'plan_date']
      }
    ]
  });

  const PlannedSet = sequelize.define('PlannedSet', {
    set_id: {
      type: DataTypes.BIGINT,
      primaryKey: true,
      autoIncrement: true
    },
    plan_id: {
      type: DataTypes.BIGINT,
      allowNull: false,
      references: {
        model: 'WorkoutPlan',
        key: 'plan_id'
      }
    },
    exercise_id: {
      type: DataTypes.BIGINT,
      allowNull: false,
      references: {
        model: 'Exercise',
        key: 'exercise_id'
      }
    },
    display_order: {
      type: DataTypes.INTEGER,
      allowNull: true
    },
    set_number: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    status: {
      type: DataTypes.ENUM('pending', 'completed', 'skipped'),
      defaultValue: 'pending'
    },
    failure_reason: {
      type: DataTypes.ENUM('FATIGUE', 'PAIN', 'LACK_OF_TIME'),
      allowNull: true
    },
    target_weight_kg: {
      type: DataTypes.DECIMAL(6, 2),
      allowNull: true
    },
    actual_weight_kg: {
      type: DataTypes.DECIMAL(6, 2),
      allowNull: true
    },
    target_reps: {
      type: DataTypes.INTEGER,
      allowNull: true
    },
    actual_reps: {
      type: DataTypes.INTEGER,
      allowNull: true
    },
    target_duration_minutes: {
      type: DataTypes.INTEGER,
      allowNull: true
    },
    actual_duration_minutes: {
      type: DataTypes.INTEGER,
      allowNull: true
    },
    target_intensity: {
      type: DataTypes.STRING(50),
      allowNull: true
    },
    actual_intensity: {
      type: DataTypes.STRING(50),
      allowNull: true
    }
  }, {
    tableName: 'PlannedSet',
    timestamps: false
  });

  const IntervalPhase = sequelize.define('IntervalPhase', {
    phase_id: {
      type: DataTypes.BIGINT,
      primaryKey: true,
      autoIncrement: true
    },
    set_id: {
      type: DataTypes.BIGINT,
      allowNull: false,
      references: {
        model: 'PlannedSet',
        key: 'set_id'
      }
    },
    phase_order: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    target_duration_seconds: {
      type: DataTypes.INTEGER,
      allowNull: true
    },
    actual_duration_seconds: {
      type: DataTypes.INTEGER,
      allowNull: true
    },
    target_intensity: {
      type: DataTypes.STRING(50),
      allowNull: true
    },
    actual_intensity: {
      type: DataTypes.STRING(50),
      allowNull: true
    }
  }, {
    tableName: 'IntervalPhase',
    timestamps: false
  });

  return {
    MuscleGroup,
    Exercise,
    ExerciseMuscleGroup,
    Routine,
    RoutineSet,
    WorkoutPlan,
    PlannedSet,
    IntervalPhase
  };
};
