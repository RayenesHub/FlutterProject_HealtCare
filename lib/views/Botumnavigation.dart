


import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/CustomDrawer.dart';

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

  int pageIndex=0;
  //List<Widget> interfaces =[GamesGridView(),GamesListView()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("WellCare", style:TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
      drawer: CustomDrawer(email: emailSharedPref!),
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
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.self_improvement_sharp), label: "Activité Physique"),
          BottomNavigationBarItem(icon: Icon(Icons.water_drop_rounded), label: "Hydratation"),
          BottomNavigationBarItem(icon: Icon(Icons.bedtime), label: "Sommeil"),
          BottomNavigationBarItem(icon: Icon(Icons.ramen_dining), label: "Module4"),
          BottomNavigationBarItem(icon: Icon(Icons.lunch_dining), label: "Module5"),
        ],
      ),
      //body: interfaces[pageIndex],
    );
  }
}

