import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bitirme/theme/app_theme.dart';

class SensorEditScreen extends StatefulWidget {
  final String tarlaId;
  final String? sensorId; // Eğer null ise yeni sensör ekleniyor

  SensorEditScreen({required this.tarlaId, this.sensorId});

  @override
  _SensorEditScreenState createState() => _SensorEditScreenState();
}

class _SensorEditScreenState extends State<SensorEditScreen> {
  final TextEditingController _sensorAdiController = TextEditingController();
  final TextEditingController _sensorTipiController = TextEditingController();
  final TextEditingController _konumController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.sensorId != null) {
      _loadSensorDetails();
    }
  }

  void _loadSensorDetails() async {
    setState(() => isLoading = true);
    DocumentSnapshot doc =
        await _firestore.collection('Sensorler').doc(widget.sensorId).get();
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    _sensorAdiController.text = data['Sensor_adi'] ?? "";
    _sensorTipiController.text = data['Sensor_tipi'] ?? "";
    _konumController.text = data['Konum'] ?? "";
    setState(() => isLoading = false);
  }

  void _saveSensor() async {
    String sensorAdi = _sensorAdiController.text.trim();
    String sensorTipi = _sensorTipiController.text.trim();
    String konum = _konumController.text.trim();

    if (sensorAdi.isEmpty || sensorTipi.isEmpty || konum.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen tüm alanları doldurun')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      if (widget.sensorId != null) {
        await _firestore.collection('Sensorler').doc(widget.sensorId).update({
          'Sensor_adi': sensorAdi,
          'Sensor_tipi': sensorTipi,
          'Konum': konum,
          'Guncelleme_tarihi': FieldValue.serverTimestamp(),
        });
      } else {
        await _firestore.collection('Sensorler').add({
          'Tarla_id': widget.tarlaId,
          'Sensor_adi': sensorAdi,
          'Sensor_tipi': sensorTipi,
          'Konum': konum,
          'Olusturulma_tarihi': FieldValue.serverTimestamp(),
        });
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(widget.sensorId != null
                  ? 'Sensör güncellendi'
                  : 'Sensör eklendi')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bir hata oluştu')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sensorId != null ? 'Sensör Düzenle' : 'Sensör Ekle'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: AppTheme.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: AppTheme.cardPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sensör Bilgileri',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 24),
                    TextFormField(
                      controller: _sensorAdiController,
                      decoration: InputDecoration(
                        labelText: 'Sensör Adı',
                        prefixIcon: Icon(Icons.sensors),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _sensorTipiController,
                      decoration: InputDecoration(
                        labelText: 'Sensör Tipi',
                        prefixIcon: Icon(Icons.category),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _konumController,
                      decoration: InputDecoration(
                        labelText: 'Konum',
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: isLoading ? null : _saveSensor,
                      icon: Icon(
                          widget.sensorId != null ? Icons.save : Icons.add),
                      label: Text(
                          widget.sensorId != null ? 'Kaydet' : 'Sensör Ekle'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _sensorAdiController.dispose();
    _sensorTipiController.dispose();
    _konumController.dispose();
    super.dispose();
  }
}
