import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import '../../models/sensor_record_model.dart';

class SensorGraphScreen extends StatelessWidget {
  final String sensorId;
  final String sensorName;

  const SensorGraphScreen({
    Key? key,
    required this.sensorId,
    required this.sensorName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(sensorName),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Sensor_kayitlari')
                  .where('Sensor_id', isEqualTo: sensorId)
                  .orderBy('Tarih', descending: true)
                  .limit(100)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: SingleChildScrollView(
                      // Hatalı boyutları engellemek için eklendi
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.show_chart,
                              size: 64,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.5),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Henüz veri bulunmuyor',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Sensör verileri henüz kaydedilmemiş',
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                final records = snapshot.data!.docs
                    .map((doc) => SensorRecordModel.fromJson(
                        doc.data() as Map<String, dynamic>))
                    .toList();

                return ListView.builder(
                  padding: AppTheme.screenPadding,
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return Card(
                      child: ListTile(
                        leading: Icon(Icons.show_chart),
                        title: Text('${record.deger}'),
                        subtitle: Text(
                          '${record.tarih.toDate().toString().split('.')[0]}',
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
