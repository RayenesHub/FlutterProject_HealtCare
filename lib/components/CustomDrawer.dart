import 'package:flutter/material.dart';
import '../views/user/SignIn.dart';



class CustomDrawer extends StatelessWidget {

  String email="";

  CustomDrawer({super.key, required this.email});

  @override
  Widget build(BuildContext context) {

    return Drawer(
      child: ListView(

        children: [
          Image.network
            ("https://scontent.ftun9-1.fna.fbcdn.net/v/t1.15752-9/578704857_1380911673604856_4037051363164192711_n.png?stp=dst-png_s480x480&_nc_cat=110&ccb=1-7&_nc_sid=0024fc&_nc_ohc=z5-dXIcU71IQ7kNvwGojLzz&_nc_oc=AdmoUJ_LrbTQZ2BRGrfWAyN8KEEcIazMbhBU493uib-dm-UDMV5k1guufu8DYfzoNa0&_nc_ad=z-m&_nc_cid=1360&_nc_zt=23&_nc_ht=scontent.ftun9-1.fna&oh=03_Q7cD3wFBW1kbMQw0ZT25ZQF8hhZe0mNMO_EjLIQL6e2E5eyIrw&oe=693B20DD",width: 200),
          ListTile(
            leading: IconButton(onPressed: () {}, icon: Icon(Icons.person)),
            title: Text(email),
          ),
          ListTile(
            leading: IconButton(onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SignIn()),
              );
            }, icon: Icon(Icons.logout)),
            title: Text("Logout"),
          ),
        ],
      ),
    );
  }}
