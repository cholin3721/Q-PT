require('dotenv').config();
const { ImageAnnotatorClient } = require('@google-cloud/vision');
const { NutritionData, sequelize } = require('./src/models');
const { Op } = require('sequelize');
const fs = require('fs');
const path = require('path');

/**
 * Google Vision API 음식 인식 테스트 스크립트 (직접 호출)
 */

async function testVisionAPI(imageFileName) {
  try {
    console.log('=== Google Vision API 음식 인식 테스트 ===\n');

    // 1. 테스트 이미지 확인
    const imagePath = imageFileName 
      ? path.join(__dirname, '..', imageFileName)
      : path.join(__dirname, '../kimchi.jpg');
    
    if (!fs.existsSync(imagePath)) {
      console.error('❌ 테스트 이미지 파일이 없습니다:', imagePath);
      return;
    }

    console.log('✅ 테스트 이미지:', imagePath);
    const imageBuffer = fs.readFileSync(imagePath);
    console.log('📏 파일 크기:', (imageBuffer.length / 1024).toFixed(2), 'KB\n');

    // 2. Google Vision API 클라이언트 초기화
    console.log('🔧 Vision API 클라이언트 초기화 중...');
    const visionClient = new ImageAnnotatorClient({
      keyFilename: path.join(__dirname, '../q-pt-479300-26c3c7255839.json')
    });
    console.log('✅ 클라이언트 초기화 완료\n');

    // 3. Vision API로 이미지 분석
    console.log('📤 Vision API로 이미지 분석 중...');
    const [result] = await visionClient.labelDetection({
      image: { content: imageBuffer }
    });

    const labels = result.labelAnnotations || [];
    console.log(`✅ ${labels.length}개의 라벨 인식됨\n`);

    // 신뢰도가 높은 라벨들 추출 (0.5 이상)
    const foodLabels = labels
      .filter(label => label.score >= 0.5)
      .map(label => ({
        description: label.description,
        score: label.score
      }))
      .slice(0, 10); // 상위 10개만 사용

    console.log('=== 인식된 라벨 (신뢰도 0.5 이상) ===');
    foodLabels.forEach((label, index) => {
      console.log(`${index + 1}. ${label.description} (신뢰도: ${(label.score * 100).toFixed(1)}%)`);
    });
    console.log('');

    // 4. 영어→한국어 음식명 매핑
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
      
      // 직접 매핑 확인
      for (const [eng, kor] of Object.entries(foodNameMapping)) {
        if (lowerLabel.includes(eng)) {
          return kor;
        }
      }
      
      return null;
    };

    // 모든 라벨에서 한국어 키워드 추출
    const koreanKeywords = [];
    for (const label of foodLabels) {
      const koreanKeyword = convertToKoreanKeyword(label.description);
      if (koreanKeyword) {
        koreanKeywords.push(koreanKeyword);
      }
    }

    // DB에서 음식 정보 매칭
    console.log('🔍 DB에서 음식 정보 매칭 중...');
    const matchedFoods = [];
    const matchedFoodNames = new Set(); // 중복 방지

    // 1단계: 여러 키워드를 모두 포함하는 음식 우선 검색 (예: "두부" + "찌개")
    if (koreanKeywords.length >= 2) {
      console.log(`   여러 키워드 조합 검색: ${koreanKeywords.join(' + ')}`);
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
          matchedFoods.push({
            foodName: nutritionData.food_name,
            calories: parseFloat(nutritionData.calories) || 0,
            protein: parseFloat(nutritionData.protein) || 0,
            fat: parseFloat(nutritionData.fat) || 0,
            carbs: parseFloat(nutritionData.carbs) || 0,
            servingSizeGrams: parseFloat(nutritionData.serving_size_grams) || 100,
            confidence: 1.0,
            matchType: 'multi-keyword'
          });
        }
      }
    }

    // 2단계: 각 라벨별로 개별 검색
    for (const label of foodLabels) {
      const labelText = label.description;
      let searchKeywords = [labelText]; // 원본 라벨
      
      // 한국어 키워드 변환 시도
      const koreanKeyword = convertToKoreanKeyword(labelText);
      if (koreanKeyword) {
        console.log(`   "${labelText}" → "${koreanKeyword}" 변환`);
        searchKeywords.push(koreanKeyword);
      }

      let nutritionData = null;

      // 각 키워드로 검색 시도
      for (const keyword of searchKeywords) {
        // 정확한 매칭 시도
        nutritionData = await NutritionData.findOne({
          where: {
            food_name: keyword
          }
        });

        if (nutritionData) break;

        // 부분 매칭 시도 (키워드가 음식명에 포함)
        nutritionData = await NutritionData.findOne({
          where: {
            food_name: {
              [Op.like]: `%${keyword}%`
            }
          }
        });

        if (nutritionData) break;

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

        if (nutritionData) break;
      }

      if (nutritionData && !matchedFoodNames.has(nutritionData.food_name)) {
        matchedFoodNames.add(nutritionData.food_name);
        matchedFoods.push({
          foodName: nutritionData.food_name,
          calories: parseFloat(nutritionData.calories) || 0,
          protein: parseFloat(nutritionData.protein) || 0,
          fat: parseFloat(nutritionData.fat) || 0,
          carbs: parseFloat(nutritionData.carbs) || 0,
          servingSizeGrams: parseFloat(nutritionData.serving_size_grams) || 100
        });
      }
    }

    // 5. 결과 출력
    console.log('=== 매칭 결과 ===\n');
    if (matchedFoods.length > 0) {
      console.log('✅ 인식된 음식 목록:');
      matchedFoods.forEach((food, index) => {
        console.log(`\n${index + 1}. ${food.foodName}`);
        console.log(`   칼로리: ${food.calories}kcal (${food.servingSizeGrams}g 기준)`);
        console.log(`   단백질: ${food.protein}g`);
        console.log(`   지방: ${food.fat}g`);
        console.log(`   탄수화물: ${food.carbs}g`);
      });
      
      const totalCalories = matchedFoods.reduce((sum, food) => sum + food.calories, 0);
      console.log(`\n📊 총 칼로리: ${totalCalories}kcal`);
    } else {
      console.log('⚠️ DB에서 매칭된 음식이 없습니다.');
      console.log('\n인식된 라벨들:');
      foodLabels.forEach(label => console.log(`  - ${label.description}`));
    }

    // 연결 종료
    await sequelize.close();
    console.log('\n✅ 테스트 완료!');

  } catch (error) {
    console.error('\n❌ 오류 발생:', error.message);
    console.error(error.stack);
    if (sequelize) {
      await sequelize.close();
    }
  }
}

// 스크립트 실행 (이미지 파일명을 인자로 받음)
const imageFile = process.argv[2] || 'kimchi.jpg';
testVisionAPI(imageFile);

