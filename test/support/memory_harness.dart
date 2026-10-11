import 'package:flutter_riverpod/misc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:loop_break/core/persistence/local_memory.dart';

Future<SharedPreferences> openMemory([
  Map<String, Object> seed = const <String, Object>{},
]) async {
  SharedPreferences.setMockInitialValues(seed);
  return SharedPreferences.getInstance();
}

List<Override> memoryScope(SharedPreferences prefs) {
  return <Override>[sharedPreferencesProvider.overrideWithValue(prefs)];
}
