import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/weather_model.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  // API anahtarını al
  String? get _apiKey => dotenv.env['OPENWEATHER_API_KEY'];

  // Mevcut hava durumu
  Future<WeatherModel?> getWeatherByLocation(double lat, double lon) async {
    try {
      if (_apiKey == null) {
        throw Exception('API anahtarı bulunamadı');
      }

      final url =
          '$_baseUrl/weather?lat=$lat&lon=$lon&units=metric&lang=tr&appid=$_apiKey';
      print('API URL: $url');

      final response = await http.get(Uri.parse(url));
      print('API Yanıt Kodu: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return WeatherModel.fromJson(jsonData);
      } else {
        print('API Hatası: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Hava durumu verisi alınırken hata oluştu: $e');
      return null;
    }
  }

  // 5 günlük hava durumu tahmini
  Future<Map<String, dynamic>?> getForecastByLocation(
      double lat, double lon) async {
    try {
      if (_apiKey == null) {
        throw Exception('API anahtarı bulunamadı');
      }

      final url =
          '$_baseUrl/forecast?lat=$lat&lon=$lon&units=metric&lang=tr&appid=$_apiKey';
      print('Tahmin API URL: $url');

      final response = await http.get(Uri.parse(url));
      print('Tahmin API Yanıt Kodu: ${response.statusCode}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Tahmin API Hatası: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Hava durumu tahmini alınırken hata oluştu: $e');
      return null;
    }
  }

  // Hava durumu haritası katmanları
  Future<String?> getWeatherMapLayer(String layer, int z, int x, int y) async {
    try {
      if (_apiKey == null) {
        throw Exception('API anahtarı bulunamadı');
      }

      final url =
          'https://tile.openweathermap.org/map/$layer/$z/$x/$y.png?appid=$_apiKey';
      print('Harita API URL: $url');

      final response = await http.get(Uri.parse(url));
      print('Harita API Yanıt Kodu: ${response.statusCode}');

      if (response.statusCode == 200) {
        return url;
      } else {
        print('Harita API Hatası: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Hava durumu haritası alınırken hata oluştu: $e');
      return null;
    }
  }
}
