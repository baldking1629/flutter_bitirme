class WeatherModel {
  final double temperature;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final int pressure;
  final String description;
  final String iconCode;
  final double windSpeed;
  final int windDegree;
  final int clouds;
  final String cityName;
  final DateTime sunrise;
  final DateTime sunset;
  final bool isRaining;

  WeatherModel({
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.pressure,
    required this.description,
    required this.iconCode,
    required this.windSpeed,
    required this.windDegree,
    required this.clouds,
    required this.cityName,
    required this.sunrise,
    required this.sunset,
    required this.isRaining,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    // Yağmur durumunu kontrol et
    bool isRaining = false;
    String weatherMain = json['weather'][0]['main'].toString().toLowerCase();
    String weatherDesc =
        json['weather'][0]['description'].toString().toLowerCase();

    if (weatherMain.contains('rain') ||
        weatherDesc.contains('yağmur') ||
        weatherDesc.contains('rain') ||
        weatherMain.contains('drizzle') ||
        weatherDesc.contains('çisenti')) {
      isRaining = true;
    }

    return WeatherModel(
      temperature: json['main']['temp'].toDouble(),
      feelsLike: json['main']['feels_like'].toDouble(),
      tempMin: json['main']['temp_min'].toDouble(),
      tempMax: json['main']['temp_max'].toDouble(),
      humidity: json['main']['humidity'],
      pressure: json['main']['pressure'],
      description: json['weather'][0]['description'],
      iconCode: json['weather'][0]['icon'],
      windSpeed: json['wind']['speed'].toDouble(),
      windDegree: json['wind']['deg'],
      clouds: json['clouds']['all'],
      cityName: json['name'],
      sunrise:
          DateTime.fromMillisecondsSinceEpoch(json['sys']['sunrise'] * 1000),
      sunset: DateTime.fromMillisecondsSinceEpoch(json['sys']['sunset'] * 1000),
      isRaining: isRaining,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'main': {
        'temp': temperature,
        'feels_like': feelsLike,
        'temp_min': tempMin,
        'temp_max': tempMax,
        'humidity': humidity,
        'pressure': pressure,
      },
      'weather': [
        {
          'description': description,
          'icon': iconCode,
        }
      ],
      'wind': {
        'speed': windSpeed,
        'deg': windDegree,
      },
      'clouds': {
        'all': clouds,
      },
      'name': cityName,
      'sys': {
        'sunrise': sunrise.millisecondsSinceEpoch ~/ 1000,
        'sunset': sunset.millisecondsSinceEpoch ~/ 1000,
      },
    };
  }
}
