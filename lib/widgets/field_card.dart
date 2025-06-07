import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import 'weather_card.dart';
import '../screens/sensor/sensor_graph_screen.dart';
import '../screens/field/field_detail_screen.dart';
import 'package:intl/intl.dart';

class FieldCard extends StatelessWidget {
  final String fieldId;
  final String fieldName;
  final String location;
  final String area;
  final WeatherModel? weather;
  final List<Map<String, dynamic>>
      sensors; // [{name, value, icon, id, timestamp}, ...]

  const FieldCard({
    Key? key,
    required this.fieldId,
    required this.fieldName,
    required this.location,
    required this.area,
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
                    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark
                          ? Colors.green.shade900.withOpacity(0.2)
                          : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.10),
                      ),
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
            ],
          ),
        ),
      ),
    );
  }
}
