import 'package:flutter/material.dart';
import 'package:healthcare/views/user/SignIn.dart';
import 'package:healthcare/views/user/SignUp.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WellCare',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      // La page qui s'affiche au démarrage
      home: SignIn(),

      // 2. DÉCLAREZ VOS ROUTES ICI
      routes: {
        '/signUp': (context) => SignUp(), // Quand on appelle '/signUp', on affiche le widget SignUp
        // Vous pouvez ajouter d'autres routes ici
        // '/home': (context) => HomePage(),
      },
    );
  }
}