import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'sensor_graph_screen.dart';
import 'field_detail_screen.dart';
import 'field_screen.dart';
import 'field_list_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  String userName = "Kullanıcı"; // Varsayılan isim

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  // 📌 Firestore'dan kullanıcı adını al
  Future<void> _fetchUserName() async {
    if (user != null) {
      var userDoc = await FirebaseFirestore.instance.collection("Kullanicilar").doc(user!.uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        setState(() {
          userName = userDoc.data()!["Ad"] ?? "Kullanıcı";
        });
      }
    }
  }

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
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Hoş Geldiniz, $userName!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => FieldScreen()));
                      },
                      icon: Icon(Icons.add),
                      label: Text("Tarla Ekle"),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => FieldListScreen()));
                      },
                      icon: Icon(Icons.list),
                      label: Text("Tarlaları Listele"),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
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
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                  return Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Center(child: CircularProgressIndicator()),
                                  );
                                }
                                if (!sensorSnapshot.hasData || sensorSnapshot.data!.docs.isEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Center(child: Text("Sensör bulunamadı.")),
                                  );
                                }

                                String sensorId = sensorSnapshot.data!.docs.first.id;

                                return Column(
                                  children: [
                                    Divider(),
                                    SensorGraphScreen(sensorId: sensorId), // Otomatik boyutlanan grafik
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
