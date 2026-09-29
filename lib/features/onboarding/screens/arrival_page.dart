import 'dart:async';

import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_durations.dart';
import '../../../theme/app_spacing.dart';
import '../widgets/conversation_page.dart';
import '../widgets/minimal_button.dart';

/// The room, before anything is asked.
class ArrivalPage extends StatefulWidget {
  const ArrivalPage({super.key, required this.onBegin});

  final VoidCallback onBegin;

  @override
  State<ArrivalPage> createState() => _ArrivalPageState();
}

class _ArrivalPageState extends State<ArrivalPage> {
  Timer? _reveal;
  bool _visible = false;
  bool _scheduled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_scheduled) {
      return;
    }
    _scheduled = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _visible = true;
      return;
    }
    _reveal = Timer(AppDurations.reveal, () {
      if (!mounted) {
        return;
      }
      setState(() => _visible = true);
    });
  }

  @override
  void dispose() {
    _reveal?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return ConversationPage(
      footer: _visible
          ? TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: AppDurations.resolve(context, AppDurations.fade),
              curve: AppDurations.curve,
              builder: (BuildContext context, double value, Widget? child) {
                return Opacity(opacity: value, child: child);
              },
              child: MinimalButton(label: 'Begin', onPressed: widget.onBegin),
            )
          : const SizedBox(height: 48),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: <Widget>[
            ExcludeSemantics(
              child: Text(
                'Future Self',
                textAlign: TextAlign.center,
                style: text.headlineMedium,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              "I'm here.",
              textAlign: TextAlign.center,
              style: text.bodyLarge?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
