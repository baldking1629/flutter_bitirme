import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController =
      TextEditingController(); // 🔹 Ad-Soyad Alanı
  bool isLogin = true; // Giriş mi, kayıt mı?

  // 📌 Google ile Giriş Fonksiyonu
  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        // Firestore’a kullanıcıyı ekle
        await _firestore.collection('Kullanicilar').doc(user.uid).set({
          'name': user.displayName ?? "Bilinmeyen Kullanıcı",
          'email': user.email ?? "bilinmeyen@example.com",
          'photoUrl': user.photoURL ?? "",
          'Olusturulma_tarihi': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        print("✅ Kullanıcı Firestore'a eklendi!");
      }
    } catch (e) {
      print("Google ile giriş hatası: $e");
    }
  }

  // 📌 E-posta ve Şifre ile Giriş veya Kayıt
  void _authenticate() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String fullName = _nameController.text.trim();

    try {
      UserCredential userCredential;
      if (isLogin) {
        userCredential = await _auth.signInWithEmailAndPassword(
            email: email, password: password);
            await userCredential.user!.updateDisplayName(fullName);
        await userCredential.user!
            .reload();
      } else {
        userCredential = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        await userCredential.user!.updateDisplayName(fullName);
        await userCredential.user!
            .reload(); // Güncellemenin hemen yansımasını sağlamak için
      }

      User? user = userCredential.user;
      if (user != null) {
        await _firestore.collection('Kullanicilar').doc(user.uid).set({
          'name': fullName.isNotEmpty ? fullName : "Anonim Kullanıcı",
          'email': email,
          'Olusturulma_tarihi': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        print("✅ Kullanıcı Firestore'a eklendi!");
      }
    } catch (e) {
      print("❌ Hata: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? "Giriş Yap" : "Kayıt Ol")),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!isLogin) // 🔹 Kayıt ekranında ad-soyad alanı gösterilecek
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: "Ad Soyad"),
                ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "E-posta"),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: "Şifre"),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _authenticate,
                child: Text(isLogin ? "Giriş Yap" : "Kayıt Ol"),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _signInWithGoogle,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text("Google ile Giriş Yap"),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    isLogin = !isLogin;
                    _nameController
                        .clear(); // 🔹 Kayıt ekranına geçildiğinde ad soyad alanı temizlenir
                  });
                },
                child: Text(isLogin
                    ? "Hesabın yok mu? Kayıt ol"
                    : "Zaten hesabın var mı? Giriş yap"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
