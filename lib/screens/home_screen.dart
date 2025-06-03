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
import 'package:flutter_bitirme/services/weather_service.dart';
import 'package:flutter_bitirme/widgets/weather_card.dart';
import 'package:flutter_bitirme/widgets/field_card.dart';

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

  String _formatLocation(String location) {
    if (location.length <= 30) return location;

    List<String> parts = location.split(' - ');
    if (parts.length <= 2) return location;

    // İlk iki parçayı al ve diğerlerini kısalt
    String result = '${parts[0]} - ${parts[1]}';
    if (parts.length > 2) {
      result += ' ...';
    }
    return result;
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

                          // Sensör verilerini çekmek için FutureBuilder
                          return FutureBuilder<QuerySnapshot>(
                            future: FirebaseFirestore.instance
                                .collection("Sensorler")
                                .where("Tarla_id", isEqualTo: fieldId)
                                .get(),
                            builder: (context, sensorSnapshot) {
                              List<Map<String, dynamic>> sensorList = [];
                              if (sensorSnapshot.hasData) {
                                sensorList =
                                    sensorSnapshot.data!.docs.map((sDoc) {
                                  var s = sDoc.data() as Map<String, dynamic>;
                                  return {
                                    'id': sDoc.id,
                                    'name': s['Sensor_adi'] ?? 'Sensör',
                                    'value': s['Deger']?.toString() ?? '-',
                                    'icon': Icons.sensors,
                                  };
                                }).toList();
                              }

                              // Hava durumu için FutureBuilder
                              if (field['Enlem'] != null &&
                                  field['Boylam'] != null) {
                                return FutureBuilder(
                                  future: WeatherService().getWeatherByLocation(
                                    double.parse(field['Enlem']),
                                    double.parse(field['Boylam']),
                                  ),
                                  builder: (context, weatherSnapshot) {
                                    return FieldCard(
                                      fieldId: fieldId,
                                      fieldName: field["Tarla_ismi"] ??
                                          "Bilinmeyen Tarla",
                                      location: field["Konum"] ?? "",
                                      area: field["Boyut"] ?? "",
                                      weather: weatherSnapshot.data,
                                      sensors: sensorList,
                                    );
                                  },
                                );
                              } else {
                                return FieldCard(
                                  fieldId: fieldId,
                                  fieldName:
                                      field["Tarla_ismi"] ?? "Bilinmeyen Tarla",
                                  location: field["Konum"] ?? "",
                                  area: field["Boyut"] ?? "",
                                  weather: null,
                                  sensors: sensorList,
                                );
                              }
                            },
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
