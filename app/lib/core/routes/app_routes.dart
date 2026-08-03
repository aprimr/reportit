import 'package:flutter/material.dart';
import 'package:app/screens/extras/splash_screen.dart';
import 'package:app/screens/extras/welcome_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    welcome: (context) => const WelcomeScreen(),
    login: (context) => const Scaffold(body: Center(child: Text('Login'))),
    signup: (context) => const Scaffold(body: Center(child: Text('Sign Up'))),
    home: (context) => const Scaffold(body: Center(child: Text('Home'))),
  };
}
