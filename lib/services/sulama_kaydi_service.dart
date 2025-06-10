import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sulama_kaydi.dart';

class SulamaKaydiService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'Sulama_kayitlari';

  // Yeni sulama kaydı ekleme
  Future<void> yeniSulamaKaydiEkle(SulamaKaydi kayit) async {
    print('Firestore\'a kayıt ekleniyor: ${kayit.toMap()}');
    // Önce tarla için son kaydı kontrol et
    final sonKayit = await _firestore
        .collection(_collectionName)
        .where('Tarla_id', isEqualTo: kayit.tarlaId)
        .orderBy('Tarih', descending: true)
        .limit(1)
        .get();

    print('Son kayıt kontrolü: ${sonKayit.docs.length} kayıt bulundu');

    // Eğer son kayıt varsa ve tamamlanmamışsa, yeni kayıt ekleme
    if (sonKayit.docs.isNotEmpty) {
      final sonKayitData = sonKayit.docs.first.data();
      print('Son kayıt durumu: ${sonKayitData['Tamamlandi_mi']}');
      if (sonKayitData['Tamamlandi_mi'] == false) {
        throw Exception('Bu tarla için zaten devam eden bir sulama kaydı var!');
      }
    }

    // Yeni kaydı ekle
    await _firestore.collection(_collectionName).add(kayit.toMap());
    print('Yeni kayıt başarıyla eklendi');
  }

  // Sulama kaydını tamamlandı olarak işaretle
  Future<void> sulamaKaydiniTamamla(String kayitId) async {
    print('Kayıt tamamlanıyor: $kayitId');
    await _firestore
        .collection(_collectionName)
        .doc(kayitId)
        .update({'Tamamlandi_mi': true});
    print('Kayıt başarıyla tamamlandı');
  }

  // Tarla için son sulama kaydını getir
  Future<SulamaKaydi?> sonSulamaKaydiniGetir(String tarlaId) async {
    print('Son kayıt getiriliyor: $tarlaId');
    final sonKayit = await _firestore
        .collection(_collectionName)
        .where('Tarla_id', isEqualTo: tarlaId)
        .orderBy('Tarih', descending: true)
        .limit(1)
        .get();

    print('Son kayıt sorgusu sonucu: ${sonKayit.docs.length} kayıt bulundu');

    if (sonKayit.docs.isEmpty) {
      print('Kayıt bulunamadı');
      return null;
    }

    final kayit = SulamaKaydi.fromMap(sonKayit.docs.first.data());
    print('Son kayıt: ${kayit.toMap()}');
    return kayit;
  }

  // Tarla için tüm sulama kayıtlarını getir
  Stream<List<SulamaKaydi>> tarlaSulamaKayitlariniGetir(String tarlaId) {
    print('Tarla kayıtları stream\'i başlatılıyor: $tarlaId');
    return _firestore
        .collection(_collectionName)
        .where('Tarla_id', isEqualTo: tarlaId)
        .orderBy('Tarih', descending: true)
        .snapshots()
        .map((snapshot) {
      print('Stream\'den ${snapshot.docs.length} kayıt alındı');
      return snapshot.docs
          .map((doc) => SulamaKaydi.fromMap(doc.data()))
          .toList();
    });
  }
}
