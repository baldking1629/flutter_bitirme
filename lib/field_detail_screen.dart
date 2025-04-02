import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'sensor_list_screen.dart';

class FieldDetailScreen extends StatefulWidget {
  final String fieldId;

  FieldDetailScreen({required this.fieldId});

  @override
  _FieldDetailScreenState createState() => _FieldDetailScreenState();
}

class _FieldDetailScreenState extends State<FieldDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  TextEditingController _sizeController = TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFieldDetails();
  }

  void _loadFieldDetails() async {
    DocumentSnapshot doc =
        await _firestore.collection('Tarlalar').doc(widget.fieldId).get();
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    setState(() {
      _nameController.text = data['Tarla_ismi'];
      _locationController.text = data['Konum'];
      _sizeController.text = data['Boyut'];
      isLoading = false;
    });
  }

  void _updateField() async {
    await _firestore.collection('Tarlalar').doc(widget.fieldId).update({
      'Tarla_ismi': _nameController.text,
      'Konum': _locationController.text,
      'Boyut': _sizeController.text,
    });
    Navigator.pop(context);
  }

  void _deleteField() async {
    await _firestore.collection('Tarlalar').doc(widget.fieldId).delete();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tarla Detayı")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  TextField(controller: _nameController, decoration: InputDecoration(labelText: "Tarla Adı")),
                  TextField(controller: _locationController, decoration: InputDecoration(labelText: "Konum")),
                  TextField(controller: _sizeController, decoration: InputDecoration(labelText: "Alan (hektar)")),
                  SizedBox(height: 20),
                  ElevatedButton(onPressed: _updateField, child: Text("Güncelle")),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _deleteField,
                    child: Text("Sil"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SensorListScreen(fieldId: widget.fieldId)),
                      );
                    },
                    child: Text("Sensörleri Görüntüle"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  ),
                ],
              ),
            ),
    );
  }
}
