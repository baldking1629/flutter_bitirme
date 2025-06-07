class WeatherForecastHour {
  final DateTime dateTime;
  final double temp;
  final String description;
  final String icon;

  WeatherForecastHour({
    required this.dateTime,
    required this.temp,
    required this.description,
    required this.icon,
  });

  factory WeatherForecastHour.fromJson(Map<String, dynamic> json) {
    return WeatherForecastHour(
      dateTime: DateTime.fromMillisecondsSinceEpoch(json["dt"] * 1000),
      temp: json["main"]["temp"].toDouble(),
      description: json["weather"][0]["description"],
      icon: json["weather"][0]["icon"],
    );
  }
}

class WeatherForecastDay {
  final DateTime date;
  final List<WeatherForecastHour> hours;

  WeatherForecastDay({required this.date, required this.hours});
}

List<WeatherForecastDay> groupForecastByDay(List<dynamic> forecastList) {
  Map<String, List<WeatherForecastHour>> grouped = {};
  for (var item in forecastList) {
    final hour = WeatherForecastHour.fromJson(item);
    final dayKey =
        "${hour.dateTime.year}-${hour.dateTime.month}-${hour.dateTime.day}";
    grouped.putIfAbsent(dayKey, () => []);
    grouped[dayKey]!.add(hour);
  }
  return grouped.entries.map((e) {
    return WeatherForecastDay(
      date: e.value.first.dateTime,
      hours: e.value,
    );
  }).toList();
}
