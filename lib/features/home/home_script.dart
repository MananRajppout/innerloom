import '../../theme/app_durations.dart';
import 'day_clock.dart';

enum Arrival { calm, heavy, restless, hopeful, drained, focused, curious }

/// The few words on the first screen after arrival.
abstract final class HomeScript {
  static const String presence = "You don't have to solve everything today.";

  static const String question = 'How are you arriving today?';

  static const List<Arrival> arrivals = <Arrival>[
    Arrival.calm,
    Arrival.heavy,
    Arrival.restless,
    Arrival.hopeful,
    Arrival.drained,
    Arrival.focused,
    Arrival.curious,
  ];

  /// Greeting first. The sentence fades in, then silence, then the question.
  static Duration get sentenceDelay => AppDurations.entrance;

  static Duration get questionDelay =>
      AppDurations.entrance +
      AppDurations.fade +
      AppDurations.linePause +
      AppDurations.linePause;

  static Duration get cardsDelay =>
      questionDelay + AppDurations.fade + AppDurations.linePause;

  static Duration get cardStagger => AppDurations.beat;

  static Duration get responseDelay => AppDurations.linePause;

  /// A returning visit keeps one breath, then the room is simply there.
  static Duration get returnDelay => AppDurations.beat;

  static String greeting(DateTime now) {
    return switch (DayClock.phase(now)) {
      DayPhase.morning => 'Good morning',
      DayPhase.afternoon => 'Good afternoon',
      DayPhase.evening => 'Good evening',
    };
  }

  static String reflection(DateTime now) {
    return switch (DayClock.phase(now)) {
      DayPhase.evening => 'Night Reflection',
      DayPhase.morning || DayPhase.afternoon => 'Morning Reflection',
    };
  }

  static String label(Arrival arrival) {
    return switch (arrival) {
      Arrival.calm => 'Calm',
      Arrival.heavy => 'Heavy',
      Arrival.restless => 'Restless',
      Arrival.hopeful => 'Hopeful',
      Arrival.drained => 'Drained',
      Arrival.focused => 'Focused',
      Arrival.curious => 'Curious',
    };
  }

  static String response(Arrival arrival) {
    return switch (arrival) {
      Arrival.calm => 'Then we can stay with this.',
      Arrival.heavy => "I'm glad you didn't carry it alone.",
      Arrival.restless =>
        "We don't have to slow every thought.\nJust this moment.",
      Arrival.hopeful => "I'll meet you here.",
      Arrival.drained => 'You can set it down.',
      Arrival.focused => 'Then this can stay simple.',
      Arrival.curious => 'We can look slowly.',
    };
  }
}
