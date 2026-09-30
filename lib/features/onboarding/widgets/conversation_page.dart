import 'package:flutter/material.dart';

import '../../../theme/app_durations.dart';
import '../../../theme/app_spacing.dart';

/// The words can scroll. The action stays on screen.
class ConversationPage extends StatefulWidget {
  const ConversationPage({
    super.key,
    required this.child,
    this.footer,
    this.followLatest = false,
  });

  final Widget child;
  final Widget? footer;

  /// When words grow past the fold, keep the newest line in view.
  final bool followLatest;

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final ScrollController _scroll = ScrollController();
  double _knownExtent = 0;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _keepLatestInView() {
    if (!widget.followLatest) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) {
        return;
      }
      final double max = _scroll.position.maxScrollExtent;
      if (max <= _knownExtent || max <= 0) {
        _knownExtent = max;
        return;
      }
      _knownExtent = max;
      final Duration duration = AppDurations.resolve(
        context,
        AppDurations.fade,
      );
      if (duration == Duration.zero) {
        _scroll.jumpTo(max);
        return;
      }
      _scroll.animateTo(max, duration: duration, curve: AppDurations.curve);
    });
  }

  @override
  Widget build(BuildContext context) {
    _keepLatestInView();
    return Column(
      children: <Widget>[
        Expanded(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double verticalPadding = AppSpacing.lg * 2;
              final double minHeight = constraints.maxHeight > verticalPadding
                  ? constraints.maxHeight - verticalPadding
                  : 0;
              return SingleChildScrollView(
                controller: _scroll,
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screen,
                  vertical: AppSpacing.lg,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: minHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[widget.child],
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.footer != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.sm,
              AppSpacing.screen,
              AppSpacing.xl,
            ),
            child: widget.footer!,
          ),
      ],
    );
  }
}
