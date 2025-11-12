import 'package:flutter/material.dart';
import 'package:healthcare/db/DBHelper.dart';
import 'package:healthcare/entities/User_Model.dart';
import 'package:healthcare/views/Botumnavigation.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();

  late String username;
  late String email;
  late String password;
  late int age;
  late double weight;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create account", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
      body: Form(
        key: _formKey,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              spacing: 20,
              children: [
                Image.network
                  ("https://scontent.ftun9-1.fna.fbcdn.net/v/t1.15752-9/578704857_1380911673604856_4037051363164192711_n.png?stp=dst-png_s480x480&_nc_cat=110&ccb=1-7&_nc_sid=0024fc&_nc_ohc=z5-dXIcU71IQ7kNvwGojLzz&_nc_oc=AdmoUJ_LrbTQZ2BRGrfWAyN8KEEcIazMbhBU493uib-dm-UDMV5k1guufu8DYfzoNa0&_nc_ad=z-m&_nc_cid=1360&_nc_zt=23&_nc_ht=scontent.ftun9-1.fna&oh=03_Q7cD3wFBW1kbMQw0ZT25ZQF8hhZe0mNMO_EjLIQL6e2E5eyIrw&oe=693B20DD",width: 200),


                // USERNAME
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: "Username",
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) => username = value!.trim(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter a username";
                    }
                    return null;
                  },
                ),

                // EMAIL
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: "Email",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (value) => email = value!.trim(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Email required";
                    } else if (!value.contains('@') || !value.contains('.')) {
                      return "Please enter a valid email";
                    }
                    return null;
                  },
                ),

                // PASSWORD
                TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: "Password",
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) => password = value!.trim(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Password required";
                    } else if (value.length < 6) {
                      return "No less than 6 caracters";
                    }
                    return null;
                  },
                ),

                // ÂGE
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: "Age",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => age = int.parse(value!),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your Age";
                    }
                    return null;
                  },
                ),

                // POIDS
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: "Weight (kg)",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onSaved: (value) => weight = double.parse(value!),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your weight";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // BUTTONS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();

                          final newUser = User(
                            username: username,
                            email: email,
                            password: password,
                            age: age,
                            weight: weight,
                          );

                          await DBHelper.insertUser(newUser);

                          if (!mounted) return;
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => Botumnavigation()),
                          );
                        }
                      },
                      child: const Text("Create account", style: TextStyle(color: Colors.white)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}