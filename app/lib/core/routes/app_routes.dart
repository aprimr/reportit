import 'package:app/screens/admin/auth/admin_login_screen.dart';
import 'package:flutter/material.dart';
import 'package:app/screens/extras/splash_screen.dart';
import 'package:app/screens/extras/welcome_screen.dart';
import 'package:app/screens/user/auth/login_screen.dart';
import 'package:app/screens/user/auth/register_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String welcome = '/welcome';

  static const String login = '/login';
  static const String register = '/register';
  static const String adminLogin = '/admin-login';

  static const String home = '/home';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    welcome: (context) => const WelcomeScreen(),

    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    adminLogin: (context) => const AdminLoginScreen(),

    home: (context) => const Scaffold(body: Center(child: Text('Home'))),
  };
}
