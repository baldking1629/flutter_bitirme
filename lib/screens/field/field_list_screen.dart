import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bitirme/theme/app_theme.dart';
import 'field_detail_screen.dart';

class FieldListScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tarlalarım"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection("Tarlalar")
            .where("Kullanici_id", isEqualTo: _auth.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.agriculture,
                    size: 64,
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Henüz tarlanız yok.",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Yeni bir tarla eklemek için ana sayfadaki butonu kullanın.",
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: AppTheme.screenPadding,
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var field = doc.data() as Map<String, dynamic>;
              String fieldId = doc.id;

              return Card(
                child: ListTile(
                  contentPadding: AppTheme.cardPadding,
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    child: Icon(
                      Icons.agriculture,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    field["Tarla_ismi"] ?? "Bilinmeyen Tarla",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Text(
                        "Konum: ${field['Konum']}",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        "Alan: ${field['Boyut']} hektar",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            FieldDetailScreen(fieldId: fieldId),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
