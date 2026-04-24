import 'package:flutter/material.dart';
import '../pages/absensi.dart';
import '../start/start.dart';
import '../start/login.dart';
import '../main.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Sora'),

      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(nextScreen: LoginPage()),
        '/login': (context) => LoginPage(),
        '/home': (context) => AbsensiPage(),
      },
    );
  }
}
