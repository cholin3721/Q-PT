const { InBody } = require('../../models');
const axios = require('axios');
const FormData = require('form-data');

/**
 * 네이버 클로바 OCR API를 사용하여 인바디 이미지에서 텍스트 추출
 */
const callClovaOCR = async (imageBuffer) => {
  try {
    const CLOVA_OCR_URL = process.env.NAVER_CLOVA_OCR_URL;
    const CLOVA_OCR_SECRET = process.env.NAVER_CLOVA_OCR_SECRET;

    if (!CLOVA_OCR_URL || !CLOVA_OCR_SECRET) {
      throw new Error('네이버 클로바 OCR API 설정이 없습니다. .env 파일을 확인하세요.');
    }

    const formData = new FormData();
    
    // OCR 요청 메타데이터 (먼저 추가)
    const message = {
      version: 'V2',
      requestId: 'inbody-' + Date.now(),
      timestamp: Date.now(),
      images: [{
        format: 'jpg',
        name: 'inbody'
      }]
    };
    formData.append('message', JSON.stringify(message));
    
    // 이미지 파일 추가 (필드명: 'file')
    formData.append('file', imageBuffer, {
      filename: 'inbody.jpg',
      contentType: 'image/jpeg'
    });

    const response = await axios.post(CLOVA_OCR_URL, formData, {
      headers: {
        'X-OCR-SECRET': CLOVA_OCR_SECRET,
        ...formData.getHeaders()
      }
    });

    return response.data;
  } catch (error) {
    console.error('네이버 클로바 OCR API 호출 오류:', error.response?.data || error.message);
    throw error;
  }
};

/**
 * OCR 결과에서 인바디 데이터 파싱 (개선 버전)
 */
