import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'day_clock.dart';
import 'screens/home_screen.dart';

/// One Home for one calendar day.
///
/// A new day replaces [HomeScreen], so yesterday's arrival, reply, draft,
/// and finished ritual leave with it.
class HomeDay extends ConsumerStatefulWidget {
  const HomeDay({super.key, this.now});

  final DateTime Function()? now;

  @override
  ConsumerState<HomeDay> createState() => _HomeDayState();
}

class _HomeDayState extends ConsumerState<HomeDay> with WidgetsBindingObserver {
  late DateTime _day;
  Timer? _midnight;

  DateTime _now() => widget.now?.call() ?? ref.read(clockProvider)();

  DateTime _date(DateTime now) => DateTime(now.year, now.month, now.day);

  @override
  void initState() {
    super.initState();
    _day = _date(_now());
    WidgetsBinding.instance.addObserver(this);
    _arm();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _midnight?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _roll();
    }
  }

  /// Wakes at the next midnight, and again if the process slept through it.
  void _arm() {
    _midnight?.cancel();
    final DateTime now = _now();
    final DateTime next = DateTime(now.year, now.month, now.day + 1);
    final Duration wait = next.difference(now);
    _midnight = Timer(
      wait <= Duration.zero ? const Duration(minutes: 1) : wait,
      () {
        if (mounted) {
          _roll();
        }
      },
    );
  }

  void _roll() {
    final DateTime today = _date(_now());
    if (today.isAfter(_day)) {
      setState(() => _day = today);
    }
    _arm();
  }

  @override
  Widget build(BuildContext context) {
    return HomeScreen(key: ValueKey<DateTime>(_day), now: widget.now);
  }
}
