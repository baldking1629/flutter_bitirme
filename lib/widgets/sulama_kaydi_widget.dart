import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sulama_kaydi_provider.dart';

class SulamaKaydiWidget extends StatefulWidget {
  final String tarlaId;

  const SulamaKaydiWidget({
    Key? key,
    required this.tarlaId,
  }) : super(key: key);

  @override
  State<SulamaKaydiWidget> createState() => _SulamaKaydiWidgetState();
}

class _SulamaKaydiWidgetState extends State<SulamaKaydiWidget> {
  final TextEditingController _sulamaZamaniController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Tarla için sulama kayıtlarını dinlemeye başla
    Provider.of<SulamaKaydiProvider>(context, listen: false)
        .tarlaSulamaKayitlariniDinle(widget.tarlaId);
  }

  @override
  void dispose() {
    _sulamaZamaniController.dispose();
    super.dispose();
  }

  Future<void> _yeniSulamaKaydiEkle() async {
    final sulamaProvider =
        Provider.of<SulamaKaydiProvider>(context, listen: false);

    // Önce son kaydı kontrol et
    final sonKayitTamamlandi =
        await sulamaProvider.sonSulamaKaydiniKontrolEt(widget.tarlaId);

    if (!sonKayitTamamlandi) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bu tarla için zaten devam eden bir sulama kaydı var!'),
        ),
      );
      return;
    }

    final sulamaZamani = int.tryParse(_sulamaZamaniController.text);
    if (sulamaZamani == null || sulamaZamani <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Lütfen geçerli bir sulama süresi girin (saniye cinsinden)'),
        ),
      );
      return;
    }

    await sulamaProvider.yeniSulamaKaydiEkle(widget.tarlaId, sulamaZamani);
    _sulamaZamaniController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SulamaKaydiProvider>(
      builder: (context, provider, child) {
        if (provider.yukleniyor) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.hata != null) {
          return Center(
            child: Text('Hata: ${provider.hata}'),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _sulamaZamaniController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Sulama Süresi (saniye)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _yeniSulamaKaydiEkle,
                    child: const Text('Sulama Başlat'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: provider.sulamaKayitlari.length,
                itemBuilder: (context, index) {
                  final kayit = provider.sulamaKayitlari[index];
                  return ListTile(
                    title: Text('Sulama Süresi: ${kayit.sulamaZamani} saniye'),
                    subtitle: Text(
                      'Tarih: ${kayit.tarih.toDate().toString()}\n'
                      'Durum: ${kayit.tamamlandiMi ? "Tamamlandı" : "Devam Ediyor"}',
                    ),
                    trailing: kayit.tamamlandiMi
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.hourglass_empty,
                            color: Colors.orange),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
