import 'package:app/core/theme/app_theme.dart';
import 'package:app/helpers/complaint_helper.dart';
import 'package:app/helpers/time_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

class ComplaintTracking extends StatelessWidget {
  final String id;
  final bool showTrackingId;
  final String? createdAt;
  final String? verifiedAt;
  final String? resolvedAt;
  final String? rejectedAt;

  const ComplaintTracking({
    super.key,
    required this.id,
    this.showTrackingId = true,
    required this.createdAt,
    required this.verifiedAt,
    required this.resolvedAt,
    required this.rejectedAt,
  });

  @override
  Widget build(BuildContext context) {
    bool isVerified = verifiedAt != null;
    bool isResolved = resolvedAt != null;
    bool isRejected = rejectedAt != null;
    final String trackingId = ComplaintHelper.extractTrackingId(id, createdAt!);

    // Colors
    const Color grayColor = AppTheme.textHint;
    final Color createdColor = AppTheme.warning;
    final Color verifiedColor = isVerified ? AppTheme.secondary : grayColor;
    final Color resolvedColor = isResolved ? AppTheme.success : grayColor;
    final Color rejectedColor = isRejected ? AppTheme.error : grayColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Track Complaint",
            style: GoogleFonts.montserrat(
              fontSize: 16,
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6),

          // Tracking ID
          if (showTrackingId) ...[
            Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: trackingId));
                  },
                  child: Row(
                    children: [
                      Text(
                        trackingId,
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 8),
                      HugeIcon(
                        size: 14,
                        color: AppTheme.textSecondary,
                        icon: HugeIcons.strokeRoundedCopy01,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 13),
              ],
            ),
          ],

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Created Node
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNodeWithLabel(
                    title: "Created",
                    date: createdAt,
                    nodeColor: createdColor,
                  ),
                ],
              ),

              // Rejected Node
              if (isRejected) ...[
                _buildVerticalConnector(
                  isActive: isRejected,
                  status: "rejected",
                ),
                _buildNodeWithLabel(
                  title: "Rejected",
                  date: rejectedAt,
                  nodeColor: rejectedColor,
                ),
              ],
            ],
          ),

          // Nodes for verified and Resolved
          if (!isRejected) ...[
            _buildVerticalConnector(isActive: isRejected, status: "verified"),
            _buildNodeWithLabel(
              title: "Verified",
              date: verifiedAt,
              nodeColor: verifiedColor,
            ),
            _buildVerticalConnector(isActive: isResolved, status: "resolved"),
            _buildNodeWithLabel(
              title: "Resolved",
              date: resolvedAt,
              nodeColor: resolvedColor,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNodeWithLabel({
    required String title,
    required String? date,
    required Color nodeColor,
  }) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.scaffoldBg, width: 0),
          ),
          child: Center(
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: nodeColor,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Labels
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: nodeColor,
              ),
            ),
            Text(
              date != null ? TimeHelper.formatDateTime(date) : "Pending",
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: AppTheme.textHint,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVerticalConnector({
    required bool isActive,
    required String status,
  }) {
    Color gradientFrom = AppTheme.textHint;
    Color gradientTo = AppTheme.textSecondary;

    if (isActive && status == "resolved") {
      gradientFrom = AppTheme.secondary;
      gradientTo = AppTheme.success;
    } else if (isActive && status == "verified") {
      gradientFrom = AppTheme.warning;
      gradientTo = AppTheme.secondary;
    } else if (isActive && status == "rejected") {
      gradientFrom = AppTheme.warning;
      gradientTo = AppTheme.error;
    }

    return Container(
      margin: const EdgeInsets.only(left: 11),
      width: 3,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [gradientFrom, gradientTo],
        ),
      ),
    );
  }
}
