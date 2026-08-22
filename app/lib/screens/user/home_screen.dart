import 'package:app/core/routes/app_routes.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/utils/app_snackbar.dart';
import 'package:app/providers/user_provider.dart';
import 'package:app/providers/complaint_provider.dart';
import 'package:app/screens/user/feed/feed_screen.dart';
import 'package:app/screens/user/map/map_screen.dart';
import 'package:app/screens/user/mycomplaints/my_complaints_screen.dart';
import 'package:app/screens/user/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    SizedBox(),
    MapScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(_initializeApp);
  }

  Future<void> _initializeApp() async {
    // Fetch all complaints
    try {
      await ref.read(feedComplaintProvider.notifier).fetchAllComplaints();
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.error(context, 'App content initialization failed');
    }

    // Fetch user profile
    try {
      await ref.read(userProvider.notifier).fetchProfile();
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.error(context, 'App content initialization failed');
    }

    // Fetch my complaints only
    try {
      await ref.read(complaintProvider.notifier).fetchMyComplaints();
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.error(context, 'App content initialization failed');
    }
  }

  @override
  void didChangeDependencies() {
    if (_currentIndex == 2) {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom],
      );
    }
    super.didChangeDependencies();
  }

  void _onCreateComplaint() {
    Navigator.pushNamed(context, AppRoutes.create);
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

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (i) {
        if (i == 2) {
          onCreateTap();
        } else {
          final tab = i;
          onTabSelected(tab);
        }
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
            icon: HugeIcons.strokeRoundedHome09,
            size: 22,
            strokeWidth: 1.5,
          ),
          activeIcon: HugeIcon(
            icon: HugeIcons.strokeRoundedHome09,
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
          icon: const HugeIcon(
            icon: HugeIcons.strokeRoundedAddSquare,
            size: 28,
            strokeWidth: 1.6,
            color: AppTheme.primary,
          ),
          label: '',
        ),

        BottomNavigationBarItem(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedMapsLocation01,
            size: 22,
            strokeWidth: 1.5,
          ),
          activeIcon: HugeIcon(
            icon: HugeIcons.strokeRoundedMapsLocation01,
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
