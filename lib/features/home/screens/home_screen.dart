import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_durations.dart';
import '../../../theme/app_spacing.dart';
import '../../onboarding/models/onboarding_answers.dart';
import '../../onboarding/providers/onboarding_controller.dart';
import '../../onboarding/widgets/minimal_button.dart';
import '../home_script.dart';
import '../widgets/arrival_response.dart';
import '../widgets/arrival_selector.dart';
import '../widgets/home_greeting.dart';

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
  Timer? _actionTimer;

  bool _opened = false;
  bool _reduce = false;
  bool _sentence = false;
  bool _question = false;
  int _shown = 0;
  Arrival? _selected;
  bool _response = false;
  bool _action = false;

  DateTime _now() => widget.now?.call() ?? DateTime.now();

  /// The reflection room is the next room. This screen only shows the door.
  void _openReflection() {}

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduce = MediaQuery.disableAnimationsOf(context);
    if (_opened) {
      return;
    }
    _opened = true;
    if (_reduce) {
      _sentence = true;
      _question = true;
      _shown = HomeScript.arrivals.length;
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
      _opening.add(
        Timer(HomeScript.cardsDelay + (HomeScript.cardStagger * i), () {
          if (mounted) {
            setState(() => _shown = i + 1);
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
    _actionTimer?.cancel();
    super.dispose();
  }

  void _choose(Arrival arrival) {
    setState(() {
      _selected = arrival;
      if (_reduce) {
        _response = true;
        _action = true;
      }
    });
    if (_reduce) {
      _reveal(_responseKey, alignment: 1);
      return;
    }
    if (_response) {
      _reveal(_responseKey, alignment: 1);
      return;
    }
    _responseTimer?.cancel();
    _actionTimer?.cancel();
    _responseTimer = Timer(HomeScript.responseDelay, () {
      if (!mounted) {
        return;
      }
      setState(() => _response = true);
      _reveal(_responseKey, alignment: 0.2);
      _actionTimer = Timer(HomeScript.actionDelay, () {
        if (!mounted) {
          return;
        }
        setState(() => _action = true);
        _reveal(_responseKey, alignment: 1);
      });
    });
  }

  /// Brings the reply into view once it exists. A tap schedules this during
  /// the current frame, so a missing target waits for the frame after.
  void _reveal(GlobalKey key, {required double alignment}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_show(key, alignment)) {
        return;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _show(key, alignment);
      });
    });
  }

  bool _show(GlobalKey key, double alignment) {
    final BuildContext? target = key.currentContext;
    if (target == null || !target.mounted) {
      return false;
    }
    Scrollable.ensureVisible(
      target,
      alignment: alignment,
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
                _QuietFade(
                  child: HomeGreeting(
                    greeting: HomeScript.greeting(_now()),
                    name: name,
                  ),
                ),
                if (_sentence) ...<Widget>[
                  const SizedBox(height: AppSpacing.lg),
                  _QuietFade(
                    child: Text(
                      HomeScript.presence,
                      textAlign: TextAlign.center,
                      style: text.headlineSmall,
                    ),
                  ),
                ],
                if (_question) ...<Widget>[
                  const SizedBox(height: AppSpacing.xxl),
                  _QuietFade(
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
                  const SizedBox(height: AppSpacing.xl),
                  ArrivalSelector(
                    visibleCount: _shown,
                    selected: selected,
                    onSelected: _choose,
                  ),
                ],
                if (_response && selected != null)
                  KeyedSubtree(
                    key: _responseKey,
                    child: Column(
                      children: <Widget>[
                        const SizedBox(height: AppSpacing.xl),
                        ArrivalResponse(
                          key: ValueKey<Arrival>(selected),
                          text: HomeScript.response(selected),
                        ),
                        if (_action) ...<Widget>[
                          const SizedBox(height: AppSpacing.xl),
                          Center(
                            child: _QuietFade(
                              child: MinimalButton(
                                label: HomeScript.reflection(_now()),
                                onPressed: _openReflection,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _QuietFade extends StatefulWidget {
  const _QuietFade({required this.child});

  final Widget child;

  @override
  State<_QuietFade> createState() => _QuietFadeState();
}

class _QuietFadeState extends State<_QuietFade> {
  double _opacity = 0;
  bool _armed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_armed) {
      return;
    }
    _armed = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _opacity = 1;
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _opacity = 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: AppDurations.resolve(context, AppDurations.fade),
      curve: AppDurations.curve,
      child: widget.child,
    );
  }
}
