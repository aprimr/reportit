import 'package:app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class HomeSkeletonScreen extends StatelessWidget {
  const HomeSkeletonScreen({super.key});

  Widget _skeletonBox({double? width, double? height, double radius = 4}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _cardSkeleton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 15),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        border: Border.all(
          width: 1.8,
          color: AppTheme.inputBorder.withAlpha(200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Category
              _skeletonBox(width: 75, height: 22, radius: 6),

              // Status
              _skeletonBox(width: 65, height: 20, radius: 6),
            ],
          ),

          const SizedBox(height: 10),

          // Title
          _skeletonBox(width: 190, height: 17, radius: 4),

          const SizedBox(height: 6),

          // Description line 1
          _skeletonBox(width: double.infinity, height: 13, radius: 4),

          const SizedBox(height: 5),

          // Description line 2
          _skeletonBox(width: 230, height: 13, radius: 4),

          const SizedBox(height: 10),

          // User
          Row(
            children: [
              _skeletonBox(width: 14, height: 14, radius: 7),
              const SizedBox(width: 6),
              _skeletonBox(width: 100, height: 13, radius: 4),
            ],
          ),

          // Divider
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, thickness: 1, color: AppTheme.divider),
          ),

          // Bottom Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Vote buttons
              Row(
                children: [
                  _skeletonBox(width: 55, height: 28, radius: 6),

                  const SizedBox(width: 10),

                  _skeletonBox(width: 55, height: 28, radius: 6),
                ],
              ),

              // Date
              _skeletonBox(width: 70, height: 13, radius: 4),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _cardSkeleton(),
        _cardSkeleton(),
        _cardSkeleton(),
        _cardSkeleton(),
        _cardSkeleton(),
      ],
    );
  }
}
