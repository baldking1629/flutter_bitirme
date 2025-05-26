import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bitirme/theme/app_theme.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'field_list_screen.dart';

class FieldScreen extends StatefulWidget {
  final String? fieldId;

  const FieldScreen({Key? key, this.fieldId}) : super(key: key);

  @override
  _FieldScreenState createState() => _FieldScreenState();
}

class _FieldScreenState extends State<FieldScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoadingLocation = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.fieldId != null;
    if (_isEditing) {
      _loadFieldDetails();
    }
  }

  Future<void> _loadFieldDetails() async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('Tarlalar').doc(widget.fieldId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        setState(() {
          _nameController.text = data['Tarla_ismi'] ?? '';
          _locationController.text = data['Konum'] ?? '';
          _sizeController.text = data['Boyut'] ?? '';
        });
      }
    } catch (e) {
      print("❌ Tarla bilgileri yüklenirken hata oluştu: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Tarla bilgileri yüklenirken bir hata oluştu.")),
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoadingLocation = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Konum izni reddedildi.")),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      Placemark place = placemarks.first;
      String address = "${place.locality}, ${place.administrativeArea}";
      
      setState(() {
        _locationController.text = address;
        _isLoadingLocation = false;
      });
    } catch (e) {
      print("❌ Konum alınırken hata oluştu: $e");
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _saveField() async {
    String userId = _auth.currentUser!.uid;
    String name = _nameController.text.trim();
    String location = _locationController.text.trim();
    String size = _sizeController.text.trim();

    if (name.isNotEmpty && location.isNotEmpty && size.isNotEmpty) {
      try {
        if (_isEditing) {
          await _firestore.collection("Tarlalar").doc(widget.fieldId).update({
            'Tarla_ismi': name,
            'Konum': location,
            'Boyut': size,
            'Guncelleme_tarihi': FieldValue.serverTimestamp(),
          });
        } else {
          await _firestore.collection("Tarlalar").add({
            'Kullanici_id': userId,
            'Tarla_ismi': name,
            'Konum': location,
            'Boyut': size,
            'Olusturulma_tarihi': FieldValue.serverTimestamp(),
          });
        }

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? "Tarla güncellendi." : "Tarla eklendi."),
          ),
        );
      } catch (e) {
        print("❌ Tarla kaydedilirken hata oluştu: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Tarla kaydedilirken bir hata oluştu.")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lütfen tüm alanları doldurun.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? "Tarla Düzenle" : "Tarla Ekle"),
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
                      "Tarla Bilgileri",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: "Tarla Adı",
                        prefixIcon: Icon(Icons.agriculture),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _sizeController,
                      decoration: InputDecoration(
                        labelText: "Alan (hektar)",
                        prefixIcon: Icon(Icons.crop_square),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _locationController,
                            decoration: InputDecoration(
                              labelText: "Konum",
                              prefixIcon: Icon(Icons.location_on),
                            ),
                            readOnly: true,
                          ),
                        ),
                        SizedBox(width: 8),
                        IconButton(
                          icon: _isLoadingLocation
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
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _saveField,
              icon: Icon(_isEditing ? Icons.save : Icons.add),
              label: Text(_isEditing ? "Kaydet" : "Tarla Ekle"),
            ),
          ],
        ),
      ),
    );
  }
}
