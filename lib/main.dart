import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_options.dart';
import 'package:firebase_database/src/app.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}