const parseInbodyData = (ocrResult) => {
  try {
    const extractedText = [];
    
    // OCR 결과에서 모든 텍스트 추출
    if (ocrResult.images && ocrResult.images[0] && ocrResult.images[0].fields) {
      ocrResult.images[0].fields.forEach(field => {
        extractedText.push({
          text: field.inferText,
          confidence: field.inferConfidence
        });
      });
    }

    const parsedData = {
      testDate: new Date().toISOString().split('T')[0],
      height: null,
      weight: null,
      muscleMass: null,
      fatMass: null,
      bmi: null,
      bodyFatPercentage: null,
      basalMetabolicRate: null,
      bodyWater: null,
      protein: null,
      leanBodyMass: null,
      visceralFatLevel: null,
      waistHipRatio: null,
      segmentalAnalysis: {}
    };

    // 1. 중요 섹션 찾기
    const compositionIndex = extractedText.findIndex(t => t.text.includes('체성분분석'));
    const historyIndex = extractedText.findIndex(t => t.text.includes('신체변화'));
    
    const relevantStart = compositionIndex >= 0 ? compositionIndex : 0;
    const relevantEnd = historyIndex >= 0 ? historyIndex : extractedText.length;
    
    console.log(`📍 주요 파싱 범위: ${relevantStart} ~ ${relevantEnd} (총 ${relevantEnd - relevantStart}개 필드)`);

    // 2. 헬퍼 함수: 다음 숫자 찾기 (범위 괄호 제외)
    const findNextNumber = (startIndex, maxLookAhead = 5) => {
      for (let i = startIndex + 1; i < Math.min(startIndex + maxLookAhead, relevantEnd); i++) {
        const text = extractedText[i].text.trim();
        
        // 괄호로 시작하는 범위 값은 제외
        if (text.startsWith('(')) continue;
        
        // 숫자 추출
        const match = text.match(/^(\d+\.?\d*)/);
        if (match) {
          return parseFloat(match[1]);
        }
      }
      return null;
    };

    // 3. 신장 먼저 추출 (전체 범위에서)
    for (let i = 0; i < extractedText.length; i++) {
      const text = extractedText[i].text.trim();
      
      // 신장이 cm과 함께 나오는 경우 (예: 156.9cm)
      if (text.match(/^(\d+\.?\d*)cm$/) && !parsedData.height) {
        const match = text.match(/^(\d+\.?\d*)cm$/);
        if (match) {
          const value = parseFloat(match[1]);
          if (value > 100 && value < 250) {
            parsedData.height = value;
            console.log(`✅ 신장: ${value}cm`);
            break;
          }
        }
      }
    }

    // 4. 데이터 추출 (관련 섹션만)
    for (let i = relevantStart; i < relevantEnd; i++) {
      const text = extractedText[i].text.trim();

      // 체중 (체성분분석 섹션에서만, 히스토리 제외)
      if (text === '체중' && extractedText[i + 1]?.text === '(kg)' && !parsedData.weight) {
        const nextValue = findNextNumber(i + 1, 3);
        if (nextValue && nextValue > 20 && nextValue < 300) {
          parsedData.weight = nextValue;
          console.log(`✅ 체중: ${nextValue}kg`);
        }
      }

      // 골격근량 (Skeletal Muscle Mass) - 정확한 위치에서
      if (text === '골격근량' && !parsedData.muscleMass) {
        // "골격근량" 이후 "(kg)" 찾고 그 다음 숫자 추출
        for (let j = i + 1; j < Math.min(i + 10, relevantEnd); j++) {
          if (extractedText[j].text.trim() === '(kg)') {
            const nextValue = findNextNumber(j, 3);
            if (nextValue && nextValue > 5 && nextValue < 50) {
              parsedData.muscleMass = nextValue;
              console.log(`✅ 골격근량: ${nextValue}kg`);
              break;
            }
          }
        }
      }

      // 체지방량 (체성분분석 섹션)
      if (text === '체지방량' && extractedText[i + 1]?.text === '(kg)' && !parsedData.fatMass) {
        const nextValue = findNextNumber(i + 1, 3);
        if (nextValue && nextValue > 0 && nextValue < 200) {
          parsedData.fatMass = nextValue;
          console.log(`✅ 체지방량: ${nextValue}kg`);
        }
      }

      // BMI
      if ((text === 'BMI' || text === '(kg/m2)') && !parsedData.bmi) {
        const nextValue = findNextNumber(i, 5);
        if (nextValue && nextValue > 10 && nextValue < 60) {
          parsedData.bmi = nextValue;
          console.log(`✅ BMI: ${nextValue}`);
        }
      }

      // 체지방률 (연구항목 섹션에서)
      if (text === '연구항목' || text === 'Body Fa') {
        const nextValue = findNextNumber(i, 5);
        if (nextValue && nextValue > 0 && nextValue < 100 && !parsedData.bodyFatPercentage) {
          parsedData.bodyFatPercentage = nextValue;
          console.log(`✅ 체지방률: ${nextValue}%`);
        }
      }

      // 기초대사량
      if (text === '기초대사량' && !parsedData.basalMetabolicRate) {
        const nextValue = findNextNumber(i, 3);
        if (nextValue && nextValue > 500 && nextValue < 5000) {
          parsedData.basalMetabolicRate = Math.round(nextValue);
          console.log(`✅ 기초대사량: ${nextValue}kcal`);
        }
      }

      // 체수분
      if (text === '체수분' && extractedText[i + 1]?.text === '(L)') {
        const nextValue = findNextNumber(i + 1, 3);
        if (nextValue && nextValue > 10 && nextValue < 100) {
          parsedData.bodyWater = nextValue;
          console.log(`✅ 체수분: ${nextValue}L`);
        }
      }

      // 단백질
      if (text === '단백질' && extractedText[i + 1]?.text === '(kg)') {
        const nextValue = findNextNumber(i + 1, 3);
        if (nextValue && nextValue > 3 && nextValue < 30) {
          parsedData.protein = nextValue;
          console.log(`✅ 단백질: ${nextValue}kg`);
        }
      }

      // 제지방량 (kg 패턴)
      if (text === '제지방량') {
        const nextText = extractedText[i + 1]?.text;
        const match = nextText?.match(/(\d+\.?\d*)kg/);
        if (match) {
          parsedData.leanBodyMass = parseFloat(match[1]);
          console.log(`✅ 제지방량: ${parsedData.leanBodyMass}kg`);
        }
      }

      // 내장지방레벨 - 정확한 값 찾기 (10은 기준선, 실제값은 더 뒤에)
      if (text === '내장지방레벨' && !parsedData.visceralFatLevel) {
        for (let j = i + 1; j < Math.min(i + 25, relevantEnd); j++) {
          const checkText = extractedText[j].text.trim();
          // "10"은 기준선이므로 건너뛰고, 그 다음 숫자를 찾음
          if (checkText === '10' || checkText === '높음' || checkText === '낮음' || checkText === '표준') continue;
          
          const match = checkText.match(/^(\d+)$/);
          if (match) {
            const value = parseInt(match[1]);
            if (value > 10 && value < 30) {
              parsedData.visceralFatLevel = value;
              console.log(`✅ 내장지방레벨: ${value}`);
              break;
            }
          }
        }
      }

      // 복부지방률 - "높음" 키워드 다음의 0.9x 값 찾기
      if (text === '복부지방률' && !parsedData.waistHipRatio) {
        let foundHigh = false;
        for (let j = i + 1; j < Math.min(i + 10, relevantEnd); j++) {
          const val = extractedText[j].text.trim();
          
          // "높음" 키워드를 찾았다면 플래그 설정
          if (val === '높음') {
            foundHigh = true;
            continue;
          }
          
          // "높음" 이후에 나오는 0.9x 형태의 값 찾기
          if (foundHigh && val.match(/^0\.\d+$/)) {
            const value = parseFloat(val);
            if (value > 0.9) {  // 0.9 이상인 값만 (실제 측정값)
              parsedData.waistHipRatio = value;
              console.log(`✅ 복부지방률: ${value}`);
              break;
            }
          }
        }
      }
    }

    console.log('파싱된 인바디 데이터:', parsedData);
    return parsedData;

  } catch (error) {
    console.error('인바디 데이터 파싱 오류:', error);
    throw new Error('인바디 데이터를 파싱하는 중 오류가 발생했습니다.');
  }
};

