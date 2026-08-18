import 'package:app/core/theme/app_theme.dart';
import 'package:app/helpers/complaint_helper.dart';
import 'package:app/helpers/time_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthorityResponseCard extends StatelessWidget {
  final String status;
  final String? adminRemarks;
  final String? resolvedAt;
  final String? rejectedAt;

  const AuthorityResponseCard({
    super.key,
    required this.status,
    this.adminRemarks,
    this.resolvedAt,
    this.rejectedAt,
  });

  bool get _isResolved => status.toLowerCase() == 'resolved';
  bool get _isRejected => status.toLowerCase() == 'rejected';
  bool get _isVisible => _isResolved || _isRejected;

  String get _actionLabel => _isResolved ? 'Resolved at' : 'Rejected at';

  String? get _actionDate => _isResolved ? resolvedAt : rejectedAt;

  String get _message {
    if (adminRemarks != null && adminRemarks!.trim().isNotEmpty) {
      return adminRemarks!;
    }
    return _isResolved
        ? 'Issue has been resolved by the authority.'
        : 'Complaint was rejected by the authority.';
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: ComplaintHelper.getStatusBgColor(status),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ComplaintHelper.getStatusColor(status).withAlpha(150),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            ComplaintHelper.formatStatus(status),
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: ComplaintHelper.getStatusColor(status),
            ),
          ),
          SizedBox(height: 4),

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
          SizedBox(height: 2),

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
