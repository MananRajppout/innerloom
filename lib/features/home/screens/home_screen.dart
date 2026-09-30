import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_durations.dart';
import '../../../theme/app_spacing.dart';
import '../../onboarding/models/onboarding_answers.dart';
import '../../onboarding/providers/onboarding_controller.dart';
import '../home_script.dart';
import '../home_visit.dart';
import '../widgets/arrival_response.dart';
import '../widgets/arrival_selector.dart';
import '../widgets/home_greeting.dart';
import '../widgets/quiet_fade.dart';

/// The first room after arrival. Words only, under the orb that is already here.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, this.now});

  final DateTime Function()? now;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
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

  DateTime _now() => widget.now?.call() ?? DateTime.now();

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
    for (final Timer timer in _opening) {
      timer.cancel();
    }
    _responseTimer?.cancel();
    super.dispose();
  }

  void _markSeen() {
    ref.read(homeVisitProvider.notifier).mark();
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

  @override
  Widget build(BuildContext context) {
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
                    child: ArrivalResponse(
                      key: ValueKey<Arrival>(selected),
                      text: HomeScript.response(selected),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
