import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'sensor_graph_screen.dart';
import 'field_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ana Sayfa"),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Tarlalar")
            .where("Kullanici_id", isEqualTo: user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("Henüz tarlanız yok."));
          }
      
          return ListView(
            padding: EdgeInsets.all(10),
            children: snapshot.data!.docs.map((doc) {
              var field = doc.data() as Map<String, dynamic>;
              String fieldId = doc.id;
                
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                margin: EdgeInsets.symmetric(vertical: 8),
                elevation: 4,
                child: Column(
                  children: [
                    ListTile(
                      title: Text(field["Tarla_ismi"] ?? "Bilinmeyen Tarla"),
                      subtitle: Text("Konum: ${field['Konum']} - Alan: ${field['Boyut']} hektar"),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FieldDetailScreen(fieldId: fieldId),
                          ),
                        );
                      },
                    ),
                    FutureBuilder<QuerySnapshot>(
                      future: FirebaseFirestore.instance
                          .collection("Sensorler")
                          .where("Tarla_id", isEqualTo: fieldId)
                          .get(),
                      builder: (context, sensorSnapshot) {
                        if (sensorSnapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (!sensorSnapshot.hasData || sensorSnapshot.data!.docs.isEmpty) {
                          return Center(child: Text("Sensör bulunamadı."));
                        }
              
                        String sensorId = sensorSnapshot.data!.docs.first.id;
              
                        return SizedBox(
                          height: 200,
                          child: SensorGraphScreen(sensorId: sensorId),
                        );
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
