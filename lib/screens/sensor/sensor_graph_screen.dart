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
  QuerySnapshot? _snapshot;
  String _selectedTimeRange = 'Son 1 Gün'; // Varsayılan değer
  bool _isFirstLoad = true;

  final Map<String, Duration> _timeRanges = {
    'Son 1 Gün': Duration(days: 1),
    'Son 2 Gün': Duration(days: 2),
    'Son 1 Hafta': Duration(days: 7),
    'Son 2 Hafta': Duration(days: 14),
    'Son 1 Ay': Duration(days: 30),
    'Son 3 Ay': Duration(days: 90),
    'Son 6 Ay': Duration(days: 180),
    'Son 1 Yıl': Duration(days: 365),
  };

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isFirstLoad) {
      _isFirstLoad = false;
      _loadSensorData();
    }
  }

  Future<void> _loadSensorData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final DateTime now = DateTime.now();
      final DateTime startTime = now.subtract(_timeRanges[_selectedTimeRange]!);

      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Sensor_kayitlari')
          .where('Sensor_id', isEqualTo: widget.sensorId)
          .where('Tarih', isGreaterThanOrEqualTo: Timestamp.fromDate(startTime))
          .orderBy('Tarih', descending: false)
          .get();

      if (!mounted) return;

      if (snapshot.docs.isEmpty) {
        setState(() {
          _isLoading = false;
          _spots = [];
          _snapshot = null;
        });
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

      if (!mounted) return;

      setState(() {
        _spots = spots;
        _minY = minY;
        _maxY = maxY;
        _snapshot = snapshot;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veriler yüklenirken bir hata oluştu: $e')),
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
      body: SingleChildScrollView(
        padding: AppTheme.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sensör Verileri',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 8),
            Text(
              'Seçilen sensöre ait geçmiş veriler görselleştirilmektedir.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                ),
              ),
              child: DropdownButton<String>(
                value: _selectedTimeRange,
                isExpanded: true,
                underline: SizedBox(),
                icon: Icon(Icons.arrow_drop_down),
                style: Theme.of(context).textTheme.bodyLarge,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedTimeRange = newValue;
                      _isLoading = true;
                    });
                    _loadSensorData();
                  }
                },
                items: _timeRanges.keys
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Row(
                      children: [
                        Icon(Icons.access_time, size: 20),
                        SizedBox(width: 8),
                        Text(value),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 24),
            if (_isLoading)
              Center(child: CircularProgressIndicator())
            else if (_spots.isEmpty)
              Center(
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
                      'Bu güne ait veri bulunamadı',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              )
            else ...[
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      height: 300,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: true,
                            horizontalInterval: (_maxY - _minY) / 5,
                            verticalInterval:
                                (_spots.length / 5).ceil().toDouble(),
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
                                interval: (_spots.length / 5).ceil().toDouble(),
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() >= _spots.length ||
                                      _snapshot == null) return Text('');

                                  final doc = _snapshot!.docs[value.toInt()];
                                  final data =
                                      doc.data() as Map<String, dynamic>;
                                  final timestamp =
                                      (data['Tarih'] as Timestamp).toDate();

                                  String date;
                                  if (_selectedTimeRange == 'Son 1 Gün' ||
                                      _selectedTimeRange == 'Son 2 Gün') {
                                    date =
                                        DateFormat('HH:mm').format(timestamp);
                                  } else {
                                    date = DateFormat('dd.MM HH:mm')
                                        .format(timestamp);
                                    // Label skipping için kontrol
                                    if (value.toInt() % 3 != 0) {
                                      return Text('');
                                    }
                                  }

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
                                getDotPainter: (spot, percent, barData, index) {
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
              SizedBox(height: 16),
              Text(
                'Veriler Firebase\'den gerçek zamanlı olarak çekilmektedir',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
