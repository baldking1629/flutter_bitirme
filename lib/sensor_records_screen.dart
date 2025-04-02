import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Tarih formatı için

class SensorRecordsScreen extends StatelessWidget {
  final String sensorId;

  SensorRecordsScreen({required this.sensorId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sensör Kayıtları")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Sensor_kayitlari")
            .where("sensor_id", isEqualTo: sensorId)
            .orderBy("tarih", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("Bu sensör için kayıt bulunamadı."));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              Map<String, dynamic> record = doc.data() as Map<String, dynamic>;
              Timestamp timestamp = record["tarih"];
              String formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(timestamp.toDate());

              return ListTile(
                title: Text("Değer: ${record['deger']}"),
                subtitle: Text("Tarih: $formattedDate"),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
