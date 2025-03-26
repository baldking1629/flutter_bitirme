import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'field_screen.dart';
import 'field_list_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Kullanıcı bilgilerini Firestore'dan çek
  }

  Future<void> _fetchUserData() async {
    if (user != null) {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('Kullanicilar').doc(user!.uid).get();

      if (userDoc.exists) {
        setState(() {
          userData = userDoc.data() as Map<String, dynamic>?;
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
      body: Center(
        child: userData == null
            ? CircularProgressIndicator() // Veriler yüklenene kadar gösterilecek loading animasyonu
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (userData!['photoUrl'] != null)
                    CircleAvatar(
                      backgroundImage: NetworkImage(userData!['photoUrl']),
                      radius: 40,
                    ),
                  SizedBox(height: 10),
                  Text("Hoşgeldin, ${userData!['name'] ?? "Kullanıcı"}"),
                  Text("E-posta: ${userData!['email']}"),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => FieldScreen()));
                    },
                    child: Text("Tarla Ekle"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => FieldListScreen()));
                    },
                    child: Text("Tarlalarımı Görüntüle"),
                  ),
                ],
              ),
      ),
    );
  }
}
