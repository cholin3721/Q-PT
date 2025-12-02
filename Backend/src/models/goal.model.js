const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const Goal = sequelize.define('Goal', {
    goal_id: {
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
    target_weight: {
      type: DataTypes.DECIMAL(5, 2),
      allowNull: true
    },
    target_fat_mass: {
      type: DataTypes.DECIMAL(5, 2),
      allowNull: true
    },
    target_muscle_mass: {
      type: DataTypes.DECIMAL(5, 2),
      allowNull: true
    },
    target_calories: {
      type: DataTypes.INTEGER,
      allowNull: true
    },
    target_protein: {
      type: DataTypes.DECIMAL(6, 2),
      allowNull: true
    },
    target_carbs: {
      type: DataTypes.DECIMAL(6, 2),
      allowNull: true
    },
    target_fat: {
      type: DataTypes.DECIMAL(6, 2),
      allowNull: true
    },
    goal_type: {
      type: DataTypes.ENUM('weight_loss', 'muscle_gain', 'maintenance', 'custom'),
      defaultValue: 'custom'
    },
    is_active: {
      type: DataTypes.BOOLEAN,
      defaultValue: true
    },
    created_at: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW
    }
  }, {
    tableName: 'Goal',
    timestamps: false
  });

  return Goal;
};
