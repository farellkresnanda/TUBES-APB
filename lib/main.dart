// File: main.dart

import 'package:flutter/material.dart';
import 'package:tubes_1/screens/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(  
    url: 'https://lfkfnygfjdqkaufwjdng.supabase.co', 
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imxma2ZueWdmamRxa2F1ZndqZG5nIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDI1MzcyNTYsImV4cCI6MjA1ODExMzI1Nn0.q4vVxl7tWI9OQbd-SY_LdUSvPWuvxSVBhWLpg5OV5yY',
  );
  runApp(const TukangKuApp());
}

class TukangKuApp extends StatelessWidget {
  const TukangKuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TukangKu',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginScreen(),
    );
  }
}


