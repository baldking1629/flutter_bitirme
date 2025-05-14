import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bitirme/theme/app_theme.dart';
import 'sensor_detail_screen.dart';
import 'sensor_edit_screen.dart';

class SensorListScreen extends StatelessWidget {
  final String fieldId;

  SensorListScreen({required this.fieldId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sensörler"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Sensorler")
            .where('Tarla_id', isEqualTo: fieldId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sensors,
                    size: 64,
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Henüz sensör bulunmuyor',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Yeni bir sensör eklemek için + butonuna tıklayın',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: AppTheme.screenPadding,
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var sensor = doc.data() as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: AppTheme.cardPadding,
                  leading: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.sensors,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    sensor['Sensor_adi'] ?? "Sensör",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Text(
                        "Tip: ${sensor['Sensor_tipi'] ?? "Bilinmiyor"}",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        "Konum: ${sensor['Konum'] ?? "Bilinmiyor"}",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SensorDetailScreen(
                          tarlaId: fieldId,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SensorEditScreen(tarlaId: fieldId),
            ),
          );
        },
        icon: Icon(Icons.add),
        label: Text('Sensör Ekle'),
      ),
    );
  }
}
