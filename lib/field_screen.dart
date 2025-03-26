import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
            TextField(controller: _locationController, decoration: InputDecoration(labelText: "Konum")),
            TextField(controller: _sizeController, decoration: InputDecoration(labelText: "Alan (hektar)")),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _addField, child: Text("Ekle")),
          ],
        ),
      ),
    );
  }
}
