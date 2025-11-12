import 'package:flutter/material.dart';
import 'package:healthcare/db/DBHelper.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../entities/User_Model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  User? _user;
  bool _loading = true;
  bool _editing = false;

  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('userId');
    if (id != null) {
      final user = await DBHelper.getUserById(id);
      if (user != null) {
        _usernameCtrl.text = user.username;
        _emailCtrl.text = user.email;
        _passwordCtrl.text = user.password;
        _ageCtrl.text = user.age.toString();
        _weightCtrl.text = user.weight.toString();
        setState(() {
          _user = user;
          _loading = false;
        });
      }
    }
  }

  Future<void> _updateUser() async {
    if (!_formKey.currentState!.validate() || _user == null) return;

    final updatedUser = User(
      id: _user!.id,
      username: _usernameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text.trim(),
      age: int.parse(_ageCtrl.text),
      weight: double.parse(_weightCtrl.text),
    );

    await DBHelper.updateUser(updatedUser);

    setState(() {
      _user = updatedUser;
      _editing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profil mis à jour avec succès ✅")),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon Profil"),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(_editing ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() => _editing = !_editing);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            spacing: 16,
            children: [
              const Icon(Icons.account_circle, size: 100, color: Colors.green),
              TextFormField(
                controller: _usernameCtrl,
                enabled: _editing,
                decoration: const InputDecoration(
                  labelText: "Nom d'utilisateur",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty
                    ? "Le nom d'utilisateur est obligatoire"
                    : null,
              ),
              TextFormField(
                controller: _emailCtrl,
                enabled: _editing,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return "L'email est obligatoire";
                  if (!v.contains('@')) return "Email invalide";
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordCtrl,
                enabled: _editing,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Mot de passe",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                v == null || v.isEmpty ? "Le mot de passe est requis" : null,
              ),
              TextFormField(
                controller: _ageCtrl,
                enabled: _editing,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Âge",
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return "L'âge est requis";
                  if (int.tryParse(v) == null) return "Entrez un nombre valide";
                  return null;
                },
              ),
              TextFormField(
                controller: _weightCtrl,
                enabled: _editing,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: "Poids (kg)",
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return "Le poids est requis";
                  if (double.tryParse(v) == null) return "Entrez un nombre valide";
                  return null;
                },
              ),
              const SizedBox(height: 20),
              if (_editing)
                ElevatedButton.icon(
                  onPressed: _updateUser,
                  icon: const Icon(Icons.save),
                  label: const Text("Enregistrer"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _ageCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }
}