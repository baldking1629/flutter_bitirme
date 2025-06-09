import 'package:cloud_firestore/cloud_firestore.dart';

class FieldModel {
  final String kullaniciId;
  final Timestamp olusturulmaTarihi;
  final String tarlaIsmi;
  final String konum;
  final String? enlem;
  final String? boylam;
  final String boyut;
  final String mahsul;

  FieldModel({
    required this.kullaniciId,
    required this.olusturulmaTarihi,
    required this.tarlaIsmi,
    required this.konum,
    this.enlem,
    this.boylam,
    required this.boyut,
    required this.mahsul,
  });

  factory FieldModel.fromJson(Map<String, dynamic> json) {
    return FieldModel(
      kullaniciId: json['Kullanici_id'] as String,
      olusturulmaTarihi: json['Olusturulma_tarihi'] as Timestamp,
      tarlaIsmi: json['Tarla_ismi'] as String,
      konum: json['Konum'] as String,
      enlem: json['Enlem'] as String,
      boylam: json['Boylam'] as String,
      boyut: json['Boyut'] as String,
      mahsul: json['Mahsul'] as String? ?? "Belirtilmemiş",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Kullanici_id': kullaniciId,
      'Olusturulma_tarihi': olusturulmaTarihi,
      'Tarla_ismi': tarlaIsmi,
      'Konum': konum,
      'Enlem': enlem,
      'Boylam': boylam,
      'Boyut': boyut,
      'Mahsul': mahsul,
    };
  }
}
