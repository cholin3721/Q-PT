require('dotenv').config();
const { NutritionData, sequelize } = require('./src/models');

async function checkNutritionData() {
  try {
    console.log('=== NutritionData 테이블 확인 ===\n');

    // 전체 개수
    const totalCount = await NutritionData.count();
    console.log(`📊 총 데이터 개수: ${totalCount.toLocaleString()}개\n`);

    // 샘플 데이터 (첫 20개)
    console.log('=== 샘플 데이터 (첫 20개) ===\n');
    const samples = await NutritionData.findAll({ 
      limit: 20,
      order: [['nutrition_data_id', 'ASC']]
    });

    samples.forEach((item, index) => {
      console.log(`${index + 1}. ${item.food_name}`);
      console.log(`   칼로리: ${item.calories || 0}kcal, 단백질: ${item.protein || 0}g, 지방: ${item.fat || 0}g, 탄수화물: ${item.carbs || 0}g`);
    });

    // "김치" 관련 검색
    console.log('\n=== "김치" 관련 검색 ===\n');
    const kimchiResults = await NutritionData.findAll({
      where: {
        food_name: {
          [require('sequelize').Op.like]: '%김치%'
        }
      },
      limit: 10
    });

    if (kimchiResults.length > 0) {
      kimchiResults.forEach((item, index) => {
        console.log(`${index + 1}. ${item.food_name}`);
      });
    } else {
      console.log('❌ "김치" 관련 데이터가 없습니다.');
    }

    // "찌개" 관련 검색
    console.log('\n=== "찌개" 관련 검색 ===\n');
    const jjigaeResults = await NutritionData.findAll({
      where: {
        food_name: {
          [require('sequelize').Op.like]: '%찌개%'
        }
      },
      limit: 10
    });

    if (jjigaeResults.length > 0) {
      jjigaeResults.forEach((item, index) => {
        console.log(`${index + 1}. ${item.food_name}`);
      });
    } else {
      console.log('❌ "찌개" 관련 데이터가 없습니다.');
    }

    await sequelize.close();
    console.log('\n✅ 확인 완료!');

  } catch (error) {
    console.error('❌ 오류:', error.message);
    if (sequelize) {
      await sequelize.close();
    }
  }
}

checkNutritionData();




