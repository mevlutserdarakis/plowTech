import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Artık başlangıç noktamız main_screen oldu
import 'screens/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Color.fromARGB(255, 255, 3, 3),
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const PloWeApp());
}

class PloWeApp extends StatelessWidget {
  const PloWeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PloWe',
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      // Uygulama artık MainScreen'den başlıyor
      home: MainScreen(), 
    );
  }
}