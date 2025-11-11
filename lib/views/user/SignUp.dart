
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:healthcare/views/Botumnavigation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/CustomDrawer.dart';

class SignUp extends StatefulWidget  {
  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  late String username;
  late String password;
  late String email;
  late String adresse;
  final _formKey = GlobalKey<FormState>();


  @override
  Widget build(BuildContext context) {
    return Scaffold( appBar: AppBar(
      title: Text("S'authentifier", style:TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.green,
    ),
        body:Form(
          key: _formKey,
          child: Center(
              child: Column(
                //espacement entre el image wl texts
                spacing:20,
                children: [
                  Image.network
                    ("https://scontent.ftun9-1.fna.fbcdn.net/v/t1.15752-9/578704857_1380911673604856_4037051363164192711_n.png?stp=dst-png_s480x480&_nc_cat=110&ccb=1-7&_nc_sid=0024fc&_nc_ohc=z5-dXIcU71IQ7kNvwGojLzz&_nc_oc=AdmoUJ_LrbTQZ2BRGrfWAyN8KEEcIazMbhBU493uib-dm-UDMV5k1guufu8DYfzoNa0&_nc_ad=z-m&_nc_cid=1360&_nc_zt=23&_nc_ht=scontent.ftun9-1.fna&oh=03_Q7cD3wFBW1kbMQw0ZT25ZQF8hhZe0mNMO_EjLIQL6e2E5eyIrw&oe=693B20DD",width: 200),

                  //USERNAME
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: "username", border:OutlineInputBorder(),
                    ),

                    onSaved:(value) {
                      username=value! ;
                    },
                    //controle de saisie ibara
                    validator: (value){
                      if ( value!.isEmpty){
                        return "username can't be empty" ;
                      }
                    },
                  ),

                  //PASSWORD
                  TextFormField(
                    //bech nrod el password mayetrach netsaml obscureText
                    obscureText: true,
                    onSaved: (value) => password=value! ,
                    validator: (value) {
                      if ( value!.isEmpty){
                        return "password can't be empty" ;
                      }
                    },
                    decoration: InputDecoration(hintText: "password",
                      border:OutlineInputBorder(), ),


                    //EMAIL
                  ),TextFormField(
                    decoration: InputDecoration(
                      hintText: "Email",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onSaved: (value) => email = value!,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Email can't be empty";
                      } else if (!value.contains('@') || !value.contains('.')) {
                        return "Please insert a valid email adress";
                      }
                      return null;
                    },
                  ),


                  TextFormField(
                    decoration: InputDecoration(
                      hintText: "Adress", border:OutlineInputBorder(),
                    ),

                    onSaved:(value) {
                      adresse=value! ;
                    },
                    //controle de saisie ibara
                    validator: (value){
                      if ( value!.isEmpty){
                        return "Address can't be empty" ;
                      }
                    },
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,

                        ), onPressed: () async {
                        //kif tenzel al bouton je vais valider el formulaire elkol
                        if (_formKey.currentState!.validate()){
                          //bech nsavi el state
                          _formKey.currentState!.save();
                          //authentification logic
                          print('Ussername: $username , Password:$password');

                          SharedPreferences prefs= await SharedPreferences.getInstance();
                          prefs.setString("email",username);
                          prefs.setString("password",password);

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => Botumnavigation()));

                        }
                      }, child: Text("Create account", style: TextStyle(color: Colors.white),) ,

                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,

                        ), onPressed: () {
                        Navigator.pop(context);
                      },
                        child: Text("cancel",style: TextStyle(color: Colors.white),) ,
                      ),

                    ],
                  )
                ],
              )),
        ));

  }
}