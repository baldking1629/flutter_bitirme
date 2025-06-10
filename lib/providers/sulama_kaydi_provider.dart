import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sulama_kaydi.dart';
import '../services/sulama_kaydi_service.dart';

class SulamaKaydiProvider with ChangeNotifier {
  final SulamaKaydiService _sulamaService = SulamaKaydiService();
  List<SulamaKaydi> _sulamaKayitlari = [];
  bool _yukleniyor = false;
  String? _hata;

  List<SulamaKaydi> get sulamaKayitlari => _sulamaKayitlari;
  bool get yukleniyor => _yukleniyor;
  String? get hata => _hata;

  // Tarla için sulama kayıtlarını dinle
  void tarlaSulamaKayitlariniDinle(String tarlaId) {
    print('Sulama kayıtları dinleniyor: $tarlaId');
    _yukleniyor = true;
    _hata = null;
    notifyListeners();

    _sulamaService.tarlaSulamaKayitlariniGetir(tarlaId).listen(
      (kayitlar) {
        print('Sulama kayıtları alındı: ${kayitlar.length} kayıt');
        _sulamaKayitlari = kayitlar;
        _yukleniyor = false;
        notifyListeners();
      },
      onError: (error) {
        print('Sulama kayıtları alınırken hata: $error');
        _hata = error.toString();
        _yukleniyor = false;
        notifyListeners();
      },
    );
  }

  // Yeni sulama kaydı ekle
  Future<void> yeniSulamaKaydiEkle(String tarlaId, int sulamaZamani) async {
    try {
      print(
          'Yeni sulama kaydı ekleniyor: Tarla: $tarlaId, Süre: $sulamaZamani');
      _yukleniyor = true;
      _hata = null;
      notifyListeners();

      final yeniKayit = SulamaKaydi(
        tarlaId: tarlaId,
        sulamaZamani: sulamaZamani,
        tamamlandiMi: false,
        tarih: Timestamp.now(),
      );

      await _sulamaService.yeniSulamaKaydiEkle(yeniKayit);
      print('Sulama kaydı başarıyla eklendi');

      _yukleniyor = false;
      notifyListeners();
    } catch (e) {
      print('Sulama kaydı eklenirken hata: $e');
      _hata = e.toString();
      _yukleniyor = false;
      notifyListeners();
    }
  }

  // Son sulama kaydını kontrol et
  Future<bool> sonSulamaKaydiniKontrolEt(String tarlaId) async {
    try {
      print('Son sulama kaydı kontrol ediliyor: $tarlaId');
      final sonKayit = await _sulamaService.sonSulamaKaydiniGetir(tarlaId);
      print('Son kayıt durumu: ${sonKayit?.tamamlandiMi}');
      return sonKayit?.tamamlandiMi ?? true;
    } catch (e) {
      print('Son kayıt kontrol edilirken hata: $e');
      _hata = e.toString();
      notifyListeners();
      return false;
    }
  }
}
