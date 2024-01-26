import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/src/screens/daftar_menu_screen.dart';
import 'package:firebase_database/src/screens/home_screen.dart';
import 'package:firebase_database/src/screens/regist_screen.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _signIn() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      String uid = userCredential.user?.uid ?? '';

      DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      Map<String, dynamic>? userData = userSnapshot.data();

      if (userData != null) {
        String email = userData['email'] ?? '';
        String displayName = userData['displayName'] ?? '';

        print('User Email: $email');
        print('User Display Name: $displayName');
      }

      // Navigasi ke HomePage setelah login berhasil
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DaftarMenuScreen(uid: uid),
        ),
      );
    } catch (e) {
      print("Failed to sign in: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to log in: $e"),
        ),
      );
    }
  }

  _regist() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => RegistrationPage(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('Aplikasi Kasir Warteg'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset('assets/wartegLogo.png', height: 250),
              Text(
                'Login',
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
                  _signIn();
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
                  _regist();
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                  minimumSize: Size(
                      double.infinity, 40), // Sesuaikan lebar yang diinginkan
                ),
                child: Text('Registrasi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
