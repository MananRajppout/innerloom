import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_durations.dart';
import '../../../theme/app_spacing.dart';
import '../onboarding_script.dart';
import '../widgets/conversation_page.dart';
import '../widgets/future_self_message.dart';
import '../widgets/minimal_button.dart';

/// Future Self speaks. Continue appears when the words have arrived.
class SpokenPage extends StatefulWidget {
  const SpokenPage({
    super.key,
    required this.lines,
    required this.footer,
  });

  final List<FutureSelfLine> lines;

  /// Built once the lines are finished, or once they have been skipped.
  final Widget Function(BuildContext context) footer;

  @override
  State<SpokenPage> createState() => _SpokenPageState();
}

class _SpokenPageState extends State<SpokenPage> {
  bool _ready = false;
  bool _skip = false;

  void _finish() {
    if (!mounted || _ready) {
      return;
    }
    setState(() => _ready = true);
  }

  void _skipNow() {
    setState(() => _skip = true);
    _finish();
  }

  @override
  Widget build(BuildContext context) {
    return ConversationPage(
      footer: AnimatedSwitcher(
        duration: AppDurations.resolve(context, AppDurations.fade),
        switchInCurve: AppDurations.curve,
        switchOutCurve: AppDurations.curve,
        child: _ready
            ? KeyedSubtree(
                key: const ValueKey<String>('ready'),
                child: widget.footer(context),
              )
            : TextButton(
                key: const ValueKey<String>('skip'),
                onPressed: _skipNow,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textTertiary,
                  textStyle: Theme.of(context).textTheme.titleSmall,
                  minimumSize: const Size(48, 48),
                ),
                child: const Text('Skip'),
              ),
      ),
      child: FutureSelfMessage(
        lines: widget.lines,
        skip: _skip,
        onFinished: _finish,
      ),
    );
  }
}

/// Two equal choices. Neither one is dressed as the right answer.
class PermissionActions extends StatelessWidget {
  const PermissionActions({
    super.key,
    required this.onYes,
    required this.onNotYet,
  });

  final VoidCallback onYes;
  final VoidCallback onNotYet;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _wide(MinimalButton(label: 'Yes', onPressed: onYes)),
        const SizedBox(height: AppSpacing.sm),
        _wide(MinimalButton(label: 'Not yet', onPressed: onNotYet)),
      ],
    );
  }

  Widget _wide(Widget child) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: AppSpacing.huge * 2),
      child: child,
    );
  }
}
