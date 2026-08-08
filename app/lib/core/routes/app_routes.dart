import 'package:app/screens/user/complaint/create_complaint.dart';
import 'package:app/screens/user/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:app/screens/extras/splash_screen.dart';
import 'package:app/screens/extras/welcome_screen.dart';
import 'package:app/screens/auth/login_screen.dart';
import 'package:app/screens/auth/register_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String welcome = '/welcome';

  static const String login = '/login';
  static const String register = '/register';

  // user routes
  static const String home = '/home';
  static const String create = '/create';

  // admin routes
  static const String adminDash = '/dashboard';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    welcome: (context) => const WelcomeScreen(),

    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),

    // user
    home: (context) => const HomeScreen(),
    create: (context) => const CreateComplaintScreen(),

    // admin
    adminDash: (context) =>
        const Scaffold(body: Center(child: Text('Admin Dash'))),
  };
}
