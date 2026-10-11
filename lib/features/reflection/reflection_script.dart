import '../../theme/app_durations.dart';

/// One morning question, one reply, then the ritual is over.
abstract final class ReflectionScript {
  static const String question = 'What is true for you this morning?';

  static const String hint = 'In your own words';

  static const String offer = "That's enough";

  static const String response = 'I heard you. Nothing else is asked of you.';

  static const String leave = 'Leave it here';

  /// One breath between their words and the reply.
  static Duration get replyDelay => AppDurations.linePause;
}
