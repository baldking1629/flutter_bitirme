import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'sensor_records_screen.dart'; // Sensör kayıtlarını gösterecek sayfa

class SensorDetailScreen extends StatelessWidget {
  final String tarlaId;

  SensorDetailScreen({required this.tarlaId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sensörler")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Sensorler")
            .where('Tarla_id', isEqualTo: tarlaId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("Bu tarlaya ait sensör bulunamadı."));
          }
          return ListView(
            children: snapshot.data!.docs.map((doc) {
              Map<String, dynamic> sensor = doc.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(sensor['Sensor_tipi'] ?? "Bilinmeyen Sensör"),
                subtitle: Text("Konum: ${sensor['Konum'] ?? "Bilinmeyen"}"),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SensorRecordsScreen(sensorId: doc.id),
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
