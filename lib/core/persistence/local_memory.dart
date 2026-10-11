import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/onboarding/models/onboarding_answers.dart';

/// Loaded in [main] before the first frame. Tests pass their own store.
final Provider<SharedPreferences> sharedPreferencesProvider =
    Provider<SharedPreferences>((Ref ref) {
      throw StateError('Local memory is loaded before Innerloom starts.');
    });

final Provider<LocalMemory> localMemoryProvider = Provider<LocalMemory>((
  Ref ref,
) {
  return LocalMemory(ref.watch(sharedPreferencesProvider));
});

/// The few things Future Self keeps on this device.
///
/// A refusal keeps the fact that arrival finished, the answer itself, and
/// whether the opening has already played. The name, what matters, and the
/// loop are written only when they said yes.
class LocalMemory {
  const LocalMemory(this._prefs);

  static const String _completed = 'completed';
  static const String _mayRemember = 'mayRemember';
  static const String _name = 'name';
  static const String _whatMatters = 'whatMatters';
  static const String _currentLoop = 'currentLoop';
  static const String _homeSeen = 'homeSeen';

  final SharedPreferences _prefs;

  bool get homeSeen => _prefs.getBool(_homeSeen) ?? false;

  OnboardingAnswers restore() {
    final bool completed = _prefs.getBool(_completed) ?? false;
    if (!completed) {
      return const OnboardingAnswers();
    }
    final bool allowed = _prefs.getBool(_mayRemember) ?? false;
    if (!allowed) {
      return const OnboardingAnswers(
        step: OnboardingStep.complete,
        mayRemember: false,
        completed: true,
      );
    }
    return OnboardingAnswers(
      step: OnboardingStep.complete,
      name: _prefs.getString(_name) ?? '',
      whatMatters: _prefs.getString(_whatMatters) ?? '',
      currentLoop: _prefs.getString(_currentLoop) ?? '',
      mayRemember: true,
      completed: true,
    );
  }

  Future<void> remember(OnboardingAnswers answers) async {
    await _prefs.setBool(_completed, answers.completed);
    await _prefs.setBool(_mayRemember, answers.mayRemember == true);
    if (answers.mayRemember == true) {
      await _prefs.setString(_name, answers.name);
      await _prefs.setString(_whatMatters, answers.whatMatters);
      await _prefs.setString(_currentLoop, answers.currentLoop);
      return;
    }
    await _prefs.remove(_name);
    await _prefs.remove(_whatMatters);
    await _prefs.remove(_currentLoop);
  }

  Future<void> markHomeSeen() => _prefs.setBool(_homeSeen, true);
}
