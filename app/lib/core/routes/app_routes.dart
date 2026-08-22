import 'package:app/core/model/complaint_model.dart';
import 'package:app/screens/admin/admin_home_screen.dart';
import 'package:app/screens/user/complaint/create_complaint.dart';
import 'package:app/screens/user/feed/feed_comlaint_detail.dart';
import 'package:app/screens/user/home_screen.dart';
import 'package:app/screens/user/mycomplaints/my_complaint_detail_screen.dart';
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
  static const String feedComplaintDetail = '/feed-complaint-detail';
  static const String myComplaintDetail = '/my-complaint-detail';

  // admin routes
  static const String adminHome = '/admin/home';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    welcome: (context) => const WelcomeScreen(),

    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),

    // user
    home: (context) => const HomeScreen(),
    create: (context) => const CreateComplaintScreen(),
    feedComplaintDetail: (context) {
      final complaint =
          ModalRoute.of(context)!.settings.arguments as FeedComplaintModel;

      return FeedComplaintDetail(complaint: complaint);
    },
    myComplaintDetail: (context) {
      final complaint =
          ModalRoute.of(context)!.settings.arguments as ComplaintModel;

      return MyComplaintDetailScreen(complaint: complaint);
    },

    // admin
    adminHome: (context) => const AdminHomeScreen(),
  };
}
