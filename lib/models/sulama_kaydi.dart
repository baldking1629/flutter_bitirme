import 'package:cloud_firestore/cloud_firestore.dart';

class SulamaKaydi {
  final String tarlaId;
  final int sulamaZamani;
  final bool tamamlandiMi;
  final Timestamp tarih;

  SulamaKaydi({
    required this.tarlaId,
    required this.sulamaZamani,
    required this.tamamlandiMi,
    required this.tarih,
  });

  Map<String, dynamic> toMap() {
    return {
      'Tarla_id': tarlaId,
      'Sulama_zamani': sulamaZamani,
      'Tamamlandi_mi': tamamlandiMi,
      'Tarih': tarih,
    };
  }

  factory SulamaKaydi.fromMap(Map<String, dynamic> map) {
    return SulamaKaydi(
      tarlaId: map['Tarla_id'] ?? '',
      sulamaZamani: map['Sulama_zamani'] ?? 0,
      tamamlandiMi: map['Tamamlandi_mi'] ?? false,
      tarih: map['Tarih'] ?? Timestamp.now(),
    );
  }
}
