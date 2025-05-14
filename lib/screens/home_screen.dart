import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bitirme/screens/field/field_detail_screen.dart';
import 'package:flutter_bitirme/screens/field/field_list_screen.dart';
import 'package:flutter_bitirme/screens/field/field_screen.dart';
import 'package:flutter_bitirme/screens/sensor/sensor_graph_preview.dart';
import 'package:flutter_bitirme/screens/settings_screen.dart';
import 'sensor/sensor_graph_screen.dart';
import 'auth_screen.dart';

import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _userName;
  bool _isLoading = true;
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('Kullanicilar')
            .doc(user.uid)
            .get();

        if (doc.exists && mounted) {
          setState(() {
            _userName = doc.data()?['name'] as String?;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => AuthScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Çıkış yapılırken bir hata oluştu')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.directions_car,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(width: 8),
            Text('Ana Ekran'),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: AppTheme.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hoş geldin, ${_userName ?? "Kullanıcı"}!',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FieldScreen(
                                  fieldId: '',
                                ),
                              ),
                            );
                          },
                          icon: Icon(Icons.add),
                          label: Text('Tarla Ekle'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FieldListScreen(),
                              ),
                            );
                          },
                          icon: Icon(Icons.list),
                          label: Text('Tarlalarım'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("Tarlalar")
                        .where("Kullanici_id", isEqualTo: user?.uid)
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
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.5),
                              ),
                              SizedBox(height: 16),
                              Text(
                                "Henüz tarlanız yok.",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Yeni bir tarla eklemek için yukarıdaki butonu kullanın.",
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var doc = snapshot.data!.docs[index];
                          var field = doc.data() as Map<String, dynamic>;
                          String fieldId = doc.id;

                          return Card(
                            margin: EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: AppTheme.cardPadding,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              FieldDetailScreen(
                                                  fieldId: fieldId),
                                        ),
                                      );
                                    },
                                    child: ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Text(
                                        field["Tarla_ismi"] ??
                                            "Bilinmeyen Tarla",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                      subtitle: Text(
                                        "Konum: ${field['Konum']} - Alan: ${field['Boyut']}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                      trailing: Icon(Icons.arrow_forward_ios),
                                    ),
                                  ),
                                  FutureBuilder<QuerySnapshot>(
                                    future: FirebaseFirestore.instance
                                        .collection("Sensorler")
                                        .where("Tarla_id", isEqualTo: fieldId)
                                        .get(),
                                    builder: (context, sensorSnapshot) {
                                      if (sensorSnapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Center(
                                              child:
                                                  CircularProgressIndicator()),
                                        );
                                      }
                                      if (!sensorSnapshot.hasData ||
                                          sensorSnapshot.data!.docs.isEmpty) {
                                        return Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Center(
                                            child: Text(
                                              "Sensör bulunamadı.",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                            ),
                                          ),
                                        );
                                      }

                                      String sensorId =
                                          sensorSnapshot.data!.docs.first.id;
                                      var sensorData =
                                          sensorSnapshot.data!.docs.first.data()
                                              as Map<String, dynamic>;

                                      return Column(
                                        children: [
                                          Divider(),
                                          SensorGraphPreview(
                                            sensorId: sensorId,
                                            sensorName:
                                                sensorData['Sensor_adi'] ??
                                                    'Bilinmeyen Sensör',
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
