import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:healthcare/views/hydration/hydration_screen.dart';

import '../components/CustomDrawer.dart';
import 'Humeur/HumeurListScreen.dart';
import 'activity/ActivityList.dart';

import 'hydration/hydration_screen.dart';
import 'objectif/objectif_screen.dart';

class Botumnavigation extends StatefulWidget {
  const Botumnavigation({super.key});

  @override
  State<Botumnavigation> createState() => _BotumnavigationState();

  initState() async{

  }
}

class _BotumnavigationState extends State<Botumnavigation> {

  String? emailSharedPref;

  void getEmailFromSharedPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      //changement d'état
      emailSharedPref = prefs.getString("email");
    });
  }
  @override
  void initState() {
    super.initState();
    getEmailFromSharedPref();
  }

  int pageIndex = 0;

// ✅ Pages alignées avec le BottomNavigationBar
  final List<Widget> _pages = const [
    ActivityList(),
    HydrationScreen(),
    ObjectiveScreen(), // Objectifs
    HumeurListScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("WellCare", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
      drawer: const CustomDrawer(),

      // ✅ Affiche la page correspondant à l’onglet sélectionné
      body: _pages[pageIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: pageIndex,
        onTap: (value) {
          setState(() {
            pageIndex = value;
          });
        },
        backgroundColor: Colors.greenAccent,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.self_improvement_sharp), label:"Activité Physique"),
          BottomNavigationBarItem(icon: Icon(Icons.water_drop_rounded), label:"Hydratation" ),
          BottomNavigationBarItem(icon: Icon(Icons.task_rounded), label: "Objectifs"),
          BottomNavigationBarItem(icon: Icon(Icons.mood), label: "Humeur"),
          BottomNavigationBarItem(icon: Icon(Icons.lunch_dining), label: "Module4"),
        ],
      ),
    );
  }

}