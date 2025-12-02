require('dotenv').config();
const fs = require('fs');
const path = require('path');
const iconv = require('iconv-lite');
const { sequelize } = require('./src/models');
const { NutritionData } = require('./src/models').sequelize.models;

/**
 * CSV → DB 임포트 스크립트
 * 전국통합식품영양성분정보_음식_표준데이터.csv → NutritionData 테이블
 */

async function importNutritionData() {
  console.log('=== 영양 데이터 임포트 시작 ===\n');

  try {
    // 1. CSV 파일 읽기
    const csvPath = path.join(__dirname, '..', '전국통합식품영양성분정보_음식_표준데이터.csv');
    
    if (!fs.existsSync(csvPath)) {
      console.error('❌ CSV 파일을 찾을 수 없습니다:', csvPath);
      return;
    }

    console.log('📂 CSV 파일 로드 중...');
    const buffer = fs.readFileSync(csvPath);
    const content = iconv.decode(buffer, 'euc-kr');
    const lines = content.split('\n').filter(line => line.trim());
    
    console.log(`✅ 총 ${lines.length.toLocaleString()}개 라인 로드 완료\n`);

    // 2. 헤더 파싱
    const headers = lines[0].split(',').map(h => h.trim());
    console.log('📋 컬럼 수:', headers.length);
    
    // 컬럼 인덱스 찾기
    const columnIndex = {
      foodName: headers.indexOf('식품명'),
      servingSize: headers.indexOf('영양성분함량기준량'),
      calories: headers.indexOf('에너지(kcal)'),
      protein: headers.indexOf('단백질(g)'),
      fat: headers.indexOf('지방(g)'),
      carbs: headers.indexOf('탄수화물(g)'),
      sugars: headers.indexOf('당류(g)'),
      sodium: headers.indexOf('나트륨(mg)'),
      cholesterol: headers.indexOf('콜레스테롤(mg)'),
      transFat: headers.indexOf('트랜스지방산(g)')
    };

    console.log('✅ 컬럼 매핑 완료\n');

    // 3. 데이터 파싱
    console.log('🔄 데이터 파싱 중...');
    const nutritionData = [];
    let successCount = 0;
    let skipCount = 0;
    const duplicates = new Set();

    for (let i = 1; i < lines.length; i++) {
      try {
        const row = lines[i].split(',');
        
        const foodName = row[columnIndex.foodName]?.trim();
        if (!foodName) {
          skipCount++;
          continue;
        }

        // 중복 체크 (메모리 기반)
        if (duplicates.has(foodName)) {
          console.log(`⚠️  중복 건너뜀: ${foodName}`);
          skipCount++;
          continue;
        }
        duplicates.add(foodName);

        // 제공량: 숫자만 추출 (단위 무시)
        const servingSizeRaw = row[columnIndex.servingSize]?.trim() || '100';
        const servingSizeMatch = servingSizeRaw.match(/(\d+\.?\d*)/);
        const servingSize = servingSizeMatch ? parseFloat(servingSizeMatch[1]) : 100.00;

        // 영양소 파싱 (빈 값은 null)
        const parseNutrient = (value) => {
          const trimmed = value?.trim();
          return trimmed && trimmed !== '' ? parseFloat(trimmed) : null;
        };

        const data = {
          food_name: foodName,
          serving_size_grams: servingSize,
          calories: parseNutrient(row[columnIndex.calories]),
          protein: parseNutrient(row[columnIndex.protein]),
          fat: parseNutrient(row[columnIndex.fat]),
          carbs: parseNutrient(row[columnIndex.carbs]),
          sugars: parseNutrient(row[columnIndex.sugars]),
          sodium: parseNutrient(row[columnIndex.sodium]),
          cholesterol: parseNutrient(row[columnIndex.cholesterol]),
          trans_fat: parseNutrient(row[columnIndex.transFat])
        };

        nutritionData.push(data);
        successCount++;

        // 진행 상황 표시 (1000개마다)
        if (successCount % 1000 === 0) {
          console.log(`   처리 중... ${successCount.toLocaleString()}개`);
        }

      } catch (error) {
        console.error(`⚠️  라인 ${i} 파싱 오류:`, error.message);
        skipCount++;
      }
    }

    console.log(`✅ 데이터 파싱 완료: ${successCount.toLocaleString()}개`);
    console.log(`⚠️  건너뛴 항목: ${skipCount}개\n`);

    // 4. DB 연결 확인
    console.log('🔌 DB 연결 확인 중...');
    await sequelize.authenticate();
    console.log('✅ DB 연결 성공\n');

    // 5. 기존 데이터 확인
    const existingCount = await NutritionData.count();
    console.log(`📊 현재 DB에 저장된 데이터: ${existingCount.toLocaleString()}개`);
    
    if (existingCount > 0) {
      console.log('\n⚠️  기존 데이터가 존재합니다!');
      console.log('   옵션:');
      console.log('   1. 기존 데이터 삭제 후 임포트 → truncate() 호출');
      console.log('   2. 중복 건너뛰고 추가만 → 현재 로직 사용');
      console.log('\n   계속 진행하려면 Ctrl+C로 중단 후 선택하세요...\n');
      
      // 5초 대기
      await new Promise(resolve => setTimeout(resolve, 5000));
    }

    // 6. Bulk Insert (배치 처리)
    console.log('💾 DB에 저장 중...');
    const batchSize = 500; // 500개씩 배치 처리
    let insertedCount = 0;

    for (let i = 0; i < nutritionData.length; i += batchSize) {
      const batch = nutritionData.slice(i, i + batchSize);
      
      try {
        await NutritionData.bulkCreate(batch, {
          ignoreDuplicates: true, // 중복은 건너뛰기
          validate: true
        });
        
        insertedCount += batch.length;
        console.log(`   저장 중... ${insertedCount.toLocaleString()}/${nutritionData.length.toLocaleString()}`);
        
      } catch (error) {
        console.error(`⚠️  배치 ${i}-${i + batchSize} 저장 오류:`, error.message);
      }
    }

    console.log(`\n✅ DB 저장 완료: ${insertedCount.toLocaleString()}개 저장됨\n`);

    // 7. 결과 확인
    const finalCount = await NutritionData.count();
    console.log('=== 임포트 완료 ===');
    console.log(`📊 총 DB 데이터: ${finalCount.toLocaleString()}개`);
    console.log(`✅ 새로 추가됨: ${finalCount - existingCount}개`);

    // 8. 샘플 데이터 출력
    console.log('\n=== 샘플 데이터 (첫 3개) ===');
    const samples = await NutritionData.findAll({ limit: 3 });
    samples.forEach((item, index) => {
      console.log(`\n${index + 1}. ${item.food_name}`);
      console.log(`   - 제공량: ${item.serving_size_grams}g`);
      console.log(`   - 칼로리: ${item.calories} kcal`);
      console.log(`   - 단백질: ${item.protein}g`);
      console.log(`   - 지방: ${item.fat}g`);
      console.log(`   - 탄수화물: ${item.carbs}g`);
    });

    console.log('\n🎉 모든 작업이 완료되었습니다!');

  } catch (error) {
    console.error('\n❌ 오류 발생:', error.message);
    console.error(error.stack);
  } finally {
    await sequelize.close();
    console.log('\n👋 DB 연결 종료');
  }
}

// 스크립트 실행
importNutritionData();



