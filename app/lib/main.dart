import 'package:app/screens/extras/splash_screen.dart';
import 'package:app/screens/extras/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Complaint Management',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) =>
            const Scaffold(body: Center(child: Text('Login'))),
        '/signup': (context) =>
            const Scaffold(body: Center(child: Text('Sign Up'))),
        '/home': (context) => const Scaffold(body: Center(child: Text('Home'))),
      },
    );
  }
}
