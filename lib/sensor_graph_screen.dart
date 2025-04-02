import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class SensorGraphScreen extends StatelessWidget {
  final String sensorId;
  SensorGraphScreen({required this.sensorId});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        margin: EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Sensör Verileri", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection("Sensor_kayitlari")
                    .where("Sensor_id", isEqualTo: sensorId)
                    .orderBy("Tarih", descending: false)
                    .get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
      
                  var docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return Center(child: Text("Veri bulunamadı"));
                  }
      
                  List<FlSpot> spots = [];
                  List<String> dateLabels = [];
                  for (var i = 0; i < docs.length; i++) {
                    var data = docs[i].data() as Map<String, dynamic>;
                    double value = (data["Deger"] as num).toDouble();
                    DateTime time = (data["Tarih"] as Timestamp).toDate();
                    spots.add(FlSpot(i.toDouble(), value));
                    dateLabels.add(DateFormat("dd/MM HH:mm").format(time));
                  }
      
                  return SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
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
                            barWidth: 4,
                            isStrokeCapRound: true,
                            belowBarData: BarAreaData(show: false),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}