import 'package:app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ComplaintHelper {
  static Color getStatusColor(String status) {
    switch (status.toLowerCase().trim()) {
      case 'open':
        return AppTheme.warning;
      case 'verified':
        return AppTheme.secondary;
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

  static String extractTrackingId(String id, String createdAt) {
    final uuid = id.replaceAll('-', '').toUpperCase();

    if (uuid.length < 32) {
      throw ArgumentError('Invalid UUID');
    }

    final dateTime = DateTime.parse(createdAt);

    final timePart =
        '${dateTime.minute.toString().padLeft(2, '0')}'
        '${dateTime.second.toString().padLeft(2, '0')}';

    final part1 = '${uuid[7]}${uuid[6]}${uuid[4]}${uuid[5]}';
    final part2 = '${uuid[30]}${uuid[29]}${uuid[27]}${uuid[28]}';

    return '#CMP-$timePart-$part1-$part2';
  }
}
