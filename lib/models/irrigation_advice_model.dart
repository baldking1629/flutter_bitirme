class IrrigationAdvice {
  final String sulamaGerekiyorMu;
  final String suMiktari;
  final String enUygunZaman;
  final String digerOneriler;
  final bool hasSensor;

  IrrigationAdvice({
    required this.sulamaGerekiyorMu,
    required this.suMiktari,
    required this.enUygunZaman,
    required this.digerOneriler,
    required this.hasSensor,
  });

  factory IrrigationAdvice.fromMap(Map<String, String> map,
      {required bool hasSensor}) {
    if (!hasSensor) {
      return IrrigationAdvice.noSensor();
    }

    return IrrigationAdvice(
      sulamaGerekiyorMu: map['sulamaGerekiyorMu'] ?? 'Bilgi yok',
      suMiktari: map['suMiktari'] ?? 'Bilgi yok',
      enUygunZaman: map['enUygunZaman'] ?? 'Bilgi yok',
      digerOneriler: map['digerOneriler'] ?? 'Bilgi yok',
      hasSensor: hasSensor,
    );
  }

  factory IrrigationAdvice.noSensor() {
    return IrrigationAdvice(
      sulamaGerekiyorMu: 'Sensör bulunmadığı için öneri verilemiyor',
      suMiktari: 'Sensör bulunmadığı için öneri verilemiyor',
      enUygunZaman: 'Sensör bulunmadığı için öneri verilemiyor',
      digerOneriler: 'Lütfen tarlanıza sensör ekleyin',
      hasSensor: false,
    );
  }

  Map<String, String> toMap() {
    return {
      'sulamaGerekiyorMu': sulamaGerekiyorMu,
      'suMiktari': suMiktari,
      'enUygunZaman': enUygunZaman,
      'digerOneriler': digerOneriler,
    };
  }

  @override
  String toString() {
    if (!hasSensor) {
      return '''
Sensör bulunmadığı için sulama önerisi verilemiyor.
Lütfen tarlanıza sensör ekleyin.
''';
    }

    return '''
Sulama Gerekiyor Mu: $sulamaGerekiyorMu
Su Miktarı: $suMiktari
En Uygun Zaman: $enUygunZaman
Diğer Öneriler: $digerOneriler
''';
  }
}
