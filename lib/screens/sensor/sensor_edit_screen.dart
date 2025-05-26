import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bitirme/theme/app_theme.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

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
  String? _latitude;
  String? _longitude;

  String _formatAddress(String address) {
    if (address.length <= 30) return address;

    List<String> parts = address.split(' - ');
    if (parts.length <= 2) return address;

    // İlk iki parçayı al ve diğerlerini kısalt
    String result = '${parts[0]} - ${parts[1]}';
    if (parts.length > 2) {
      result += ' ...';
    }
    return result;
  }

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

  Future<void> _getCurrentLocation() async {
    setState(() => isLoading = true);
    try {
      // Konum izinlerini kontrol et
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Konum izni reddedildi')),
          );
          setState(() => isLoading = false);
          return;
        }
      }

      // Mevcut konumu al
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String fullAddress =
            '${place.administrativeArea} / ${place.locality} - ${place.thoroughfare} - ${place.street} - ${place.subAdministrativeArea} - ${place.country}';
        String shortAddress = _formatAddress(fullAddress);

        _konumController.text = shortAddress;
        _latitude = position.latitude.toString();
        _longitude = position.longitude.toString();

        // Tam adres bilgisini göster
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tam Adres:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    fullAddress,
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
              duration: Duration(seconds: 5),
            ),
          );
        }
      } else {
        _konumController.text = '${position.latitude}, ${position.longitude}';
        _latitude = position.latitude.toString();
        _longitude = position.longitude.toString();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Konum alınamadı: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
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
          'Enlem': _latitude,
          'Boylam': _longitude,
          'Guncelleme_tarihi': FieldValue.serverTimestamp(),
        });
      } else {
        await _firestore.collection('Sensorler').add({
          'Tarla_id': widget.tarlaId,
          'Sensor_adi': sensorAdi,
          'Sensor_tipi': sensorTipi,
          'Konum': konum,
          'Enlem': _latitude,
          'Boylam': _longitude,
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
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _konumController,
                            decoration: InputDecoration(
                              labelText: "Konum",
                              prefixIcon: Icon(Icons.location_on),
                            ),
                            readOnly: true,
                          ),
                        ),
                        SizedBox(width: 8),
                        IconButton(
                          icon: isLoading
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(Icons.my_location),
                          onPressed: _getCurrentLocation,
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: isLoading ? null : _saveSensor,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                              widget.sensorId != null ? Icons.save : Icons.add),
                          SizedBox(width: 8),
                          Text(widget.sensorId != null
                              ? 'Kaydet'
                              : 'Sensör Ekle'),
                        ],
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
