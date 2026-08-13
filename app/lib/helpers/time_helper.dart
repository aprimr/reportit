class TimeHelper {
  TimeHelper._();

  static String timeAgo(String? timestampz) {
    if (timestampz == null || timestampz.isEmpty) return '';

    final DateTime past;
    try {
      past = DateTime.parse(timestampz);
    } catch (_) {
      return '';
    }

    final now = DateTime.now();
    final diff = now.difference(past);

    if (diff.isNegative) return 'just now';

    final seconds = diff.inSeconds;
    final minutes = diff.inMinutes;
    final hours = diff.inHours;
    final days = diff.inDays;
    final weeks = days ~/ 7;
    final months = days ~/ 30;
    final years = days ~/ 365;

    if (seconds < 1) return 'just now';
    if (seconds < 60) return seconds == 1 ? 'a sec ago' : '$seconds sec ago';
    if (minutes < 60) return minutes == 1 ? 'a min ago' : '$minutes min ago';
    if (hours < 24) return hours == 1 ? 'a hr ago' : '$hours hr ago';
    if (days < 7) return days == 1 ? 'a day ago' : '$days days ago';
    if (weeks < 5) return weeks == 1 ? 'a week ago' : '$weeks weeks ago';
    if (months < 12) return months == 1 ? 'a month ago' : '$months months ago';
    return years == 1 ? 'a year ago' : '$years years ago';
  }

  static String formatDate(
    String? timestampz, {
    String pattern = 'MMM dd, yyyy',
  }) {
    if (timestampz == null || timestampz.isEmpty) return '';

    final DateTime date;
    try {
      date = DateTime.parse(timestampz);
    } catch (_) {
      return '';
    }

    final months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return pattern
        .replaceAll('yyyy', '${date.year}')
        .replaceAll('MMM', months[date.month])
        .replaceAll('MM', date.month.toString().padLeft(2, '0'))
        .replaceAll('dd', date.day.toString().padLeft(2, '0'))
        .replaceAll('HH', date.hour.toString().padLeft(2, '0'))
        .replaceAll('mm', date.minute.toString().padLeft(2, '0'))
        .replaceAll('ss', date.second.toString().padLeft(2, '0'));
  }

  static String formatDateTime(String? timestampz) {
    if (timestampz == null || timestampz.isEmpty) return '';

    final DateTime date;
    try {
      date = DateTime.parse(timestampz).toLocal();
    } catch (_) {
      return '';
    }

    final months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final day = date.day;
    final month = months[date.month];
    final year = date.year;

    int hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final amPm = hour >= 12 ? 'pm' : 'am';

    if (hour == 0) {
      hour = 12;
    } else if (hour > 12) {
      hour = hour - 12;
    }

    return '$day $month $year, $hour:$minute $amPm';
  }
}
