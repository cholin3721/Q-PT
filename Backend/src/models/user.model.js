const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const User = sequelize.define('User', {
    user_id: {
      type: DataTypes.BIGINT,
      primaryKey: true,
      autoIncrement: true
    },
    provider: {
      type: DataTypes.ENUM('google', 'kakao'),
      allowNull: false
    },
    provider_id: {
      type: DataTypes.STRING(255),
      allowNull: false
    },
    nickname: {
      type: DataTypes.STRING(50),
      unique: true,
      allowNull: true
    },
    email: {
      type: DataTypes.STRING(255),
      unique: true,
      allowNull: true
    },
    created_at: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW
    }
  }, {
    tableName: 'User',
    timestamps: false,
    indexes: [
      {
        unique: true,
        fields: ['provider', 'provider_id']
      }
    ]
  });

  return User;
};