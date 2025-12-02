const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const InBody = sequelize.define('InBody', {
    inbody_id: {
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
    test_date: {
      type: DataTypes.DATEONLY,
      allowNull: false
    },
    height: {
      type: DataTypes.DECIMAL(5, 2),
      allowNull: true
    },
    weight: {
      type: DataTypes.DECIMAL(5, 2),
      allowNull: true
    },
    muscle_mass: {
      type: DataTypes.DECIMAL(5, 2),
      allowNull: true
    },
    fat_mass: {
      type: DataTypes.DECIMAL(5, 2),
      allowNull: true
    },
    bmi: {
      type: DataTypes.DECIMAL(4, 2),
      allowNull: true
    },
    body_fat_percentage: {
      type: DataTypes.DECIMAL(4, 2),
      allowNull: true
    },
    basal_metabolic_rate: {
      type: DataTypes.INTEGER,
      allowNull: true
    },
    segmental_analysis: {
      type: DataTypes.JSON,
      allowNull: true
    },
    // 필수 추가 컬럼 (2025-11-19)
    body_water: {
      type: DataTypes.DECIMAL(5, 2),
      allowNull: true,
      comment: '체수분(L)'
    },
    protein: {
      type: DataTypes.DECIMAL(5, 2),
      allowNull: true,
      comment: '단백질(kg)'
    },
    lean_body_mass: {
      type: DataTypes.DECIMAL(5, 2),
      allowNull: true,
      comment: '제지방량(kg)'
    },
    visceral_fat_level: {
      type: DataTypes.INTEGER,
      allowNull: true,
      comment: '내장지방레벨 (1-30)'
    },
    waist_hip_ratio: {
      type: DataTypes.DECIMAL(4, 2),
      allowNull: true,
      comment: '복부지방률'
    }
  }, {
    tableName: 'InBody',
    timestamps: false
  });

  return InBody;
};
