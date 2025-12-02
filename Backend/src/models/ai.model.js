const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const AIFeedback = sequelize.define('AIFeedback', {
    feedback_id: {
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
    feedback_content: {
      type: DataTypes.JSON,
      allowNull: false
    },
    created_at: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW
    }
  }, {
    tableName: 'AIFeedback',
    timestamps: false
  });

  return AIFeedback;
};
