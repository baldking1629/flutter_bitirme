import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  bool isLogin = true; // Giriş mi, kayıt mı?
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // 📌 Google ile Giriş Fonksiyonu
  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Firestore'a kullanıcıyı ekle
        await _firestore.collection('Kullanicilar').doc(user.uid).set({
          'name': user.displayName?.split(' ').first ?? '',
          'surname': user.displayName?.split(' ').last ?? '',
          'email': user.email ?? "bilinmeyen@example.com",
          'photoUrl': user.photoURL ?? "",
          'Olusturulma_tarihi': FieldValue.serverTimestamp(),
          'Guncellenme_tarihi': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google ile giriş yapılırken bir hata oluştu'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // 📌 E-posta ve Şifre ile Giriş veya Kayıt
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (isLogin) {
        // Giriş yap
        final userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (userCredential.user != null && mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        }
      } else {
        // Kayıt ol
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (userCredential.user != null) {
          // Kullanıcı bilgilerini Firestore'a kaydet
          await _firestore
              .collection('Kullanicilar')
              .doc(userCredential.user!.uid)
              .set({
            'name': _nameController.text.trim(),
            'surname': _surnameController.text.trim(),
            'email': _emailController.text.trim(),
            'Olusturulma_tarihi': FieldValue.serverTimestamp(),
            'Guncellenme_tarihi': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          }
        }
      }
    } on FirebaseAuthException catch (error) {
      String message = 'Bir hata oluştu';

      if (error.code == 'user-not-found') {
        message = 'Bu e-posta adresi ile kayıtlı kullanıcı bulunamadı';
      } else if (error.code == 'wrong-password') {
        message = 'Yanlış şifre girdiniz';
      } else if (error.code == 'email-already-in-use') {
        message = 'Bu e-posta adresi zaten kullanımda';
      } else if (error.code == 'weak-password') {
        message = 'Şifre en az 6 karakter olmalıdır';
      } else if (error.code == 'invalid-email') {
        message = 'Geçersiz e-posta adresi';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bir hata oluştu'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 40),
                Icon(
                  Icons.agriculture,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(height: 16),
                Text(
                  'Akıllı Tarım',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  isLogin ? 'Hesabınıza Giriş Yapın' : 'Yeni Hesap Oluşturun',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),
                if (!isLogin) ...[
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: "İsim",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (!isLogin && (value?.isEmpty ?? true)) {
                        return 'Lütfen isminizi girin';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _surnameController,
                    decoration: InputDecoration(
                      labelText: "Soyisim",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (!isLogin && (value?.isEmpty ?? true)) {
                        return 'Lütfen soyisminizi girin';
                      }
                      return null;
                    },
                  ),
                ],
                SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "E-posta",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Lütfen e-posta adresinizi girin';
                    }
                    if (!value!.contains('@')) {
                      return 'Geçerli bir e-posta adresi girin';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: "Şifre",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Lütfen şifrenizi girin';
                    }
                    if (value!.length < 6) {
                      return 'Şifre en az 6 karakter olmalıdır';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                if (_isLoading)
                  Center(child: CircularProgressIndicator())
                else
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: _submit,
                        child: Text(isLogin ? "Giriş Yap" : "Kayıt Ol"),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _signInWithGoogle,
                        icon: Icon(Icons.g_mobiledata, size: 24),
                        label: Text("Google ile Giriş Yap"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          minimumSize: Size(double.infinity, 50),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isLogin = !isLogin;
                            _nameController.clear();
                            _surnameController.clear();
                          });
                        },
                        child: Text(isLogin
                            ? "Hesabınız yok mu? Kayıt olun"
                            : "Zaten hesabınız var mı? Giriş yapın"),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    super.dispose();
  }
}
