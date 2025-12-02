const express = require('express');
const router = express.Router();
const workoutsController = require('./workouts.controller');
const authMiddleware = require('../../middleware/auth.middleware');

router.get('/exercises', authMiddleware, workoutsController.getExercises);
router.post('/exercises', authMiddleware, workoutsController.addExercise);
router.post('/workout-plans', authMiddleware, workoutsController.createPlan);
router.get('/workout-plans', authMiddleware, workoutsController.getPlans);
router.post('/workout-plans/:planId/sets', authMiddleware, workoutsController.addSetToPlan);
router.put('/workout-plans/sets/:setId', authMiddleware, workoutsController.updateSet);

module.exports = router;