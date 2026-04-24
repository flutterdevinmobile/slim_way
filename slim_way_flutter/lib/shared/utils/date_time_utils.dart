import 'package:slim_way_client/slim_way_client.dart';

class DateTimeUtils {
  /// Returns a [DateTime] representing the start of the day (00:00:00) for the given date.
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Returns a [DateTime] representing the end of the day (23:59:59) for the given date.
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  /// Checks if a [DateTime] falls within a specific day.
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  /// Filters a list of walks to only include those from the current day.
  static List<Walk> filterToday(List<Walk> history) {
    final today = startOfDay(DateTime.now());
    return history.where((walk) => isSameDay(walk.createdAt.toLocal(), today)).toList();
  }
}
