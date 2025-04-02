import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'sensor_detail_screen.dart';
import 'sensor_edit_screen.dart';

class SensorListScreen extends StatelessWidget {
  final String fieldId;

  SensorListScreen({required this.fieldId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sensörler")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Sensorler")
            .where('Tarla_id', isEqualTo: fieldId) // ✅ Tarlaya ait sensörleri getir
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
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(sensor['Sensor_tipi'] ?? "Sensör"),
                  subtitle: Text("Konum: ${sensor['Konum'] ?? "Bilinmiyor"}"),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SensorDetailScreen(tarlaId: fieldId),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SensorEditScreen(tarlaId: fieldId),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
