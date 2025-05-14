import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String name;
  final String? surname;
  final String email;
  final String? photoUrl;
  final Timestamp olusturulmaTarihi;
  final Timestamp? guncellenmeTarihi;

  UserModel({
    required this.name,
    this.surname,
    required this.email,
    this.photoUrl,
    required this.olusturulmaTarihi,
    this.guncellenmeTarihi,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] as String,
      surname: json['surname'] as String?,
      email: json['email'] as String,
      photoUrl: json['photoUrl'] as String?,
      olusturulmaTarihi: json['Olusturulma_tarihi'] as Timestamp,
      guncellenmeTarihi: json['Guncellenme_tarihi'] as Timestamp?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'surname': surname,
      'email': email,
      'photoUrl': photoUrl,
      'Olusturulma_tarihi': olusturulmaTarihi,
      'Guncellenme_tarihi': guncellenmeTarihi,
    };
  }
}
