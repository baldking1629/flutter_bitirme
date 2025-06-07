import 'package:flutter/material.dart';
import '../models/weather_forecast_day.dart';

class WeatherForecastWidget extends StatelessWidget {
  final List<WeatherForecastDay> days;
  const WeatherForecastWidget({Key? key, required this.days}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: days.length,
      itemBuilder: (context, dayIndex) {
        final day = days[dayIndex];
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${day.date.day}.${day.date.month}.${day.date.year}",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 8),
              SizedBox(
                height: 140,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: day.hours.length,
                  separatorBuilder: (_, __) => SizedBox(width: 10),
                  itemBuilder: (context, i) {
                    final hour = day.hours[i];
                    return ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: 90,
                        maxWidth: 100,
                        minHeight: 120,
                        maxHeight: 140,
                      ),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${hour.dateTime.hour}:00",
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            SizedBox(height: 6),
                            Image.network(
                              'https://openweathermap.org/img/wn/${hour.icon}@2x.png',
                              width: 36,
                              height: 36,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.cloud,
                                      size: 28, color: Colors.grey.shade400),
                            ),
                            SizedBox(height: 6),
                            Text(
                              "${hour.temp.toStringAsFixed(1)}°C",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            SizedBox(height: 4),
                            Flexible(
                              child: Text(
                                hour.description,
                                style: Theme.of(context).textTheme.bodySmall,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