/**
 * 인바디 이미지 OCR 처리
 */
exports.ocr = async (req, res) => {
  try {
    // 업로드된 이미지 확인
    if (!req.file) {
      return res.status(400).json({ message: '이미지 파일을 업로드해주세요.' });
    }

    console.log('업로드된 파일:', req.file.originalname, req.file.size, 'bytes');

    // 네이버 클로바 OCR API 호출
    const ocrResult = await callClovaOCR(req.file.buffer);

    // OCR 결과에서 인바디 데이터 파싱
    const inbodyData = parseInbodyData(ocrResult);

    res.json(inbodyData);

  } catch (error) {
    console.error('OCR 처리 오류:', error);
    
    if (error.message.includes('API 설정')) {
      return res.status(500).json({ 
        message: error.message,
        hint: 'NAVER_CLOVA_OCR_URL과 NAVER_CLOVA_OCR_SECRET을 .env 파일에 설정하세요.'
      });
    }

    res.status(500).json({ message: 'OCR 처리 중 오류가 발생했습니다.' });
  }
};

exports.register = async (req, res) => {
  try {
    const userId = req.user.user_id;
    const {
      testDate,
      height,
      weight,
      muscleMass,
      fatMass,
      bmi,
      bodyFatPercentage,
      basalMetabolicRate,
      bodyWater,
      protein,
      leanBodyMass,
      visceralFatLevel,
      waistHipRatio,
      segmentalAnalysis
    } = req.body;

    const inbody = await InBody.create({
      user_id: userId,
      test_date: testDate,
      height,
      weight,
      muscle_mass: muscleMass,
      fat_mass: fatMass,
      bmi,
      body_fat_percentage: bodyFatPercentage,
      basal_metabolic_rate: basalMetabolicRate,
      body_water: bodyWater,
      protein,
      lean_body_mass: leanBodyMass,
      visceral_fat_level: visceralFatLevel,
      waist_hip_ratio: waistHipRatio,
      segmental_analysis: segmentalAnalysis
    });

    res.status(201).json({
      inbodyId: inbody.inbody_id,
      userId: inbody.user_id,
      testDate: inbody.test_date,
      height: inbody.height,
      weight: inbody.weight,
      muscleMass: inbody.muscle_mass,
      fatMass: inbody.fat_mass,
      bmi: inbody.bmi,
      bodyFatPercentage: inbody.body_fat_percentage,
      basalMetabolicRate: inbody.basal_metabolic_rate,
      bodyWater: inbody.body_water,
      protein: inbody.protein,
      leanBodyMass: inbody.lean_body_mass,
      visceralFatLevel: inbody.visceral_fat_level,
      waistHipRatio: inbody.waist_hip_ratio,
      segmentalAnalysis: inbody.segmental_analysis
    });
  } catch (error) {
    console.error('인바디 등록 오류:', error);
    res.status(500).json({ message: '인바디 등록 중 오류가 발생했습니다.' });
  }
};

exports.list = async (req, res) => {
  try {
    const userId = req.user.user_id;
    
    const inbodies = await InBody.findAll({
      where: { user_id: userId },
      order: [['test_date', 'DESC']],
      attributes: [
        'inbody_id',
        'test_date',
        'height',
        'weight',
        'muscle_mass',
        'fat_mass',
        'bmi',
        'body_fat_percentage',
        'basal_metabolic_rate',
        'body_water',
        'protein',
        'lean_body_mass',
        'visceral_fat_level',
        'waist_hip_ratio',
        'segmental_analysis'
      ]
    });

    const formattedInbodies = inbodies.map(inbody => ({
      inbodyId: inbody.inbody_id,
      testDate: inbody.test_date,
      height: inbody.height,
      weight: inbody.weight,
      muscleMass: inbody.muscle_mass,
      fatMass: inbody.fat_mass,
      bmi: inbody.bmi,
      bodyFatPercentage: inbody.body_fat_percentage,
      basalMetabolicRate: inbody.basal_metabolic_rate,
      bodyWater: inbody.body_water,
      protein: inbody.protein,
      leanBodyMass: inbody.lean_body_mass,
      visceralFatLevel: inbody.visceral_fat_level,
      waistHipRatio: inbody.waist_hip_ratio,
      segmentalAnalysis: inbody.segmental_analysis
    }));

    res.json(formattedInbodies);
  } catch (error) {
    console.error('인바디 이력 조회 오류:', error);
    res.status(500).json({ message: '인바디 이력 조회 중 오류가 발생했습니다.' });
  }
};