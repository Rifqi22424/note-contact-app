import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/src/screens/login_screen.dart';
import 'package:flutter/material.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _signUp() async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      )
          .then((userCredential) async {
        String uid = userCredential.user?.uid ?? '';

        // Create a Firestore collection with the UID as its name
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'email': _emailController.text,
          // Add other user-specific data as needed
        });

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
        );
      });
    } catch (e) {
      print("Failed to sign up: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to sign in: $e"),
        ),
      );
    }
  }

  _login() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => LoginPage(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('Aplikasi Kasir Warteg'),
        centerTitle: true,
      ),
      //Jang scroll meh alus
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset('assets/wartegLogo.png', height: 250),
              Text(
                'Registrasi',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  _signUp();
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                  minimumSize: Size(
                      double.infinity, 40), // Sesuaikan lebar yang diinginkan
                ),
                child: Text('Submit'),
              ),
              Text(
                'Or',
                style: TextStyle(fontSize: 10),
              ),
              ElevatedButton(
                  onPressed: () {
                    _login();
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                    minimumSize: Size(
                        double.infinity, 40), // Sesuaikan lebar yang diinginkan
                  ),
                  child: Text('Login'))
            ],
          ),
        ),
      ),
    );
  }
}
