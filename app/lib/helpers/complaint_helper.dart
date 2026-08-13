import 'package:app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ComplaintHelper {
  static Color getStatusColor(String status) {
    switch (status.toLowerCase().trim()) {
      case 'open':
        return AppTheme.secondary;
      case 'verified':
        return AppTheme.warning;
      case 'resolved':
        return AppTheme.success;
      case 'rejected':
        return AppTheme.error;
      default:
        return AppTheme.textSecondary;
    }
  }

  static Color getStatusBgColor(String status) {
    return getStatusColor(status).withAlpha(20);
  }

  static String formatStatus(String status) {
    if (status.isEmpty) return 'Unknown';
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }
}
