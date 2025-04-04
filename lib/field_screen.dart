import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'field_list_screen.dart';

class FieldScreen extends StatefulWidget {
  @override
  _FieldScreenState createState() => _FieldScreenState();
}

class _FieldScreenState extends State<FieldScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoadingLocation = false; // Konum yükleniyor göstergesi

  // 📌 Cihazın mevcut konumunu al ve adrese çevir
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // 📍 Kullanıcıdan konum izni al
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoadingLocation = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Konum izni reddedildi.")));
        return;
      }

      // 📍 Konumu al
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      // 📍 Konumu adrese çevir
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks.first;
      String address = "${place.locality}, ${place.administrativeArea}";

      // 📍 Konum alanına yaz
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

  // 📌 Firestore'a tarla ekle
  void _addField() async {
    String userId = _auth.currentUser!.uid;
    String name = _nameController.text.trim();
    String location = _locationController.text.trim();
    String size = _sizeController.text.trim();

    if (name.isNotEmpty && location.isNotEmpty && size.isNotEmpty) {
      try {
        await _firestore.collection("Tarlalar").add({
          'Kullanici_id': userId,
          'Tarla_ismi': name,
          'Konum': location,
          'Boyut': size,
          'Olusturulma_tarihi': FieldValue.serverTimestamp(),
        });

        // Başarıyla eklendiyse tarlalar listesine yönlendir
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FieldListScreen()),
        );
      } catch (e) {
        print("❌ Tarla eklenirken hata oluştu: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tarla Ekle")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: InputDecoration(labelText: "Tarla Adı")),
            TextField(controller: _sizeController, decoration: InputDecoration(labelText: "Alan (hektar)")),
            Row(
              children: [
                Expanded(
                  child: TextField(controller: _locationController, decoration: InputDecoration(labelText: "Konum"), readOnly: true),
                ),
                IconButton(
                  icon: _isLoadingLocation ? CircularProgressIndicator() : Icon(Icons.my_location),
                  onPressed: _getCurrentLocation,
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _addField, child: Text("Ekle")),
          ],
        ),
      ),
    );
  }
}
