import 'package:flutter/material.dart';
import 'package:workouttimer/splash.dart';
import 'package:workouttimer/config.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workout Timer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),

      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/config': (context) => const ConfigurationPage(),
      },
    );
  }
}
