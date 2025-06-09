class IrrigationModel {
  final double humidity; // Nem değeri (0-100 arası)
  final double temperature; // Sıcaklık değeri (Celsius)
  final bool isRaining; // Yağmur yağıyor mu?
  final String plantType; // Bitki türü
  final String season; // Mevsim
  final double soilMoisture; // Toprak nemi (0-100 arası)

  IrrigationModel({
    required this.humidity,
    required this.temperature,
    required this.isRaining,
    required this.plantType,
    required this.season,
    required this.soilMoisture,
  });

  // Bitki kategorilerine göre nem ihtiyacı
  Map<String, Map<String, double>> _plantMoistureNeeds = {
    "sukulent": {"min": 20, "max": 40, "soil_min": 10, "soil_max": 30},
    "tropikal": {"min": 60, "max": 80, "soil_min": 50, "soil_max": 70},
    "çöl": {"min": 20, "max": 40, "soil_min": 10, "soil_max": 30},
    "akdeniz": {"min": 40, "max": 60, "soil_min": 30, "soil_max": 50},
    "genel": {"min": 40, "max": 60, "soil_min": 30, "soil_max": 50}
  };

  // Mevsimsel etki faktörü
  double _getSeasonalFactor() {
    switch (season.toLowerCase()) {
      case "yaz":
        return 1.2; // Yazın daha fazla su
      case "kış":
        return 0.7; // Kışın daha az su
      case "sonbahar":
        return 0.9;
      case "ilkbahar":
        return 1.1;
      default:
        return 1.0;
    }
  }

  // Bitki kategorisini belirle
  String _getPlantCategory() {
    final plantTypeLower = plantType.toLowerCase();

    if (plantTypeLower.contains("kaktüs") ||
        plantTypeLower.contains("sukulent") ||
        plantTypeLower.contains("aloe")) {
      return "sukulent";
    } else if (plantTypeLower.contains("orkide") ||
        plantTypeLower.contains("monstera") ||
        plantTypeLower.contains("ficus")) {
      return "tropikal";
    } else if (plantTypeLower.contains("lavanta") ||
        plantTypeLower.contains("zeytin") ||
        plantTypeLower.contains("defne")) {
      return "akdeniz";
    } else if (plantTypeLower.contains("kaktüs") ||
        plantTypeLower.contains("agave")) {
      return "çöl";
    }
    return "genel";
  }

  String getIrrigationAdvice() {
    if (isRaining) {
      return "Yağmur yağıyor, sulama yapmanıza gerek yok.";
    }

    final plantCategory = _getPlantCategory();
    final moistureNeeds = _plantMoistureNeeds[plantCategory]!;
    final seasonalFactor = _getSeasonalFactor();

    // Toprak nemi kontrolü
    if (soilMoisture > moistureNeeds["soil_max"]! * seasonalFactor) {
      return "Toprak nemi yeterli seviyede, sulama yapmanıza gerek yok.";
    }

    // Hava nemi kontrolü
    if (humidity > moistureNeeds["max"]! * seasonalFactor) {
      return "Hava nemi yeterli seviyede, sulama yapmanıza gerek yok.";
    }

    // Sıcaklık kontrolü
    if (temperature > 35) {
      return "Sıcaklık çok yüksek, sulama yapmanız önerilir.";
    } else if (temperature < 5) {
      return "Sıcaklık çok düşük, sulama yapmanıza gerek yok.";
    }

    // Bitki özel durumları
    if (soilMoisture < moistureNeeds["soil_min"]! * seasonalFactor) {
      return "${plantType} için toprak nemi çok düşük, sulama yapmanız önerilir.";
    }

    if (humidity < moistureNeeds["min"]! * seasonalFactor) {
      return "${plantType} için hava nemi düşük, sulama yapmanız önerilir.";
    }

    return "${plantType} için nem seviyeleri uygun, sulama yapmanıza gerek yok.";
  }

  bool shouldIrrigate() {
    if (isRaining) return false;

    final plantCategory = _getPlantCategory();
    final moistureNeeds = _plantMoistureNeeds[plantCategory]!;
    final seasonalFactor = _getSeasonalFactor();

    // Toprak nemi kontrolü
    if (soilMoisture > moistureNeeds["soil_max"]! * seasonalFactor) {
      return false;
    }

    // Hava nemi kontrolü
    if (humidity > moistureNeeds["max"]! * seasonalFactor) {
      return false;
    }

    // Sıcaklık kontrolü
    if (temperature < 5 || temperature > 35) {
      return false;
    }

    // Bitki özel durumları
    return soilMoisture < moistureNeeds["soil_min"]! * seasonalFactor ||
        humidity < moistureNeeds["min"]! * seasonalFactor;
  }

  // Sulama miktarı önerisi (ml cinsinden)
  double getIrrigationAmount() {
    final plantCategory = _getPlantCategory();
    final baseAmount = _getBaseIrrigationAmount(plantCategory);
    final seasonalFactor = _getSeasonalFactor();

    // Nem ve sıcaklık faktörleri
    double humidityFactor = 1.0;
    if (humidity < 30)
      humidityFactor = 1.3;
    else if (humidity > 70) humidityFactor = 0.7;

    double temperatureFactor = 1.0;
    if (temperature > 30)
      temperatureFactor = 1.2;
    else if (temperature < 10) temperatureFactor = 0.8;

    return baseAmount * seasonalFactor * humidityFactor * temperatureFactor;
  }

  double _getBaseIrrigationAmount(String plantCategory) {
    switch (plantCategory) {
      case "sukulent":
        return 100.0; // ml
      case "tropikal":
        return 300.0;
      case "çöl":
        return 50.0;
      case "akdeniz":
        return 200.0;
      default:
        return 150.0;
    }
  }
}
