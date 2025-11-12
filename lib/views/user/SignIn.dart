import 'package:flutter/material.dart';
import 'package:healthcare/db/DBHelper.dart';
import 'package:healthcare/views/Botumnavigation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  bool _loading = false;
  bool _obscure = true;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final email = _emailCtrl.text.trim();
      final password = _passwordCtrl.text.trim();

      // Vérification en base de données SQLite
      final user = await DBHelper.getUserByEmailAndPassword(email, password);

      if (user == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email ou mot de passe incorrect.")),
        );
        return;
      }

      // Sauvegarde de la session
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', user.id!);
      await prefs.setString('username', user.username);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Botumnavigation()),
      );
    } catch (e) {
      debugPrint('Erreur de connexion: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Une erreur s'est produite.")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Se connecter", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
      body: Form(
        key: _formKey,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              spacing: 20,
              children: [
                Image.network(
                  "https://scontent.ftun9-1.fna.fbcdn.net/v/t1.15752-9/578704857_1380911673604856_4037051363164192711_n.png?stp=dst-png_s480x480&_nc_cat=110&ccb=1-7&_nc_sid=0024fc&_nc_ohc=z5-dXIcU71IQ7kNvwGojLzz&_nc_oc=AdmoUJ_LrbTQZ2BRGrfWAyN8KEEcIazMbhBU493uib-dm-UDMV5k1guufu8DYfzoNa0&_nc_ad=z-m&_nc_cid=1360&_nc_zt=23&_nc_ht=scontent.ftun9-1.fna&oh=03_Q7cD3wFBW1kbMQw0ZT25ZQF8hhZe0mNMO_EjLIQL6e2E5eyIrw&oe=693B20DD",
                  width: 180,
                ),

                // EMAIL
                TextFormField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(
                    hintText: "Email",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Veuillez entrer votre email";
                    } else if (!value.contains('@') || !value.contains('.')) {
                      return "Adresse email invalide";
                    }
                    return null;
                  },
                ),

                // MOT DE PASSE
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    hintText: "Mot de passe",
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscure ? Icons.visibility : Icons.visibility_off),
                      onPressed: () =>
                          setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Veuillez entrer votre mot de passe";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 10),

                // BOUTON DE CONNEXION
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 14),
                  ),
                  onPressed: _loading ? null : _login,
                  child: _loading
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    "Se connecter",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),

                // Lien vers SignUp
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signUp');
                  },
                  child: const Text(
                    "Pas encore de compte ? Créez-en un",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}