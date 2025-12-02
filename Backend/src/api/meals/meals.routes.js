const express = require('express');
const router = express.Router();
const mealsController = require('./meals.controller');
const authMiddleware = require('../../middleware/auth.middleware');
const upload = require('../../middleware/upload.middleware');

router.post('/image-analysis', authMiddleware, upload.single('file'), mealsController.imageAnalysis);
router.post('/', authMiddleware, mealsController.createMeal);
router.get('/', authMiddleware, mealsController.getMeals);

module.exports = router;