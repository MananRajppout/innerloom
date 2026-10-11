import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Where the day is. Greeting and reflection both read this.
enum DayPhase { morning, afternoon, evening }

/// The clock for this launch. Tests can hold the morning still.
final Provider<DateTime Function()> clockProvider =
    Provider<DateTime Function()>((Ref ref) => DateTime.now);

abstract final class DayClock {
  static const int morningHour = 5;
  static const int afternoonHour = 12;
  static const int eveningHour = 17;

  static DayPhase phase(DateTime now) {
    final int hour = now.hour;
    if (hour >= morningHour && hour < afternoonHour) {
      return DayPhase.morning;
    }
    if (hour >= afternoonHour && hour < eveningHour) {
      return DayPhase.afternoon;
    }
    return DayPhase.evening;
  }
}
