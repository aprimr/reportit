import 'package:app/core/theme/app_theme.dart';
import 'package:app/providers/user_provider.dart';
import 'package:app/screens/user/feed/feed_screen.dart';
import 'package:app/screens/user/map/map_screen.dart';
import 'package:app/screens/user/mycomplaints/my_complaints_screen.dart';
import 'package:app/screens/user/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    FeedScreen(),
    MyComplaintsScreen(),
    MapScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Fetch user profile in background on homescreen initializes
    Future.microtask(() {
      ref.read(userProvider.notifier).fetchProfile();
    });
  }

  void _onCreateComplaint() {
    // TODO: navigate to create-complaint flow
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      body: _screens[_currentIndex],
      bottomNavigationBar: _ReportItNavBar(
        currentIndex: _currentIndex,
        onTabSelected: (i) => setState(() => _currentIndex = i),
        onCreateTap: _onCreateComplaint,
      ),
    );
  }
}

class _ReportItNavBar extends StatelessWidget {
  const _ReportItNavBar({
    required this.currentIndex,
    required this.onTabSelected,
    required this.onCreateTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onCreateTap;

  static const List<List<List<dynamic>>> _icons = [
    HugeIcons.strokeRoundedHome09,
    HugeIcons.strokeRoundedReceiptText,
    HugeIcons.strokeRoundedMapsLocation01,
    HugeIcons.strokeRoundedUserCircle,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.appBarBg,
        border: Border(
          top: BorderSide(
            color: AppTheme.textSecondary.withAlpha(30),
            width: 0.8,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavIcon(
                icon: _icons[0],
                isActive: currentIndex == 0,
                onTap: () => onTabSelected(0),
              ),
              _NavIcon(
                icon: _icons[1],
                isActive: currentIndex == 1,
                onTap: () => onTabSelected(1),
              ),
              _NavIcon(
                icon: HugeIcons.strokeRoundedAddSquare,
                isActive: false,
                isCenter: true,
                onTap: onCreateTap,
              ),
              _NavIcon(
                icon: _icons[2],
                isActive: currentIndex == 2,
                onTap: () => onTabSelected(2),
              ),
              _NavIcon(
                icon: _icons[3],
                isActive: currentIndex == 3,
                onTap: () => onTabSelected(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.icon,
    required this.isActive,
    required this.onTap,
    this.isCenter = false,
  });

  final List<List<dynamic>> icon;
  final bool isActive;
  final bool isCenter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = isActive ? AppTheme.primary : AppTheme.textPrimary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        height: double.infinity,
        child: Center(
          child: HugeIcon(
            icon: icon,
            size: isCenter ? 28 : 24,
            strokeWidth: isActive ? 1.6 : 1.4,
            color: color,
          ),
        ),
      ),
    );
  }
}
