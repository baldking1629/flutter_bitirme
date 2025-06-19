import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bitirme/models/field_model.dart';
import 'package:flutter_bitirme/models/sensor_model.dart';
import 'package:flutter_bitirme/screens/sensor/sensor_graph_screen.dart';
import 'package:flutter_bitirme/screens/sensor/sensor_edit_screen.dart';
import 'package:flutter_bitirme/theme/app_theme.dart';
import 'package:flutter_bitirme/services/weather_service.dart';
import 'package:flutter_bitirme/models/weather_forecast_day.dart';
import 'package:flutter_bitirme/widgets/weather_forecast_widget.dart';
import 'package:flutter_bitirme/services/gemini_service.dart';
import 'package:flutter_bitirme/models/irrigation_advice_model.dart';
import 'package:flutter_bitirme/models/weather_model.dart';

import 'field_screen.dart';

class FieldDetailScreen extends StatefulWidget {
  final String fieldId;
  final IrrigationAdvice? irrigationAdvice;

  const FieldDetailScreen({
    Key? key,
    required this.fieldId,
    this.irrigationAdvice,
  }) : super(key: key);

  @override
  _FieldDetailScreenState createState() => _FieldDetailScreenState();
}

class _FieldDetailScreenState extends State<FieldDetailScreen> {
  bool _isLoading = false;
  FieldModel? _fieldData;

  @override
  void initState() {
    super.initState();
    _loadFieldData();
  }

  Future<void> _loadFieldData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);
    try {
      final doc = await FirebaseFirestore.instance
          .collection('Tarlalar')
          .doc(widget.fieldId)
          .get();

      if (doc.exists) {
        setState(() {
          _fieldData = FieldModel.fromJson(doc.data()!);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tarla bulunamadı')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tarla bilgileri yüklenirken hata oluştu')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tarla Detayları'),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _fieldData == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text(
                        'Tarla bilgileri yüklenemedi',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: AppTheme.screenPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FieldScreen(
                                  fieldId: widget.fieldId,
                                ),
                              ),
                            ).then((_) => _loadFieldData());
                          },
                          child: Padding(
                            padding: AppTheme.cardPadding,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Tarla Bilgileri',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                    Icon(Icons.edit,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                  ],
                                ),
                                SizedBox(height: 16),
                                _buildInfoRow(
                                    'Tarla Adı', _fieldData!.tarlaIsmi),
                                _buildInfoRow('Konum', '${_fieldData!.konum}'),
                                _buildInfoRow(
                                    'Alan', '${_fieldData!.boyut} m²'),
                                _buildInfoRow(
                                    'Tarla İçeriği', _fieldData!.Tarla_icerigi),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      Card(
                        child: Padding(
                          padding: AppTheme.cardPadding,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Sensör Verileri',
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  SizedBox(
                                    width: 150,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SensorEditScreen(
                                              tarlaId: widget.fieldId,
                                            ),
                                          ),
                                        );
                                      },
                                      icon: Icon(Icons.add),
                                      label: Text('Sensör Ekle'),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('Sensorler')
                                    .where('Tarla_id',
                                        isEqualTo: widget.fieldId)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                        child: CircularProgressIndicator());
                                  }

                                  if (!snapshot.hasData ||
                                      snapshot.data!.docs.isEmpty) {
                                    return Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.sensors,
                                            size: 48,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withOpacity(0.5),
                                          ),
                                          SizedBox(height: 16),
                                          Text(
                                            'Henüz sensör bulunmuyor',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'Sensör eklemek için yönetici ile iletişime geçin',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    );
                                  }

                                  return ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: snapshot.data!.docs.length,
                                    itemBuilder: (context, index) {
                                      final doc = snapshot.data!.docs[index];
                                      final sensor = SensorModel.fromJson(
                                          doc.data() as Map<String, dynamic>);

                                      return ListTile(
                                        leading: Icon(Icons.sensors),
                                        title: Text(sensor.sensorAdi),
                                        subtitle: Text(sensor.sensorTipi),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                Icons.edit,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        SensorEditScreen(
                                                      tarlaId: widget.fieldId,
                                                      sensorId: doc.id,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                            Icon(Icons.arrow_forward_ios),
                                          ],
                                        ),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  SensorGraphScreen(
                                                sensorId: doc.id,
                                                sensorName: "",
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      // SULAMA ÖNERİLERİ
                      Card(
                        child: Padding(
                          padding: AppTheme.cardPadding,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Sulama Önerileri',
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.refresh),
                                    onPressed: () {
                                      setState(() {});
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              if (widget.irrigationAdvice?.sulamaGerekiyorMu ==
                                      'Sensör bulunmadığı için öneri verilemiyor' ||
                                  widget.irrigationAdvice == null)
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.water_drop,
                                        size: 48,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.5),
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'Sulama önerisi için sensör gerekli',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Sulama önerileri almak için tarlanıza sensör ekleyin',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                )
                              else
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildAdviceRow(
                                      'Sulama Gerekiyor Mu',
                                      widget
                                          .irrigationAdvice!.sulamaGerekiyorMu,
                                      Icons.water_drop,
                                    ),
                                    SizedBox(height: 12),
                                    _buildAdviceRow(
                                      'Su Miktarı',
                                      widget.irrigationAdvice!.suMiktari,
                                      Icons.water,
                                    ),
                                    SizedBox(height: 12),
                                    _buildAdviceRow(
                                      'En Uygun Zaman',
                                      widget.irrigationAdvice!.enUygunZaman,
                                      Icons.access_time,
                                    ),
                                    SizedBox(height: 12),
                                    _buildAdviceRow(
                                      'Diğer Öneriler',
                                      widget.irrigationAdvice!.digerOneriler,
                                      Icons.lightbulb,
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      // HAVA DURUMU TAHMİNİ
                      if (_fieldData?.enlem != null &&
                          _fieldData?.boylam != null)
                        Card(
                          child: Padding(
                            padding: AppTheme.cardPadding,
                            child: FutureBuilder(
                              future: WeatherService().getForecastByLocation(
                                double.parse(_fieldData!.enlem!),
                                double.parse(_fieldData!.boylam!),
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                }
                                if (!snapshot.hasData ||
                                    snapshot.data == null) {
                                  return Center(
                                      child: Text(
                                          'Hava durumu tahmini alınamadı.'));
                                }
                                final forecastList =
                                    snapshot.data!["list"] as List<dynamic>?;
                                if (forecastList == null ||
                                    forecastList.isEmpty) {
                                  return Center(
                                      child: Text('Tahmin verisi yok.'));
                                }
                                final days = groupForecastByDay(forecastList);
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('5 Günlük Hava Durumu Tahmini',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge),
                                    SizedBox(height: 12),
                                    WeatherForecastWidget(days: days),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    IconData icon;
    switch (label) {
      case 'Tarla Adı':
        icon = Icons.agriculture;
        break;
      case 'Konum':
        icon = Icons.location_on;
        break;
      case 'Alan':
        icon = Icons.crop_square;
        break;
      case 'Tarla İçeriği':
        icon = Icons.grass;
        break;
      default:
        icon = Icons.info;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceRow(String title, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
