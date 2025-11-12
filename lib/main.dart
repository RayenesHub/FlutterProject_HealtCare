import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:healthcare/views/user/SignIn.dart';
import 'package:healthcare/views/user/SignUp.dart';
import 'package:healthcare/views/Botumnavigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _decideStartPage() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    // Si une session existe → aller sur l’app principale
    if (userId != null) {
      return Botumnavigation();
    }
    // Sinon → écran de connexion
    return const SignIn();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WellCare',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      // Démarrage conditionnel selon la session
      home: FutureBuilder<Widget>(
        future: _decideStartPage(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return snapshot.data!;
        },
      ),

      // Routes nommées
      routes: {
        '/signIn': (context) => const SignIn(),
        '/signUp': (context) => const SignUp(),
        '/home': (context) => Botumnavigation(),
      },
    );
  }
}