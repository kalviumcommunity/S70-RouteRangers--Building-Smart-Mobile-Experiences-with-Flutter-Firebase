import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  /// Formats a DateTime into a friendly relative time (e.g., "5m ago", "2h ago", "Yesterday", or "Oct 12")
  static String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, yyyy').format(dateTime);
    }
  }

  static String formatFullDate(DateTime dateTime) {
    return DateFormat('MMMM d, yyyy · h:mm a').format(dateTime);
  }
}
