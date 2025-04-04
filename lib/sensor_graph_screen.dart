import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class SensorGraphScreen extends StatelessWidget {
  final String sensorId;
  SensorGraphScreen({required this.sensorId});

  @override
  Widget build(BuildContext context) {
    // Bugünün başlangıç ve bitiş zamanını hesapla
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0);
    DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection("Sensor_kayitlari")
          .where("Sensor_id", isEqualTo: sensorId)
          .where("Tarih", isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where("Tarih", isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .orderBy("Tarih", descending: false)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return Center(child: Text("Bugüne ait sensör verisi yok."));
        }

        List<FlSpot> spots = [];
        List<String> dateLabels = [];
        for (var i = 0; i < docs.length; i++) {
          var data = docs[i].data() as Map<String, dynamic>;
          double value = (data["Deger"] as num).toDouble();
          DateTime time = (data["Tarih"] as Timestamp).toDate();
          
          spots.add(FlSpot(i.toDouble(), value));
          dateLabels.add(DateFormat("HH:mm").format(time)); // Sadece saat ve dakika göster
        }

        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: SizedBox(
            height: 250, // Otomatik büyüme için yeterli alan bırak
            child: LineChart(
              LineChartData(
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < dateLabels.length) {
                          return Text(dateLabels[value.toInt()], style: TextStyle(fontSize: 10));
                        }
                        return SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
