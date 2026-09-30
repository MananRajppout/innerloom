import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether this session has already opened the day.
///
/// Nothing is written down. A later restore can set the same flag.
final NotifierProvider<HomeVisit, bool> homeVisitProvider =
    NotifierProvider<HomeVisit, bool>(HomeVisit.new);

class HomeVisit extends Notifier<bool> {
  @override
  bool build() => false;

  void mark() {
    if (state) {
      return;
    }
    state = true;
  }
}
