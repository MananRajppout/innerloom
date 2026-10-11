import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/persistence/local_memory.dart';

/// Whether the opening has already played on this device.
final NotifierProvider<HomeVisit, bool> homeVisitProvider =
    NotifierProvider<HomeVisit, bool>(HomeVisit.new);

class HomeVisit extends Notifier<bool> {
  @override
  bool build() => ref.read(localMemoryProvider).homeSeen;

  Future<void> mark() async {
    if (state) {
      return;
    }
    state = true;
    await ref.read(localMemoryProvider).markHomeSeen();
  }
}
