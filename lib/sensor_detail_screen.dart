import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'sensor_records_screen.dart'; // Sensör kayıtlarını gösterecek sayfa
import 'sensor_edit_screen.dart'; // Sensör düzenleme sayfası

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
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SensorEditScreen(sensorId: doc.id, tarlaId: tarlaId,),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection("Sensorler")
                            .doc(doc.id)
                            .delete();
                      },
                    ),
                  ],
                ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Sensör ekleme sayfasına yönlendirme
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SensorEditScreen(tarlaId: tarlaId),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
