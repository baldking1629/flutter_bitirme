import 'package:cloud_firestore/cloud_firestore.dart';

class SensorRecordModel {
  final double deger;
  final String sensorId;
  final Timestamp tarih;

  SensorRecordModel({
    required this.deger,
    required this.sensorId,
    required this.tarih,
  });

  factory SensorRecordModel.fromJson(Map<String, dynamic> json) {
    return SensorRecordModel(
      deger: (json['Deger'] as num).toDouble(),
      sensorId: json['Sensor_id'] as String,
      tarih: json['Tarih'] as Timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Deger': deger,
      'Sensor_id': sensorId,
      'Tarih': tarih,
    };
  }
}
