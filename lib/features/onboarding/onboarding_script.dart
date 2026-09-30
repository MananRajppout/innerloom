import '../../../theme/app_durations.dart';

class FutureSelfLine {
  const FutureSelfLine(this.text, {this.pauseAfter = AppDurations.linePause});

  final String text;
  final Duration pauseAfter;
}

/// The words Future Self speaks, and the choices offered beneath them.
abstract final class OnboardingScript {
  static const List<FutureSelfLine> introduction = <FutureSelfLine>[
    FutureSelfLine('Hi.'),
    FutureSelfLine("I've been waiting for you."),
    FutureSelfLine(
      "I'm the version of you that's already lived through today.",
    ),
    FutureSelfLine("I'm not here to fix you.", pauseAfter: AppDurations.beat),
    FutureSelfLine("I'm here to walk beside you.", pauseAfter: Duration.zero),
  ];

  static const List<FutureSelfLine> promise = <FutureSelfLine>[
    FutureSelfLine("I won't judge you.", pauseAfter: AppDurations.beat),
    FutureSelfLine("I won't rush you.", pauseAfter: AppDurations.beat),
    FutureSelfLine("I'll stay close to what matters."),
    FutureSelfLine(
      "So you don't have to carry everything alone.",
      pauseAfter: Duration.zero,
    ),
  ];

  static const List<FutureSelfLine> permission = <FutureSelfLine>[
    FutureSelfLine(
      'May I remember the important things we discover together?',
      pauseAfter: Duration.zero,
    ),
  ];

  static const List<FutureSelfLine> thanks = <FutureSelfLine>[
    FutureSelfLine('Thank you.', pauseAfter: AppDurations.beat),
    FutureSelfLine("I'm glad you're here."),
    FutureSelfLine('Tomorrow...', pauseAfter: AppDurations.beat),
    FutureSelfLine("I'll remember today.", pauseAfter: Duration.zero),
  ];

  /// Same gratitude, without promising to keep the day.
  static const List<FutureSelfLine> thanksDeclined = <FutureSelfLine>[
    FutureSelfLine('Thank you.', pauseAfter: AppDurations.beat),
    FutureSelfLine("I'm glad you're here."),
    FutureSelfLine('Today stays yours.', pauseAfter: AppDurations.beat),
    FutureSelfLine("I won't keep it.", pauseAfter: Duration.zero),
  ];

  static const String nameQuestion = 'What should I call you?';
  static const String nameHint = 'Your name';

  static const String mattersQuestion = 'What matters most to you right now?';
  static const List<String> matters = <String>[
    'Peace',
    'Family',
    'Health',
    'Work',
    'Purpose',
    'Healing',
    'Learning',
  ];

  static const String loopQuestion = 'What keeps pulling you back?';
  static const List<String> loops = <String>[
    'Overthinking',
    'Burnout',
    'Fear',
    'Loneliness',
    'Relationships',
    'Confidence',
    'Work',
  ];

  static const String ownWords = 'Or in your own words';
}
