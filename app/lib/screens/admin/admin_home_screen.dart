import 'package:app/core/theme/app_theme.dart';
import 'package:app/screens/admin/complaints/admin_complaints_screen.dart';
import 'package:app/screens/admin/dashboard/admin_dashboard_screen.dart';
import 'package:app/screens/admin/profile/admin_profile_screen.dart';
import 'package:app/screens/admin/users/admin_users_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

class AdminHomeScreen extends ConsumerStatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  ConsumerState<AdminHomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<AdminHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    AdminDashboardScreen(),
    AdminComplaintsScreen(),
    AdminUsersScreen(),
    AdminProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(_initializeApp);
  }

  Future<void> _initializeApp() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      body: _screens[_currentIndex],
      bottomNavigationBar: _ReportItAdminNavBar(
        currentIndex: _currentIndex,
        onTabSelected: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _ReportItAdminNavBar extends StatelessWidget {
  const _ReportItAdminNavBar({
    required this.currentIndex,
    required this.onTabSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (i) {
        onTabSelected(i);
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppTheme.appBarBg,
      selectedItemColor: AppTheme.primary,
      unselectedItemColor: AppTheme.textPrimary,
      elevation: 0,
      selectedFontSize: 0,
      unselectedFontSize: 0,

      items: [
        BottomNavigationBarItem(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedDashboardSquare02,
            size: 22,
            strokeWidth: 1.5,
          ),
          activeIcon: HugeIcon(
            icon: HugeIcons.strokeRoundedDashboardSquare02,
            size: 22,
            strokeWidth: 1.6,
          ),
          label: '',
        ),

        BottomNavigationBarItem(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedReceiptText,
            size: 22,
            strokeWidth: 1.5,
          ),
          activeIcon: HugeIcon(
            icon: HugeIcons.strokeRoundedReceiptText,
            size: 22,
            strokeWidth: 1.6,
          ),
          label: '',
        ),

        BottomNavigationBarItem(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedUserMultiple,
            size: 22,
            strokeWidth: 1.5,
          ),
          activeIcon: HugeIcon(
            icon: HugeIcons.strokeRoundedUserMultiple,
            size: 22,
            strokeWidth: 1.6,
          ),
          label: '',
        ),

        BottomNavigationBarItem(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedUserCircle,
            size: 22,
            strokeWidth: 1.5,
          ),
          activeIcon: HugeIcon(
            icon: HugeIcons.strokeRoundedUserCircle,
            size: 22,
            strokeWidth: 1.6,
          ),
          label: '',
        ),
      ],
    );
  }
}
