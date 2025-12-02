const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const MealLog = sequelize.define('MealLog', {
    meal_log_id: {
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
    meal_date: {
      type: DataTypes.DATEONLY,
      allowNull: false
    },
    meal_type: {
      type: DataTypes.INTEGER,
      allowNull: false,
      comment: 'n번째 식사'
    },
    image_url: {
      type: DataTypes.STRING(2048),
      allowNull: true
    }
  }, {
    tableName: 'MealLog',
    timestamps: false
  });

  const LoggedFood = sequelize.define('LoggedFood', {
    logged_food_id: {
      type: DataTypes.BIGINT,
      primaryKey: true,
      autoIncrement: true
    },
    meal_log_id: {
      type: DataTypes.BIGINT,
      allowNull: false,
      references: {
        model: 'MealLog',
        key: 'meal_log_id'
      }
    },
    food_name: {
      type: DataTypes.STRING(100),
      allowNull: false
    },
    serving_size_grams: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: true
    },
    calories: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: true
    },
    protein: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: true
    },
    fat: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: true
    },
    carbs: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: true
    }
  }, {
    tableName: 'LoggedFood',
    timestamps: false
  });

  const NutritionData = sequelize.define('NutritionData', {
    nutrition_data_id: {
      type: DataTypes.BIGINT,
      primaryKey: true,
      autoIncrement: true
    },
    food_name: {
      type: DataTypes.STRING(100),
      allowNull: false,
      unique: true
    },
    serving_size_grams: {
      type: DataTypes.DECIMAL(10, 2),
      defaultValue: 100.00
    },
    calories: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: true
    },
    protein: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: true
    },
    fat: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: true
    },
    carbs: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: true
    },
    sugars: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: true
    },
    sodium: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: true
    },
    cholesterol: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: true
    },
    trans_fat: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: true
    }
  }, {
    tableName: 'NutritionData',
    timestamps: false
  });

  return { MealLog, LoggedFood, NutritionData };
};
