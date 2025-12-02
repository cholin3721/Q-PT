const { MealLog, LoggedFood, NutritionData, sequelize } = require('../../models');
const { ImageAnnotatorClient } = require('@google-cloud/vision');
const { Op } = require('sequelize');
const path = require('path');

// Google Vision API 클라이언트 초기화
const visionClient = new ImageAnnotatorClient({
  keyFilename: path.join(__dirname, '../../../q-pt-479300-26c3c7255839.json')
});

exports.imageAnalysis = async (req, res) => {
  try {
    // 이미지 파일 확인
    if (!req.file) {
      return res.status(400).json({ message: '이미지 파일이 필요합니다.' });
    }

    const imageBuffer = req.file.buffer;

    // Google Vision API로 이미지 분석 (Label Detection + Object Localization)
    const [labelResult] = await visionClient.labelDetection({
      image: { content: imageBuffer }
    });

    const [objectResult] = await visionClient.objectLocalization({
      image: { content: imageBuffer }
    });

    // Label Detection 결과
    const labels = labelResult.labelAnnotations || [];
    
    // Object Localization 결과 (더 정확한 객체 인식)
    const objects = objectResult.localizedObjectAnnotations || [];
    
    // Object Localization에서 음식 관련 객체 추출
    const foodObjects = objects
      .filter(obj => {
        const name = obj.name.toLowerCase();
        // 음식 관련 객체만 필터링
        const foodKeywords = ['food', 'dish', 'meal', 'cuisine', 'stew', 'soup', 'curry', 'tofu', 'kimchi', 'jjigae'];
        return foodKeywords.some(keyword => name.includes(keyword)) && obj.score >= 0.5;
      })
      .sort((a, b) => b.score - a.score)
      .slice(0, 3); // 상위 3개만 사용
    
    // 음식 관련이 아닌 라벨 제외 (Cookware, Bowl, Recipe, Cooking 등)
    const nonFoodLabels = ['cookware', 'bakeware', 'bowl', 'recipe', 'cooking', 'dish', 'plate', 'tableware'];
    
    // 음식 관련 라벨만 필터링하고 신뢰도 순으로 정렬
    const foodLabels = labels
      .filter(label => {
        const lowerDesc = label.description.toLowerCase();
        // 음식 관련이 아니거나 너무 일반적인 라벨 제외
        return label.score >= 0.5 && 
               !nonFoodLabels.some(nonFood => lowerDesc.includes(nonFood)) &&
               lowerDesc !== 'food'; // 너무 일반적인 "Food" 제외
      })
      .sort((a, b) => b.score - a.score) // 신뢰도 높은 순으로 정렬
      .slice(0, 5); // 상위 5개만 사용

    // Object Localization 결과를 라벨에 추가 (더 높은 우선순위)
    const combinedLabels = [];
    
    // Object Localization 결과를 먼저 추가 (더 정확함)
    for (const obj of foodObjects) {
      combinedLabels.push({
        description: obj.name,
        score: obj.score * 1.2 // Object Localization에 가중치 부여
      });
    }
    
    // Label Detection 결과 추가
    for (const label of foodLabels) {
      // 중복 제거
      if (!combinedLabels.some(l => l.description.toLowerCase() === label.description.toLowerCase())) {
        combinedLabels.push({
          description: label.description,
          score: label.score
        });
      }
    }
    
    // 최종 라벨 리스트 (신뢰도 순 정렬)
    const finalFoodLabels = combinedLabels
      .sort((a, b) => b.score - a.score)
      .slice(0, 5);

    if (finalFoodLabels.length === 0) {
      return res.status(400).json({ message: '음식을 인식할 수 없습니다. 다른 사진을 시도해주세요.' });
    }
    
    // 이후 코드에서 foodLabels 대신 finalFoodLabels 사용
    // const foodLabels는 이미 위에서 선언되었으므로 재할당
    const foodLabelsToUse = finalFoodLabels;

    // 영어→한국어 음식명 매핑
    const foodNameMapping = {
      'jjigae': '찌개',
      'kimchi': '김치',
      'stew': '찌개',
      'soup': '국',
      'curry': '카레',
      'rice': '밥',
      'noodle': '면',
      'ramen': '라면',
      'bread': '빵',
      'bun': '빵',
      'chicken': '닭',
      'beef': '소고기',
      'pork': '돼지고기',
      'ham': '햄',
      'hamburger': '햄버거',
      'burger': '버거',
      'sandwich': '샌드위치',
      'fish': '생선',
      'vegetable': '채소',
      'salad': '샐러드',
      'tofu': '두부',
      'bean': '콩',
      'bean curd': '두부',
      'soybean': '콩',
      'doenjang': '된장',
      'gochujang': '고추장'
    };

    // 영어 라벨을 한국어 키워드로 변환
    const convertToKoreanKeyword = (label) => {
      const lowerLabel = label.toLowerCase();
      
      // 긴 매핑부터 확인 (예: "hamburger"가 "ham"보다 먼저 매칭되도록)
      const sortedMappings = Object.entries(foodNameMapping).sort((a, b) => b[0].length - a[0].length);
      
      for (const [eng, kor] of sortedMappings) {
        if (lowerLabel.includes(eng)) {
          return kor;
        }
      }
      
      return null;
    };

    // 모든 라벨에서 한국어 키워드 추출
    const koreanKeywords = [];
    for (const label of foodLabelsToUse) {
      const koreanKeyword = convertToKoreanKeyword(label.description);
      if (koreanKeyword) {
        koreanKeywords.push(koreanKeyword);
      }
    }

    // DB에서 음식 정보 매칭 (신뢰도 순으로)
    const matchedFoods = [];
    const matchedFoodNames = new Set(); // 중복 방지

    // 1단계: 여러 키워드를 모두 포함하는 음식 우선 검색 (예: "김치" + "찌개")
    if (koreanKeywords.length >= 2) {
      const multiMatchFoods = await NutritionData.findAll({
        where: {
          [Op.and]: koreanKeywords.map(k => ({
            food_name: {
              [Op.like]: `%${k}%`
            }
          }))
        },
        limit: 10
      });

      for (const nutritionData of multiMatchFoods) {
        if (!matchedFoodNames.has(nutritionData.food_name)) {
          matchedFoodNames.add(nutritionData.food_name);
          
          // 정확도 점수 계산
          const foodName = nutritionData.food_name;
          let accuracyScore = 1.5; // 여러 키워드 매칭은 기본 점수 높음
          
          // 1. 음식명이 짧을수록 더 구체적 (우선순위 높음)
          const nameLength = foodName.length;
          if (nameLength <= 8) accuracyScore += 0.5; // 매우 짧은 이름 (예: "순두부찌개")
          else if (nameLength <= 12) accuracyScore += 0.3;
          else if (nameLength <= 15) accuracyScore += 0.2;
          else if (nameLength <= 20) accuracyScore += 0.1;
          
          // 2. "간편조리세트", "_" 같은 키워드가 있으면 낮은 우선순위
          if (foodName.includes('간편조리세트') || foodName.includes('_간편')) {
            accuracyScore -= 0.6; // 간편조리세트는 낮은 우선순위
          }
          if (foodName.includes('_') && foodName.split('_').length > 2) {
            accuracyScore -= 0.3; // 언더스코어가 많으면 복잡한 이름
          }
          
          // 3. 정확한 이름 우선 (키워드와 정확히 일치하는 음식명)
          const exactMatchKeywords = ['햄버거', '순두부찌개', '두부찌개', '김치찌개'];
          for (const keyword of exactMatchKeywords) {
            if (foodName === keyword) {
              accuracyScore += 1.0; // 정확한 이름 매칭
              break;
            } else if (foodName.startsWith(keyword) && !foodName.includes('_')) {
              accuracyScore += 0.5; // 키워드로 시작하는 단순한 이름
              break;
            }
          }
          
          // 4. 주요 키워드가 음식명에 포함되는 경우 우선순위 높임
          // "햄버거" 키워드가 있으면 "햄버거"가 포함된 음식 우선
          if (koreanKeywords.includes('버거') || koreanKeywords.includes('햄버거')) {
            if (foodName.includes('햄버거')) {
              accuracyScore += 0.8; // "햄버거" 포함 시 높은 점수
            } else if (foodName.includes('샌드위치') && !foodName.includes('햄버거')) {
              accuracyScore -= 0.3; // "샌드위치"만 있고 "햄버거" 없으면 낮은 점수
            }
          }
          
          // 5. 키워드가 음식명에 포함되는 경우 (예: "햄버거" 키워드 → "햄버거_돼지고기")
          for (const keyword of koreanKeywords) {
            if (foodName.startsWith(keyword) && foodName.length <= keyword.length + 10) {
              accuracyScore += 0.3; // 키워드로 시작하고 길이가 비슷한 경우
            }
          }
          
          // 6. 모든 키워드를 포함하면서 더 짧은 이름 우선
          const keywordCount = koreanKeywords.filter(k => foodName.includes(k)).length;
          if (keywordCount === koreanKeywords.length) {
            accuracyScore += 0.3; // 모든 키워드 포함
          }
          
          matchedFoods.push({
            foodName: nutritionData.food_name,
            calories: parseFloat(nutritionData.calories) || 0,
            protein: parseFloat(nutritionData.protein) || 0,
            fat: parseFloat(nutritionData.fat) || 0,
            carbs: parseFloat(nutritionData.carbs) || 0,
            servingSizeGrams: parseFloat(nutritionData.serving_size_grams) || 100,
            confidence: accuracyScore, // 정확도 점수
            matchType: 'multi-keyword',
            recognizedLabel: koreanKeywords.join(' + '), // 여러 키워드 조합
            originalLabel: koreanKeywords.join(' + ')
          });
        }
      }
    }

    // 2단계: 각 라벨별로 개별 검색
    for (const label of foodLabelsToUse) {
      const labelText = label.description;
      const labelScore = label.score;
      let searchKeywords = [labelText]; // 원본 라벨
      
      // 한국어 키워드 변환 시도
      const koreanKeyword = convertToKoreanKeyword(labelText);
      if (koreanKeyword) {
        searchKeywords.push(koreanKeyword);
      }

      let nutritionData = null;
      let matchType = null; // 'exact', 'partial', 'reverse'

      // 각 키워드로 검색 시도
      for (const keyword of searchKeywords) {
        // 이미 매칭된 음식은 건너뛰기
        if (matchedFoodNames.has(keyword)) {
          nutritionData = await NutritionData.findOne({
            where: { food_name: keyword }
          });
          if (nutritionData) {
            matchType = 'exact';
            break;
          }
        }

        // 정확한 매칭 시도
        nutritionData = await NutritionData.findOne({
          where: {
            food_name: keyword
          }
        });

        if (nutritionData) {
          matchType = 'exact';
          break;
        }

        // 부분 매칭 시도 (키워드가 음식명에 포함)
        nutritionData = await NutritionData.findOne({
          where: {
            food_name: {
              [Op.like]: `%${keyword}%`
            }
          }
        });

        if (nutritionData) {
          matchType = 'partial';
          break;
        }

        // 반대 방향 매칭 (음식명이 키워드에 포함 - 영어인 경우)
        if (keyword.length > 2) {
          nutritionData = await NutritionData.findOne({
            where: {
              food_name: {
                [Op.like]: `%${keyword.split(' ')[0]}%`
              }
            }
          });
        }

        if (nutritionData) {
          matchType = 'reverse';
          break;
        }
      }

      if (nutritionData && !matchedFoodNames.has(nutritionData.food_name)) {
        matchedFoodNames.add(nutritionData.food_name);
        // 한국어 키워드가 있으면 그것을 라벨로 사용, 없으면 원본 라벨 사용
        const labelKey = koreanKeyword || labelText;
        matchedFoods.push({
          foodName: nutritionData.food_name,
          calories: parseFloat(nutritionData.calories) || 0,
          protein: parseFloat(nutritionData.protein) || 0,
          fat: parseFloat(nutritionData.fat) || 0,
          carbs: parseFloat(nutritionData.carbs) || 0,
          servingSizeGrams: parseFloat(nutritionData.serving_size_grams) || 100,
          confidence: labelScore, // Vision API 신뢰도
          matchType: matchType, // 매칭 타입
          recognizedLabel: labelKey, // 인식된 라벨 (한국어 키워드 우선)
          originalLabel: labelText // 원본 라벨 (영어)
        });
      }
    }

    if (matchedFoods.length === 0) {
      return res.status(404).json({ 
        message: '인식된 음식을 데이터베이스에서 찾을 수 없습니다.',
        recognizedLabels: foodLabelsToUse.map(l => l.description)
      });
    }

    // 신뢰도 순으로 정렬 (높은 순)
    matchedFoods.sort((a, b) => b.confidence - a.confidence);

    // 상위 10개까지 반환 (사용자가 선택할 수 있도록)
    const topMatches = matchedFoods.slice(0, 10);

    // 가장 높은 신뢰도의 음식 하나를 추천
    const recommended = topMatches[0];

    // 라벨별로 매칭된 음식들 그룹화
    const foodsByLabel = {};
    for (const food of matchedFoods) {
      const label = food.recognizedLabel || '기타';
      if (!foodsByLabel[label]) {
        foodsByLabel[label] = [];
      }
      foodsByLabel[label].push(food);
    }

    res.json({
      recommended: recommended, // 가장 추천하는 음식
      candidates: topMatches, // 선택 가능한 후보들 (신뢰도 순)
      totalCandidates: matchedFoods.length, // 전체 매칭 개수
      foodsByLabel: foodsByLabel, // 라벨별로 그룹화된 음식들
      recognizedLabels: foodLabelsToUse.map(l => ({
        label: l.description,
        confidence: l.score,
        koreanKeyword: convertToKoreanKeyword(l.description) // 한국어 키워드도 포함
      }))
    });
  } catch (error) {
    console.error('음식 사진 분석 오류:', error);
    res.status(500).json({ message: '음식 사진 분석 중 오류가 발생했습니다.', error: error.message });
  }
};

