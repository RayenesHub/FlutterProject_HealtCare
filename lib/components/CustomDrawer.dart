import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:healthcare/views/user/SignIn.dart';

import '../db/DBHelper.dart';
import '../entities/User_Model.dart';
import '../views/user/Profile_screen.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  Future<User?> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId == null) return null;
    return DBHelper.getUserById(userId);
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('username');
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SignIn()),
          (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder<User?>(
        future: _loadCurrentUser(),
        builder: (context, snapshot) {
          final user = snapshot.data;

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              // En-tête du Drawer
              DrawerHeader(
                decoration: const BoxDecoration(color: Colors.green),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ton image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        "https://scontent.ftun9-1.fna.fbcdn.net/v/t1.15752-9/578704857_1380911673604856_4037051363164192711_n.png?stp=dst-png_s480x480&_nc_cat=110&ccb=1-7&_nc_sid=0024fc&_nc_ohc=z5-dXIcU71IQ7kNvwGojLzz&_nc_oc=AdmoUJ_LrbTQZ2BRGrfWAyN8KEEcIazMbhBU493uib-dm-UDMV5k1guufu8DYfzoNa0&_nc_ad=z-m&_nc_cid=1360&_nc_zt=23&_nc_ht=scontent.ftun9-1.fna&oh=03_Q7cD3wFBW1kbMQw0ZT25ZQF8hhZe0mNMO_EjLIQL6e2E5eyIrw&oe=693B20DD",
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Nom + email (dynamiques)
                    Text(
                      snapshot.connectionState == ConnectionState.waiting
                          ? "Chargement…"
                          : (user?.username ?? "Invité"),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      user?.email ?? "—",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),

              // Exemple d’item profil
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text("Profil"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
              ),
              // Logout
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text("Logout"),
                onTap: _logout,
              ),
            ],
          );
        },
      ),
    );
  }
}
