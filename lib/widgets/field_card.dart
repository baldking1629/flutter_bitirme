import 'package:flutter/material.dart';
import 'package:flutter_bitirme/models/irrigation_advice_model.dart';
import '../models/weather_model.dart';
import '../models/irrigation_model.dart';
import 'weather_card.dart';
import '../screens/sensor/sensor_graph_screen.dart';
import '../screens/field/field_detail_screen.dart';
import '../services/gemini_service.dart';
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
    final humidity = weather?.humidity ?? 50.0;
    final temperature = weather?.temperature ?? 20.0;
    final soilMoisture = lastSensor?['value'] as double? ?? 50.0;
    final isRaining = weather?.isRaining ?? false;

    // Sensör değerini göster
    final sensorValue = lastSensor?['value'] as double? ?? 0.0;
    final sensorTimestamp =
        lastSensor?['timestamp'] as DateTime? ?? DateTime.now();

    // Son güncelleme zamanını göster
    final lastUpdate = sensorTimestamp.toString().substring(0, 16);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fieldName,
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        location,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: () async {
                    // Sulama önerilerini al
                    final advice = await GeminiService().getIrrigationAdvice(
                      temperature: temperature,
                      humidity: humidity.toDouble(),
                      soilMoisture: soilMoisture,
                      isRaining: isRaining,
                      cropType: mahsul,
                      hasSensor: sensors.isNotEmpty,
                    );

                    if (!context.mounted) return;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FieldDetailScreen(
                          fieldId: fieldId,
                          irrigationAdvice: advice,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (weather != null) WeatherCard(weather: weather!),
            const SizedBox(height: 12),
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
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                      const SizedBox(width: 10),
                      Text(
                        lastSensor!['name'],
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        lastSensor!['type'],
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "%",
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        sensorValue.toStringAsFixed(1),
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (lastSensor!['timestamp'] != null) ...[
                        const SizedBox(width: 10),
                        Text(
                          lastUpdate,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),
            FutureBuilder<IrrigationAdvice>(
              future: GeminiService().getIrrigationAdvice(
                temperature: temperature,
                humidity: humidity.toDouble(),
                soilMoisture: soilMoisture,
                isRaining: isRaining,
                cropType: mahsul,
                hasSensor: sensors.isNotEmpty,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData) {
                  return Container(
                    padding: const EdgeInsets.all(16),
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
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Sulama Önerisi',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Öneri alınamadı.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }

                return Container(
                  padding: const EdgeInsets.all(16),
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
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Sulama Önerisi',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        snapshot.data?.sulamaGerekiyorMu ?? 'Öneri alınamadı.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
