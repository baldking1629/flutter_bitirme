import 'package:cloud_firestore/cloud_firestore.dart';

class FieldModel {
  final String kullaniciId;
  final Timestamp olusturulmaTarihi;
  final String tarlaIsmi;
  final String konum;
  final String boyut;

  FieldModel({
    required this.kullaniciId,
    required this.olusturulmaTarihi,
    required this.tarlaIsmi,
    required this.konum,
    required this.boyut,
  });

  factory FieldModel.fromJson(Map<String, dynamic> json) {
    return FieldModel(
      kullaniciId: json['Kullanici_id'] as String,
      olusturulmaTarihi: json['Olusturulma_tarihi'] as Timestamp,
      tarlaIsmi: json['Tarla_ismi'] as String,
      konum: json['Konum'] as String,
      boyut: json['Boyut'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Kullanici_id': kullaniciId,
      'Olusturulma_tarihi': olusturulmaTarihi,
      'Tarla_ismi': tarlaIsmi,
      'Konum': konum,
      'Boyut': boyut,
    };
  }
}
