import 'package:cloud_firestore/cloud_firestore.dart';

class SensorModel {
  final String tarlaId;
  final String konum;
  final String sensorAdi;
  final String sensorTipi;
  final Timestamp olusturulmaTarihi;

  SensorModel({
    required this.tarlaId,
    required this.konum,
    required this.sensorAdi,
    required this.sensorTipi,
    required this.olusturulmaTarihi,
  });

  factory SensorModel.fromJson(Map<String, dynamic> json) {
    return SensorModel(
      tarlaId: json['Tarla_id'] as String,
      konum: json['Konum'] as String,
      sensorAdi: json['Sensor_adi'] as String,
      sensorTipi: json['Sensor_tipi'] as String,
      olusturulmaTarihi: json['Olusturulma_tarihi'] as Timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Tarla_id': tarlaId,
      'Konum': konum,
      'Sensor_adi': sensorAdi,
      'Sensor_tipi': sensorTipi,
      'Olusturulma_tarihi': olusturulmaTarihi,
    };
  }
}
