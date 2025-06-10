import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/sulama_kaydi_provider.dart';

class SulamaGecmisiScreen extends StatelessWidget {
  final String tarlaId;
  final String? tarlaAdi;
  const SulamaGecmisiScreen({Key? key, required this.tarlaId, this.tarlaAdi})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final provider = SulamaKaydiProvider();
        provider.tarlaSulamaKayitlariniDinle(tarlaId);
        return provider;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(tarlaAdi != null
              ? 'Sulama Geçmişi - $tarlaAdi'
              : 'Sulama Geçmişi'),
        ),
        body: Consumer<SulamaKaydiProvider>(
          builder: (context, provider, child) {
            if (provider.yukleniyor) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.hata != null) {
              return Center(child: Text('Hata: ${provider.hata}'));
            }
            if (provider.sulamaKayitlari.isEmpty) {
              return const Center(child: Text('Hiç sulama kaydı yok.'));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.sulamaKayitlari.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final kayit = provider.sulamaKayitlari[index];
                final tarih =
                    DateFormat('dd.MM.yyyy HH:mm').format(kayit.tarih.toDate());
                final durum =
                    kayit.tamamlandiMi ? 'Tamamlandı' : 'Devam Ediyor';
                final durumIcon = kayit.tamamlandiMi
                    ? Icons.check_circle
                    : Icons.hourglass_empty;
                final durumColor =
                    kayit.tamamlandiMi ? Colors.green : Colors.orange;
                return ListTile(
                  leading: Icon(durumIcon, color: durumColor),
                  title: Text('Süre: ${kayit.sulamaZamani} saniye'),
                  subtitle: Text('Tarih: $tarih'),
                  trailing: Text(
                    durum,
                    style: TextStyle(
                        color: durumColor, fontWeight: FontWeight.bold),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
