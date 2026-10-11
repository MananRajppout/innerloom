import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_durations.dart';
import '../../../theme/app_spacing.dart';
import '../../onboarding/models/onboarding_answers.dart';
import '../../onboarding/providers/onboarding_controller.dart';
import '../../reflection/reflection_screen.dart';
import '../day_clock.dart';
import '../home_script.dart';
import '../home_visit.dart';
import '../widgets/arrival_response.dart';
import '../widgets/arrival_selector.dart';
import '../widgets/home_greeting.dart';
import '../../../ui/quiet_fade.dart';

/// The first room after arrival. Words only, under the orb that is already here.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, this.now});

  final DateTime Function()? now;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  final List<Timer> _opening = <Timer>[];
  final GlobalKey _responseKey = GlobalKey();

  Timer? _responseTimer;

  bool _opened = false;
  bool _reduce = false;
  bool _sentence = false;
  bool _question = false;
  int _shown = 0;
  Arrival? _selected;
  bool _response = false;
  bool _reflecting = false;
  bool _replyReady = false;
  DateTime? _finishedOn;
  String _draft = '';

  DateTime _now() => widget.now?.call() ?? ref.read(clockProvider)();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduce = MediaQuery.disableAnimationsOf(context);
    if (_opened) {
      return;
    }
    _opened = true;
    final bool returning = ref.read(homeVisitProvider);
    if (_reduce) {
      _sentence = true;
      _question = true;
      _shown = HomeScript.arrivals.length;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _markSeen();
        }
      });
      return;
    }
    if (returning) {
      _opening.add(
        Timer(HomeScript.returnDelay, () {
          if (!mounted) {
            return;
          }
          setState(() {
            _sentence = true;
            _question = true;
            _shown = HomeScript.arrivals.length;
          });
          _markSeen();
        }),
      );
      return;
    }
    _opening.add(
      Timer(HomeScript.sentenceDelay, () {
        if (mounted) {
          setState(() => _sentence = true);
        }
      }),
    );
    _opening.add(
      Timer(HomeScript.questionDelay, () {
        if (mounted) {
          setState(() => _question = true);
        }
      }),
    );
    for (var i = 0; i < HomeScript.arrivals.length; i++) {
      final int index = i;
      _opening.add(
        Timer(HomeScript.cardsDelay + (HomeScript.cardStagger * index), () {
          if (!mounted) {
            return;
          }
          setState(() => _shown = index + 1);
          if (index == HomeScript.arrivals.length - 1) {
            _markSeen();
          }
        }),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    for (final Timer timer in _opening) {
      timer.cancel();
    }
    _responseTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _releaseStaleRitual();
    }
  }

  void _markSeen() {
    unawaited(ref.read(homeVisitProvider.notifier).mark());
  }

  void _choose(Arrival arrival) {
    final bool alreadyAnswered = _response;
    setState(() {
      _selected = arrival;
      if (_reduce) {
        _response = true;
      }
    });
    _markSeen();
    if (_reduce || alreadyAnswered) {
      _reveal();
      return;
    }
    _responseTimer?.cancel();
    _responseTimer = Timer(HomeScript.responseDelay, () {
      if (!mounted) {
        return;
      }
      setState(() => _response = true);
      _reveal();
    });
  }

  /// Brings the reply into view. A tap schedules this during the current
  /// frame, so a missing target waits for the frame after.
  void _reveal() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_show()) {
        return;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) => _show());
    });
  }

  bool _show() {
    final BuildContext? target = _responseKey.currentContext;
    if (target == null || !target.mounted) {
      return false;
    }
    Scrollable.ensureVisible(
      target,
      alignment: 1,
      duration: AppDurations.resolve(target, AppDurations.fade),
      curve: AppDurations.curve,
    );
    return true;
  }

  bool _closedToday() {
    final DateTime? finished = _finishedOn;
    return finished != null && DayClock.sameDay(finished, _now());
  }

  bool _morningDoor() {
    return !_closedToday() &&
        DayClock.phase(_now()) != DayPhase.evening &&
        _shown == HomeScript.arrivals.length;
  }

  /// A finished ritual belongs to the day it ended. The next morning opens again.
  void _releaseStaleRitual() {
    if (_finishedOn == null || _closedToday()) {
      return;
    }
    setState(() {
      _finishedOn = null;
      _draft = '';
      _replyReady = false;
      _reflecting = false;
    });
  }

  void _closeReflection(bool finished) {
    if (!mounted) {
      return;
    }
    setState(() {
      _reflecting = false;
      _replyReady = false;
      if (finished) {
        _draft = '';
        final DateTime now = _now();
        _finishedOn = DateTime(now.year, now.month, now.day);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _releaseStaleRitualIfNeeded();
    return PopScope(
      canPop: !_reflecting,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop || !_reflecting) {
          return;
        }
        _closeReflection(_replyReady);
      },
      child: _reflecting
          ? ReflectionScreen(
              draft: _draft,
              onDraft: (String value) => _draft = value,
              onReplied: () => _replyReady = true,
              onLeave: () => _closeReflection(true),
            )
          : _room(context),
    );
  }

  void _releaseStaleRitualIfNeeded() {
    if (_finishedOn == null || _closedToday()) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _releaseStaleRitual();
      }
    });
  }

  Widget _room(BuildContext context) {
    final String name = ref.watch(
      onboardingProvider.select((OnboardingAnswers answers) => answers.name),
    );
    final TextTheme text = Theme.of(context).textTheme;
    final Arrival? selected = _selected;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double minHeight = constraints.maxHeight.isFinite
            ? math.max(0, constraints.maxHeight - AppSpacing.lg - AppSpacing.xl)
            : 0;
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screen,
            AppSpacing.lg,
            AppSpacing.screen,
            AppSpacing.xl,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                QuietFade(
                  child: HomeGreeting(
                    greeting: HomeScript.greeting(_now()),
                    name: name,
                  ),
                ),
                if (_sentence) ...<Widget>[
                  const SizedBox(height: AppSpacing.lg),
                  QuietFade(
                    child: Text(
                      HomeScript.presence,
                      textAlign: TextAlign.center,
                      style: text.headlineSmall,
                    ),
                  ),
                ],
                if (_question) ...<Widget>[
                  const SizedBox(height: AppSpacing.xxl),
                  QuietFade(
                    child: Text(
                      HomeScript.question,
                      textAlign: TextAlign.center,
                      style: text.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
                if (_shown > 0) ...<Widget>[
                  const SizedBox(height: AppSpacing.lg),
                  ArrivalSelector(
                    visibleCount: _shown,
                    selected: selected,
                    onSelected: _choose,
                  ),
                ],
                if (_response && selected != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.xl),
                  KeyedSubtree(
                    key: _responseKey,
                    child: Column(
                      children: <Widget>[
                        ArrivalResponse(
                          key: ValueKey<Arrival>(selected),
                          text: HomeScript.response(selected),
                        ),
                        if (_morningDoor()) _reflectionDoor(text),
                      ],
                    ),
                  ),
                ],
                if (_morningDoor() && !_response) _reflectionDoor(text),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _reflectionDoor(TextTheme text) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: QuietFade(
        child: TextButton(
          onPressed: () => setState(() {
            _replyReady = false;
            _reflecting = true;
          }),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            textStyle: text.bodyLarge,
            minimumSize: const Size(48, 48),
          ),
          child: Text(HomeScript.reflection(_now())),
        ),
      ),
    );
  }
}
