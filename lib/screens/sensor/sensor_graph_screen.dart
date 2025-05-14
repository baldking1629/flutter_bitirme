import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bitirme/theme/app_theme.dart';
import 'package:intl/intl.dart';

class SensorGraphScreen extends StatefulWidget {
  final String sensorId;
  final String sensorName;

  const SensorGraphScreen({
    Key? key,
    required this.sensorId,
    required this.sensorName,
  }) : super(key: key);

  @override
  _SensorGraphScreenState createState() => _SensorGraphScreenState();
}

class _SensorGraphScreenState extends State<SensorGraphScreen> {
  bool _isLoading = true;
  List<FlSpot> _spots = [];
  double _minY = 0;
  double _maxY = 0;

  @override
  void initState() {
    super.initState();
    _loadSensorData();
  }

  Future<void> _loadSensorData() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Sensor_kayitlari')
          .where('Sensor_id', isEqualTo: widget.sensorId)
          .orderBy('Tarih', descending: false)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      List<FlSpot> spots = [];
      double minY = double.infinity;
      double maxY = -double.infinity;

      for (int i = 0; i < snapshot.docs.length; i++) {
        final doc = snapshot.docs[i];
        final data = doc.data() as Map<String, dynamic>;
        final value = (data['Deger'] as num).toDouble();
        final timestamp = (data['Tarih'] as Timestamp).toDate();

        spots.add(FlSpot(i.toDouble(), value));
        minY = minY < value ? minY : value;
        maxY = maxY > value ? maxY : value;
      }

      setState(() {
        _spots = spots;
        _minY = minY;
        _maxY = maxY;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veriler yüklenirken bir hata oluştu')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sensorName),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _spots.isEmpty
              ? Center(
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
                    ],
                  ),
                )
              : Padding(
                  padding: AppTheme.screenPadding,
                  child: Column(
                    children: [
                      Expanded(
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: true,
                              horizontalInterval: 1,
                              verticalInterval: 1,
                              getDrawingHorizontalLine: (value) {
                                return FlLine(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.1),
                                  strokeWidth: 1,
                                );
                              },
                              getDrawingVerticalLine: (value) {
                                return FlLine(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.1),
                                  strokeWidth: 1,
                                );
                              },
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  interval:
                                      (_spots.length / 5).ceil().toDouble(),
                                  getTitlesWidget: (value, meta) {
                                    if (value.toInt() >= _spots.length)
                                      return Text('');
                                    final date = DateFormat('dd/MM').format(
                                      DateTime.fromMillisecondsSinceEpoch(
                                        (_spots[value.toInt()].x * 1000)
                                            .toInt(),
                                      ),
                                    );
                                    return Text(
                                      date,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    );
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: (_maxY - _minY) / 5,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      value.toStringAsFixed(1),
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    );
                                  },
                                  reservedSize: 42,
                                ),
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.2),
                              ),
                            ),
                            minX: 0,
                            maxX: _spots.length.toDouble() - 1,
                            minY: _minY - (_maxY - _minY) * 0.1,
                            maxY: _maxY + (_maxY - _minY) * 0.1,
                            lineBarsData: [
                              LineChartBarData(
                                spots: _spots,
                                isCurved: true,
                                color: Theme.of(context).colorScheme.primary,
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter:
                                      (spot, percent, barData, index) {
                                    return FlDotCirclePainter(
                                      radius: 4,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      strokeWidth: 2,
                                      strokeColor: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.5),
                                    );
                                  },
                                ),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
