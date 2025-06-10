import 'package:flutter/material.dart';
import 'package:flutter_bitirme/models/irrigation_advice_model.dart';
import '../models/weather_model.dart';
import '../models/irrigation_model.dart';
import 'weather_card.dart';
import '../screens/sensor/sensor_graph_screen.dart';
import '../screens/field/field_detail_screen.dart';
import '../screens/sulama_gecmisi_screen.dart';
import '../services/gemini_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/sulama_kaydi_provider.dart';

class FieldCard extends StatefulWidget {
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
  State<FieldCard> createState() => _FieldCardState();
}

class _FieldCardState extends State<FieldCard> {
  @override
  void initState() {
    super.initState();
    // Tarla için sulama kayıtlarını dinlemeye başla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SulamaKaydiProvider>(context, listen: false)
          .tarlaSulamaKayitlariniDinle(widget.fieldId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // En güncel sensör verisini bul (timestamp'e göre)
    Map<String, dynamic>? lastSensor;
    if (widget.sensors.isNotEmpty) {
      widget.sensors.sort((a, b) {
        final aTime = a['timestamp'] as DateTime?;
        final bTime = b['timestamp'] as DateTime?;
        if (aTime == null || bTime == null) return 0;
        return bTime.compareTo(aTime);
      });
      lastSensor = widget.sensors.first;
    }

    // Sulama modeli için gerekli verileri hazırla
    final humidity = widget.weather?.humidity ?? 50.0;
    final temperature = widget.weather?.temperature ?? 20.0;
    final soilMoisture = lastSensor?['value'] as double? ?? 50.0;
    final isRaining = widget.weather?.isRaining ?? false;

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
                        widget.fieldName,
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.location,
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
                      cropType: widget.mahsul,
                      hasSensor: widget.sensors.isNotEmpty,
                      area: widget.area,
                    );

                    if (!context.mounted) return;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FieldDetailScreen(
                          fieldId: widget.fieldId,
                          irrigationAdvice: advice,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (widget.weather != null) WeatherCard(weather: widget.weather!),
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
                cropType: widget.mahsul,
                hasSensor: widget.sensors.isNotEmpty,
                area: widget.area,
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

                final advice = snapshot.data!;
                final suMiktariStr = advice.suMiktari;
                final sulamaGerekiyor =
                    advice.sulamaGerekiyorMu.toLowerCase().contains('evet') ||
                        advice.sulamaGerekiyorMu
                            .toLowerCase()
                            .contains('gerekiyor');

                double? litre;
                if (double.tryParse(suMiktariStr) != null) {
                  litre = double.tryParse(suMiktariStr);
                }
                // Devam eden sulama kaydı kontrolü
                final sulamaProvider =
                    Provider.of<SulamaKaydiProvider>(context, listen: false);
                final devamEdenKayitVar = sulamaProvider
                        .sulamaKayitlari.isNotEmpty &&
                    sulamaProvider.sulamaKayitlari.first.tamamlandiMi == false;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
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
                            advice.sulamaGerekiyorMu,
                            style: theme.textTheme.bodyMedium,
                          ),
                          if (advice.suMiktari.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Text(
                                  'Önerilen Su Miktarı: ${advice.suMiktari}',
                                  style: theme.textTheme.bodyMedium),
                            ),
                        ],
                      ),
                    ),
                    if (sulamaGerekiyor &&
                        litre != null &&
                        litre > 0 &&
                        !devamEdenKayitVar)
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 8.0, left: 2.0, right: 2.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            width: 260,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.add_task),
                              label:
                                  const Text('Sulama kaydı oluşturulsun mu?'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 8),
                                textStyle: theme.textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () async {
                                final saniye = (litre! * 60).round();
                                final provider =
                                    Provider.of<SulamaKaydiProvider>(context,
                                        listen: false);
                                final onay = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Otomatik Sulama Kaydı'),
                                    content: Text(
                                        'Bu tarlaya $litre litre su için $saniye saniyelik sulama kaydı oluşturulsun mu?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Hayır'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Evet'),
                                      ),
                                    ],
                                  ),
                                );
                                if (onay == true) {
                                  await provider.yeniSulamaKaydiEkle(
                                      widget.fieldId, saniye);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Sulama kaydı başarıyla oluşturuldu!')),
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            ChangeNotifierProvider(
              create: (_) {
                final provider = SulamaKaydiProvider();
                provider.tarlaSulamaKayitlariniDinle(widget.fieldId);
                return provider;
              },
              child: Consumer<SulamaKaydiProvider>(
                builder: (context, provider, child) {
                  if (provider.yukleniyor) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (provider.hata != null) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.dark
                            ? Colors.red.shade900.withOpacity(0.2)
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Hata: ${provider.hata}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.red,
                        ),
                      ),
                    );
                  }

                  if (provider.sulamaKayitlari.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.dark
                            ? Colors.orange.shade900.withOpacity(0.2)
                            : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.history,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Son Sulama',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Henüz sulama kaydı yok',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    );
                  }

                  final sonKayit = provider.sulamaKayitlari.first;
                  final tarih = DateFormat('dd.MM.yyyy HH:mm')
                      .format(sonKayit.tarih.toDate());
                  final durum =
                      sonKayit.tamamlandiMi ? 'Tamamlandı' : 'Devam Ediyor';
                  final durumIcon = sonKayit.tamamlandiMi
                      ? Icons.check_circle
                      : Icons.hourglass_empty;
                  final durumColor =
                      sonKayit.tamamlandiMi ? Colors.green : Colors.orange;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SulamaGecmisiScreen(
                            tarlaId: widget.fieldId,
                            tarlaAdi: widget.fieldName,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 14),
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.dark
                            ? Colors.green.shade900.withOpacity(0.18)
                            : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.10),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.history,
                              color: theme.colorScheme.primary, size: 28),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Son Sulama',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Süre: ${sonKayit.sulamaZamani} saniye',
                                  style: theme.textTheme.bodyMedium,
                                ),
                                Text(
                                  'Tarih: $tarih',
                                  style: theme.textTheme.bodyMedium,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                durumIcon,
                                color: durumColor,
                                size: 28,
                              ),
                              Text(
                                durum,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: durumColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
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
      ),
    );
  }
}
