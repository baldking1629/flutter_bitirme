import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bitirme/theme/app_theme.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'field_list_screen.dart';

class FieldScreen extends StatefulWidget {
  final String? fieldId;

  const FieldScreen({Key? key, this.fieldId}) : super(key: key);

  @override
  _FieldScreenState createState() => _FieldScreenState();
}

class _FieldScreenState extends State<FieldScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _sizeController = TextEditingController();
  final _mahsulController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoadingLocation = false;
  bool _isEditing = false;
  String? _latitude;
  String? _longitude;
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.fieldId != null && widget.fieldId!.isNotEmpty;
    print("🔄 initState çağrıldı");
    print("fieldId: ${widget.fieldId}");
    print("_isEditing: $_isEditing");
    if (_isEditing) {
      _loadFieldDetails();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isFirstLoad &&
        _isEditing &&
        widget.fieldId != null &&
        widget.fieldId!.isNotEmpty) {
      _isFirstLoad = false;
      _loadFieldDetails();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _sizeController.dispose();
    _mahsulController.dispose();
    super.dispose();
  }

  Future<void> _loadFieldDetails() async {
    if (!mounted) return;

    print("🔍 Tarla detayları yükleniyor...");
    print("Tarla ID: ${widget.fieldId}");

    try {
      DocumentSnapshot doc =
          await _firestore.collection('Tarlalar').doc(widget.fieldId).get();

      print("📄 Firestore'dan veri alındı: ${doc.exists ? 'Var' : 'Yok'}");

      if (doc.exists && mounted) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        print("📋 Tarla verileri:");
        print("Tarla İsmi: ${data['Tarla_ismi']}");
        print("Konum: ${data['Konum']}");
        print("Boyut: ${data['Boyut']}");
        print("Enlem: ${data['Enlem']}");
        print("Boylam: ${data['Boylam']}");
        print("Mahsul: ${data['Mahsul']}");

        setState(() {
          _nameController.text = data['Tarla_ismi'] ?? '';
          _locationController.text = data['Konum'] ?? '';
          _sizeController.text = data['Boyut'] ?? '';
          _latitude = data['Enlem']?.toString();
          _longitude = data['Boylam']?.toString();
          _mahsulController.text = data['Mahsul'] ?? '';
        });
        print("✅ Tarla detayları yüklendi");
      } else {
        print("⚠️ Tarla bulunamadı");
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Tarla bulunamadı."),
                  backgroundColor: Colors.orange,
                ),
              );
              Navigator.pop(context);
            }
          });
        }
      }
    } catch (e) {
      if (!mounted) return;

      print("❌ Tarla bilgileri yüklenirken hata oluştu: $e");

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  "Tarla bilgileri yüklenirken bir hata oluştu: ${e.toString()}"),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.pop(context);
        }
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;

    setState(() {
      _isLoadingLocation = true;
    });

    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;

        setState(() {
          _isLoadingLocation = false;
        });

        // SnackBar'ı bir sonraki frame'de göster
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Konum izni reddedildi.")),
            );
          }
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;

      Placemark place = placemarks.first;
      String address =
          '${place.administrativeArea} / ${place.subAdministrativeArea} - ${place.locality} - ${place.thoroughfare} - ${place.street} -  ${place.country}';
      _latitude = position.latitude.toString();
      _longitude = position.longitude.toString();

      setState(() {
        _locationController.text = address;
        _isLoadingLocation = false;
      });
    } catch (e) {
      if (!mounted) return;

      print("❌ Konum alınırken hata oluştu: $e");
      setState(() {
        _isLoadingLocation = false;
      });

      // Hata SnackBar'ını bir sonraki frame'de göster
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Konum alınırken bir hata oluştu.")),
          );
        }
      });
    }
  }

  Future<void> _saveField() async {
    if (!mounted) return;

    String userId = _auth.currentUser!.uid;
    String name = _nameController.text.trim();
    String location = _locationController.text.trim();
    String size = _sizeController.text.trim();
    String mahsul = _mahsulController.text.trim();

    print("🔍 Kaydetme işlemi başladı:");
    print("Kullanıcı ID: $userId");
    print("Tarla Adı: $name");
    print("Konum: $location");
    print("Boyut: $size");
    print("Mahsul: $mahsul");
    print("Enlem: $_latitude");
    print("Boylam: $_longitude");
    print("Düzenleme Modu: $_isEditing");
    print("fieldId: ${widget.fieldId}");

    if (name.isNotEmpty && location.isNotEmpty && size.isNotEmpty) {
      try {
        if (_isEditing &&
            widget.fieldId != null &&
            widget.fieldId!.isNotEmpty) {
          print("📝 Tarla güncelleniyor...");
          await _firestore.collection("Tarlalar").doc(widget.fieldId).update({
            'Tarla_ismi': name,
            'Konum': location,
            'Boyut': size,
            'Enlem': _latitude,
            'Boylam': _longitude,
            'Mahsul': mahsul,
            'Guncelleme_tarihi': FieldValue.serverTimestamp(),
          });
          print("✅ Tarla güncellendi");
        } else {
          print("📝 Yeni tarla ekleniyor...");
          DocumentReference docRef =
              await _firestore.collection("Tarlalar").add({
            'Kullanici_id': userId,
            'Tarla_ismi': name,
            'Konum': location,
            'Boyut': size,
            'Enlem': _latitude,
            'Boylam': _longitude,
            'Mahsul': mahsul,
            'Olusturulma_tarihi': FieldValue.serverTimestamp(),
          });
          print("✅ Yeni tarla eklendi. ID: ${docRef.id}");
        }

        if (!mounted) return;

        // Önce SnackBar'ı göster, sonra sayfayı kapat
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text(_isEditing ? "Tarla güncellendi." : "Tarla eklendi."),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
        });
      } catch (e) {
        if (!mounted) return;

        print("❌ Tarla kaydedilirken hata oluştu: $e");

        // Hata SnackBar'ını bir sonraki frame'de göster
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    "Tarla kaydedilirken bir hata oluştu: ${e.toString()}"),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
      }
    } else {
      // Uyarı SnackBar'ını bir sonraki frame'de göster
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Lütfen tüm alanları doldurun."),
              backgroundColor: Colors.orange,
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? "Tarla Düzenle" : "Tarla Ekle"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: AppTheme.screenPadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: AppTheme.cardPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Tarla Bilgileri",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: "Tarla Adı",
                          prefixIcon: Icon(Icons.agriculture),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Lütfen tarla adını girin";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _sizeController,
                        decoration: InputDecoration(
                          labelText: "Alan (hektar)",
                          prefixIcon: Icon(Icons.crop_square),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Lütfen tarla alanını girin";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _mahsulController,
                        decoration: InputDecoration(
                          labelText: "Ekili Mahsul",
                          prefixIcon: Icon(Icons.grass),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Lütfen ekili mahsulü girin";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _locationController,
                              decoration: InputDecoration(
                                labelText: "Konum",
                                prefixIcon: Icon(Icons.location_on),
                              ),
                              readOnly: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Lütfen konum seçin";
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 8),
                          IconButton(
                            icon: _isLoadingLocation
                                ? SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Icon(Icons.my_location),
                            onPressed: _getCurrentLocation,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _saveField,
                icon: Icon(_isEditing ? Icons.save : Icons.add),
                label: Text(_isEditing ? "Kaydet" : "Tarla Ekle"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
