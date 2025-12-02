const express = require('express');
const router = express.Router();
const aiController = require('./ai.controller');
const authMiddleware = require('../../middleware/auth.middleware');

router.post('/feedback', authMiddleware, aiController.requestFeedback);
router.get('/feedback', authMiddleware, aiController.getFeedbacks);
router.post('/apply-workout', authMiddleware, aiController.applyRecommendedWorkout);

module.exports = router;