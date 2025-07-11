import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'providers/theme_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'providers/sulama_kaydi_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  try {
    await dotenv.load(fileName: ".env");
    print(
        'API Key yüklendi: ${dotenv.env['OPENWEATHER_API_KEY'] != null ? 'Mevcut' : 'Bulunamadı'}');
  } catch (e) {
    print('Hata: .env dosyası yüklenemedi: $e');
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SulamaKaydiProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Akıllı Tarım',
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            home: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Scaffold(
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.agriculture,
                            size: 80,
                            color: themeProvider.lightTheme.colorScheme.primary,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Akıllı Tarım',
                            style: themeProvider
                                .lightTheme.textTheme.headlineMedium
                                ?.copyWith(
                              color:
                                  themeProvider.lightTheme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 24),
                          CircularProgressIndicator(),
                        ],
                      ),
                    ),
                  );
                }
                if (snapshot.hasData) {
                  return HomeScreen();
                }
                return AuthScreen();
              },
            ),
          );
        },
      ),
    );
  }
}
