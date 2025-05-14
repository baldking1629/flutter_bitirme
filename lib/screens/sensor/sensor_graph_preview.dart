// sensor_graph_preview.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bitirme/screens/sensor/sensor_graph_screen.dart';
import '../../models/sensor_record_model.dart';

class SensorGraphPreview extends StatelessWidget {
  final String sensorId;
  final String sensorName;

  const SensorGraphPreview({
    Key? key,
    required this.sensorId,
    required this.sensorName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Sensor_kayitlari')
          .where('Sensor_id', isEqualTo: sensorId)
          .orderBy('Tarih', descending: true)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text('Sensör verisi yok.');
        }

        final record = SensorRecordModel.fromJson(
            snapshot.data!.docs.first.data() as Map<String, dynamic>);

        return ListTile(
          leading: Icon(Icons.thermostat),
          title: Text(sensorName),
          subtitle: Text('Son Değer: ${record.deger}'),
          trailing: Icon(Icons.bar_chart),
          onTap: () {
            // Tam ekran detaylı grafik sayfasına git
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SensorGraphScreen(
                  sensorId: sensorId,
                  sensorName: sensorName,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
