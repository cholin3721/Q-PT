const express = require('express');
const router = express.Router();
const goalsController = require('./goals.controller');
const authMiddleware = require('../../middleware/auth.middleware');

router.post('/', authMiddleware, goalsController.setGoal);
router.get('/active', authMiddleware, goalsController.getActiveGoal);
router.post('/apply-nutrition', authMiddleware, goalsController.applyAINutrition);
router.put('/nutrition', authMiddleware, goalsController.updateNutritionGoal);

module.exports = router;