exports.createMeal = async (req, res) => {
  try {
    const userId = req.user.user_id;
    const { mealDate, mealType, imageUrl, foods } = req.body;

    // 식사 기록 생성
    const mealLog = await MealLog.create({
      user_id: userId,
      meal_date: mealDate,
      meal_type: mealType,
      image_url: imageUrl
    });

    // 음식 정보 저장
    if (foods && foods.length > 0) {
      const loggedFoods = foods.map(food => ({
        meal_log_id: mealLog.meal_log_id,
        food_name: food.foodName,
        serving_size_grams: food.servingSizeGrams || 100,
        calories: food.calories,
        protein: food.protein,
        fat: food.fat,
        carbs: food.carbs
      }));

      await LoggedFood.bulkCreate(loggedFoods);
    }

    res.status(201).json({
      mealLogId: mealLog.meal_log_id,
      mealDate: mealLog.meal_date,
      mealType: mealLog.meal_type,
      imageUrl: mealLog.image_url
    });
  } catch (error) {
    console.error('식단 기록 오류:', error);
    res.status(500).json({ message: '식단 기록 중 오류가 발생했습니다.' });
  }
};

exports.getMeals = async (req, res) => {
  try {
    const userId = req.user.user_id;
    const { date } = req.query;

    if (!date) {
      return res.status(400).json({ message: '날짜를 입력해주세요.' });
    }

    // 해당 날짜의 식사 기록 조회
    const mealLogs = await MealLog.findAll({
      where: { user_id: userId, meal_date: date },
      include: [{
        model: LoggedFood,
        as: 'foods',
        attributes: ['logged_food_id', 'food_name', 'serving_size_grams', 'calories', 'protein', 'fat', 'carbs']
      }],
      order: [['meal_type', 'ASC']]
    });

    // 총 영양소 계산
    let totalNutrition = {
      calories: 0,
      protein: 0,
      fat: 0,
      carbs: 0
    };

    const formattedMeals = mealLogs.map(meal => {
      const foods = meal.foods.map(food => {
        // 총 영양소에 추가
        totalNutrition.calories += parseFloat(food.calories) || 0;
        totalNutrition.protein += parseFloat(food.protein) || 0;
        totalNutrition.fat += parseFloat(food.fat) || 0;
        totalNutrition.carbs += parseFloat(food.carbs) || 0;

        return {
          loggedFoodId: food.logged_food_id,
          foodName: food.food_name,
          servingSizeGrams: food.serving_size_grams,
          calories: food.calories,
          protein: food.protein,
          fat: food.fat,
          carbs: food.carbs
        };
      });

      return {
        mealLogId: meal.meal_log_id,
        mealType: meal.meal_type,
        imageUrl: meal.image_url,
        foods
      };
    });

    res.json({
      date,
      totalNutrition,
      meals: formattedMeals
    });
  } catch (error) {
    console.error('식단 조회 오류:', error);
    res.status(500).json({ message: '식단 조회 중 오류가 발생했습니다.' });
  }
};