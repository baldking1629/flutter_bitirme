import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/irrigation_advice_model.dart';

class GeminiService {
  final GenerativeModel _model;
  final String _apiKey =
      'AIzaSyDFxHuTFTM3oG00PI16i5Cp5dfa8xitJ1Q'; // Gemini API anahtarınızı buraya ekleyin

  GeminiService()
      : _model = GenerativeModel(
          model: 'gemini-2.0-flash',
          apiKey:
              '', // Gemini API anahtarınızı buraya ekleyin
        );

  Future<IrrigationAdvice> getIrrigationAdvice({
    required double humidity,
    required double temperature,
    required double soilMoisture,
    required bool isRaining,
    required String cropType,
    required bool hasSensor,
  }) async {
    try {
      if (!hasSensor) {
        return IrrigationAdvice.noSensor();
      }

      final prompt = '''
Aşağıdaki verilere göre sulama önerileri ver:

- Hava Sıcaklığı: $temperature°C  
- Hava Nemi: $humidity%  
- Toprak Nemi: $soilMoisture%  
- Yağmur Durumu: ${isRaining ? 'Yağmur yağıyor' : 'Yağmur yağmıyor'}  
- Mahsul Türü: $cropType  

Lütfen sadece aşağıdaki başlıklarla cevap ver:

1. sulamaGerekiyorMu: Sulama yapılmalı mı? (Evet/Hayır ve kısa gerekçe)  
2. suMiktari: Ne kadar su verilmeli? (Litre cinsinden)  
3. enUygunZaman: Sulama için en uygun zaman nedir? (Sabah/Öğlen/Akşam gibi)  
4. digerOneriler: Başka önerilerin var mı? (Kısa ve öz)  

Cevapları sadece şu formatta ver:
sulamaGerekiyorMu: ...  
suMiktari: ...  
enUygunZaman: ...  
digerOneriler: ...
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      final text = response.text ?? 'Öneri alınamadı.';

      // Yanıtı parse et
      final Map<String, String> result = {};
      final lines = text.split('\n');

      for (var line in lines) {
        if (line.contains('sulamaGerekiyorMu:')) {
          result['sulamaGerekiyorMu'] =
              line.split('sulamaGerekiyorMu:')[1].trim();
        } else if (line.contains('suMiktari:')) {
          result['suMiktari'] = line.split('suMiktari:')[1].trim();
        } else if (line.contains('enUygunZaman:')) {
          result['enUygunZaman'] = line.split('enUygunZaman:')[1].trim();
        } else if (line.contains('digerOneriler:')) {
          result['digerOneriler'] = line.split('digerOneriler:')[1].trim();
        }
      }

      return IrrigationAdvice.fromMap(result, hasSensor: hasSensor);
    } catch (e) {
      return IrrigationAdvice(
          sulamaGerekiyorMu: 'Hata oluştu',
          suMiktari: 'Hata oluştu',
          enUygunZaman: 'Hata oluştu',
          digerOneriler: 'Hata oluştu: $e',
          hasSensor: hasSensor);
    }
  }
}
