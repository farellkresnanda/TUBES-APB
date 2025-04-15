import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'theme_notifier.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(  
    url: 'https://lfkfnygfjdqkaufwjdng.supabase.co', 
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imxma2ZueWdmamRxa2F1ZndqZG5nIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDI1MzcyNTYsImV4cCI6MjA1ODExMzI1Nn0.q4vVxl7tWI9OQbd-SY_LdUSvPWuvxSVBhWLpg5OV5yY',
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeNotifier(),
      child: const TukangKuApp(),
    ),
  );
}

class TukangKuApp extends StatelessWidget {
  const TukangKuApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TukangKu',
      themeMode: themeNotifier.themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: Supabase.instance.client.auth.currentSession != null
          ? const HomeScreen()
          : const LoginScreen(),
    );
  }
}


