String getWeekdayName(int day, {int? month, int? year}) {
  // Use current date if month/year not provided
  final now = DateTime.now();
  final targetMonth = month ?? now.month;
  final targetYear = year ?? now.year;

  // Create DateTime for the given day
  final date = DateTime(targetYear, targetMonth, day);

  // Get weekday (1 = Monday, 7 = Sunday)
  final weekday = date.weekday;

  switch (weekday) {
    case 1:
      return 'Monday';
    case 2:
      return 'Tuesday';
    case 3:
      return 'Wednesday';
    case 4:
      return 'Thursday';
    case 5:
      return 'Friday';
    case 6:
      return 'Saturday';
    case 7:
      return 'Sunday';
    default:
      return 'Unknown';
  }
}
