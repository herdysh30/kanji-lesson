import 'package:intl/intl.dart';

/// Date utility helpers for SRS and progress tracking
class AppDateUtils {
  AppDateUtils._();

  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  /// Format DateTime to date string (yyyy-MM-dd)
  static String formatDate(DateTime date) => _dateFormat.format(date);

  /// Parse date string to DateTime
  static DateTime parseDate(String date) => _dateFormat.parse(date);

  /// Get today's date string
  static String todayString() => formatDate(DateTime.now());

  /// Check if a date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if a date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Calculate days between two dates
  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  /// Calculate next review date given interval in days
  static DateTime nextReviewDate(int intervalDays) {
    return DateTime.now().add(Duration(days: intervalDays));
  }

  /// Calculate next review date from minutes (for "Again" rating)
  static DateTime nextReviewFromMinutes(int minutes) {
    return DateTime.now().add(Duration(minutes: minutes));
  }

  /// Check if a review is overdue
  static bool isOverdue(DateTime? nextReviewAt) {
    if (nextReviewAt == null) return false;
    return DateTime.now().isAfter(nextReviewAt);
  }

  /// Get relative time description
  static String relativeTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 365) return '${diff.inDays ~/ 365}y ago';
    if (diff.inDays > 30) return '${diff.inDays ~/ 30}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  /// Calculate streak from list of daily progress dates
  static int calculateStreak(List<String> dates) {
    if (dates.isEmpty) return 0;

    final sortedDates = dates.toList()..sort((a, b) => b.compareTo(a));
    final today = todayString();
    final yesterday = formatDate(
      DateTime.now().subtract(const Duration(days: 1)),
    );

    // Streak must include today or yesterday
    if (sortedDates.first != today && sortedDates.first != yesterday) {
      return 0;
    }

    int streak = 1;
    for (int i = 0; i < sortedDates.length - 1; i++) {
      final current = parseDate(sortedDates[i]);
      final previous = parseDate(sortedDates[i + 1]);
      final diff = daysBetween(previous, current);

      if (diff == 1) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }
}
