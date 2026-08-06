import 'package:app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ProfileSkeletonScreen extends StatelessWidget {
  const ProfileSkeletonScreen({super.key});

  static const Color grey = Color(0xFFE4E6EA);
  static const Color lightGrey = Color(0xFFF0F1F4);

  Widget _box(double w, double h, {Color color = grey, double r = 4}) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(r),
      ),
    );
  }

  Widget _tile({double subtitleWidth = 0, bool arrow = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          _box(34, 34, r: 10),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _box(130, 13),
                if (subtitleWidth > 0) ...[
                  const SizedBox(height: 6),
                  _box(subtitleWidth, 10),
                ],
              ],
            ),
          ),
          if (arrow) ...[const SizedBox(width: 8), _box(14, 14, r: 7)],
        ],
      ),
    );
  }

  Widget _divider() => Divider(
    height: 1,
    thickness: 1,
    indent: 56,
    color: AppTheme.inputBorder.withValues(alpha: 0.7),
  );

  Widget _card(List<Widget> children) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppTheme.inputBorder, width: 1),
    ),
    child: Column(children: children),
  );

  Widget _heroStat() => Row(
    children: [
      _box(22, 22, color: lightGrey, r: 11),
      const SizedBox(width: 8),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _box(40, 9, color: lightGrey, r: 3),
            const SizedBox(height: 6),
            _box(64, 11, color: lightGrey, r: 3),
          ],
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          physics: const NeverScrollableScrollPhysics(),
          children: [
            // Hero card
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: grey,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _box(140, 18, color: lightGrey, r: 5),
                      const SizedBox(width: 10),
                      _box(58, 18, color: lightGrey, r: 6),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _box(180, 11, color: lightGrey),
                  const SizedBox(height: 18),
                  Container(height: 1, color: lightGrey.withValues(alpha: 0.5)),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: _heroStat()),
                      Container(
                        width: 1.5,
                        height: 30,
                        color: lightGrey.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: _heroStat()),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Account card
            _card([
              _tile(subtitleWidth: 110),
              _divider(),
              _tile(),
              _divider(),
              _tile(subtitleWidth: 90),
            ]),

            const SizedBox(height: 30),

            // Danger zone
            _card([
              _tile(subtitleWidth: 150, arrow: false),
              _divider(),
              _tile(arrow: false),
            ]),
          ],
        ),
      ),
    );
  }
}
