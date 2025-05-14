import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    DocumentSnapshot doc = await _firestore.collection('Sensorler').doc(widget.sensorId).get();
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

    if (sensorAdi.isEmpty || sensorTipi.isEmpty || konum.isEmpty) return;

    setState(() => isLoading = true);

    if (widget.sensorId == null) {
      // Yeni sensör ekle
      await _firestore.collection("Sensorler").add({
        'Tarla_id': widget.tarlaId,
        'Sensor_adi': sensorAdi,
        'Sensor_tipi': sensorTipi,
        'Konum': konum,
        'Olusturulma_tarihi': FieldValue.serverTimestamp(),
      });
    } else {
      // Mevcut sensörü güncelle
      await _firestore.collection("Sensorler").doc(widget.sensorId).update({
        'Sensor_adi': sensorAdi,
        'Sensor_tipi': sensorTipi,
        'Konum': konum,
      });
    }

    setState(() => isLoading = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.sensorId == null ? "Yeni Sensör Ekle" : "Sensörü Düzenle")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  TextField(controller: _sensorAdiController, decoration: InputDecoration(labelText: "Sensör Adı")),
                  TextField(controller: _sensorTipiController, decoration: InputDecoration(labelText: "Sensör Tipi")),
                  TextField(controller: _konumController, decoration: InputDecoration(labelText: "Konum")),
                  SizedBox(height: 20),
                  ElevatedButton(onPressed: _saveSensor, child: Text("Kaydet")),
                ],
              ),
            ),
    );
  }
}
