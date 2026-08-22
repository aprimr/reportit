import 'package:app/core/theme/app_theme.dart';
import 'package:app/helpers/complaint_helper.dart';
import 'package:app/helpers/time_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthorityResponseCard extends StatelessWidget {
  final String status;
  final String? adminRemarks;
  final String? verifiedAt;
  final String? resolvedAt;
  final String? rejectedAt;

  const AuthorityResponseCard({
    super.key,
    required this.status,
    required this.verifiedAt,
    required this.resolvedAt,
    required this.adminRemarks,
    required this.rejectedAt,
  });

  bool get _isVerified => verifiedAt != null;

  bool get _isResolved => status.toLowerCase() == 'resolved';

  bool get _isRejected => status.toLowerCase() == 'rejected';

  bool get _isVisible => _isVerified || _isResolved || _isRejected;

  String get _actionLabel {
    if (_isResolved) return 'Resolved at';
    if (_isRejected) return 'Rejected at';
    return 'Verified at';
  }

  String? get _actionDate {
    if (_isResolved) return resolvedAt;
    if (_isRejected) return rejectedAt;
    return verifiedAt;
  }

  String get _message {
    if (_isResolved) {
      if (adminRemarks != null && adminRemarks!.trim().isNotEmpty) {
        return adminRemarks!;
      }
      return 'Issue has been resolved by the authority.';
    }

    if (_isRejected) {
      if (adminRemarks != null && adminRemarks!.trim().isNotEmpty) {
        return adminRemarks!;
      }
      return 'Complaint was rejected by the authority.';
    }

    return 'Your complaint has been verified and is now being worked on by the authority.';
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    final displayStatus = _isResolved
        ? 'Resolved'
        : _isRejected
        ? 'Rejected'
        : 'Verified';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 16),
      decoration: BoxDecoration(
        color: ComplaintHelper.getStatusBgColor(displayStatus),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ComplaintHelper.getStatusColor(displayStatus).withAlpha(150),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            displayStatus,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: ComplaintHelper.getStatusColor(displayStatus),
            ),
          ),

          const SizedBox(height: 4),

          // Remarks
          Text(
            _message,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 2),

          // Timestamp
          Text(
            '$_actionLabel ${_actionDate != null ? TimeHelper.formatDateTime(_actionDate) : '—'}',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
