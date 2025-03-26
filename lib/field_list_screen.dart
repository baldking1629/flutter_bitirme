import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FieldListScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tarlalarım")),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection("Tarlalar").where('Kullanici_id', isEqualTo: _auth.currentUser!.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("Henüz bir tarlanız yok."));
          }
          return ListView(
            children: snapshot.data!.docs.map((doc) {
              Map<String, dynamic> field = doc.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(field['Tarla_ismi']),
                subtitle: Text("Konum: ${field['Konum']} - Alan: ${field['Boyut']} hektar"),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
