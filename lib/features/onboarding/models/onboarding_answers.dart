/// What the person offered during arrival, kept in memory for this session.
class OnboardingAnswers {
  const OnboardingAnswers({
    this.step = OnboardingStep.arrival,
    this.name = '',
    this.whatMatters = '',
    this.currentLoop = '',
    this.mayRemember,
    this.completed = false,
  });

  final OnboardingStep step;
  final String name;
  final String whatMatters;
  final String currentLoop;

  /// Null until they answer. False means "Not yet", and that answer stands.
  final bool? mayRemember;
  final bool completed;

  OnboardingAnswers copyWith({
    OnboardingStep? step,
    String? name,
    String? whatMatters,
    String? currentLoop,
    bool? mayRemember,
    bool updateMemory = false,
    bool? completed,
  }) {
    return OnboardingAnswers(
      step: step ?? this.step,
      name: name ?? this.name,
      whatMatters: whatMatters ?? this.whatMatters,
      currentLoop: currentLoop ?? this.currentLoop,
      mayRemember: updateMemory ? mayRemember : this.mayRemember,
      completed: completed ?? this.completed,
    );
  }
}

enum OnboardingStep {
  arrival,
  introduction,
  name,
  whatMatters,
  currentLoop,
  promise,
  permission,
  complete,
}
