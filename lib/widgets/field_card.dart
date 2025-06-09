import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../models/irrigation_model.dart';
import 'weather_card.dart';
import '../screens/sensor/sensor_graph_screen.dart';
import '../screens/field/field_detail_screen.dart';
import 'package:intl/intl.dart';

class FieldCard extends StatelessWidget {
  final String fieldId;
  final String fieldName;
  final String location;
  final String area;
  final String mahsul;
  final WeatherModel? weather;
  final List<Map<String, dynamic>> sensors;

  const FieldCard({
    Key? key,
    required this.fieldId,
    required this.fieldName,
    required this.location,
    required this.area,
    required this.mahsul,
    this.weather,
    this.sensors = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // En güncel sensör verisini bul (timestamp'e göre)
    Map<String, dynamic>? lastSensor;
    if (sensors.isNotEmpty) {
      sensors.sort((a, b) {
        final aTime = a['timestamp'] as DateTime?;
        final bTime = b['timestamp'] as DateTime?;
        if (aTime == null || bTime == null) return 0;
        return bTime.compareTo(aTime);
      });
      lastSensor = sensors.first;
    }

    // Sulama modeli için gerekli verileri hazırla
    double humidity = 50.0; // Varsayılan değer
    double temperature = weather?.temperature ?? 20.0;
    double soilMoisture = 50.0; // Varsayılan değer
    bool isRaining = weather?.isRaining ?? false;

    // Sensör verilerinden nem ve toprak nemi değerlerini al
    if (sensors.isNotEmpty) {
      for (var sensor in sensors) {
        if (sensor['type'] == 'nem') {
          humidity =
              double.tryParse(sensor['value'].toString().replaceAll('%', '')) ??
                  humidity;
        } else if (sensor['type'] == 'Toprak Nemi') {
          soilMoisture =
              double.tryParse(sensor['value'].toString().replaceAll('%', '')) ??
                  soilMoisture;
        }
      }
    }

    // Sulama modelini oluştur
    final irrigationModel = IrrigationModel(
      humidity: humidity,
      temperature: temperature,
      isRaining: isRaining,
      plantType: mahsul,
      season: _getCurrentSeason(),
      soilMoisture: soilMoisture,
    );

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FieldDetailScreen(fieldId: fieldId),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tarla adı ve alan
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      fieldName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    "$area hektar",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Text(
                location,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 16),
              // Hava durumu
              if (weather != null) WeatherCard(weather: weather!),
              // Sensör verisi (sadece en güncel)
              SizedBox(height: 12),
              if (lastSensor != null)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SensorGraphScreen(
                          sensorId: lastSensor!['id'],
                          sensorName: lastSensor!['name'],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark
                          ? Colors.blue.shade900.withOpacity(0.2)
                          : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(lastSensor!['icon'],
                            color: theme.colorScheme.primary, size: 22),
                        SizedBox(width: 10),
                        Text(
                          lastSensor!['name'],
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        SizedBox(width: 2),
                        Text(
                          lastSensor!['type'],
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        SizedBox(width: 10),
                        Text(
                          "%",
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          lastSensor!['value'],
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        
                        if (lastSensor!['timestamp'] != null) ...[
                          SizedBox(width: 10),
                          Text(
                            DateFormat('dd.MM.yyyy HH:mm')
                                .format(lastSensor!['timestamp']),
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                        ],
                      ],
                    ),
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark
                        ? Colors.green.shade900.withOpacity(0.2)
                        : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Veri bulunamadı.",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              // Sulama önerisi bölümü
              SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? Colors.green.shade900.withOpacity(0.2)
                      : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.water_drop,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Sulama Önerisi",
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      irrigationModel.getIrrigationAdvice(),
                      style: theme.textTheme.bodyMedium,
                    ),
                    if (irrigationModel.shouldIrrigate()) ...[
                      SizedBox(height: 8),
                      Text(
                        "Önerilen sulama miktarı: ${irrigationModel.getIrrigationAmount().toStringAsFixed(0)} ml",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCurrentSeason() {
    final now = DateTime.now();
    final month = now.month;

    if (month >= 3 && month <= 5) return "ilkbahar";
    if (month >= 6 && month <= 8) return "yaz";
    if (month >= 9 && month <= 11) return "sonbahar";
    return "kış";
  }
}
