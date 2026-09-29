import 'dart:async';

import 'package:flutter/material.dart';

import '../../../theme/app_durations.dart';
import '../../../theme/app_spacing.dart';
import '../onboarding_script.dart';
import 'typing_text.dart';

/// Future Self, one line at a time. [skip] shows every line at once.
class FutureSelfMessage extends StatefulWidget {
  const FutureSelfMessage({
    super.key,
    required this.lines,
    required this.onFinished,
    this.skip = false,
  });

  final List<FutureSelfLine> lines;
  final VoidCallback onFinished;
  final bool skip;

  @override
  State<FutureSelfMessage> createState() => _FutureSelfMessageState();
}

class _FutureSelfMessageState extends State<FutureSelfMessage> {
  int _index = 0;
  bool _finished = false;
  bool _notified = false;
  bool _reduceMotion = false;
  Timer? _pause;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    _finishIfInstant();
  }

  @override
  void didUpdateWidget(FutureSelfMessage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.skip && !oldWidget.skip) {
      _pause?.cancel();
      _finished = true;
      _notify();
    }
  }

  @override
  void dispose() {
    _pause?.cancel();
    super.dispose();
  }

  void _finishIfInstant() {
    if (_notified || _finished) {
      return;
    }
    if (!_reduceMotion && !widget.skip) {
      return;
    }
    _finished = true;
    _notify();
  }

  void _notify() {
    if (_notified) {
      return;
    }
    _notified = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onFinished();
      }
    });
  }

  void _onLineComplete() {
    if (!mounted || _finished || widget.skip) {
      return;
    }
    if (_index >= widget.lines.length - 1) {
      setState(() => _finished = true);
      _notify();
      return;
    }
    final Duration pause = AppDurations.resolve(
      context,
      widget.lines[_index].pauseAfter,
    );
    _pause?.cancel();
    _pause = Timer(pause, () {
      if (!mounted || _finished || widget.skip) {
        return;
      }
      setState(() => _index += 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle style =
        Theme.of(context).textTheme.headlineSmall ?? const TextStyle();
    final bool showAll = _finished || widget.skip || _reduceMotion;
    final int last = showAll ? widget.lines.length : _index + 1;

    return Column(
      children: <Widget>[
        for (int i = 0; i < last; i++) ...<Widget>[
          if (i > 0) const SizedBox(height: AppSpacing.md),
          if (showAll || i < _index)
            Text(
              widget.lines[i].text,
              textAlign: TextAlign.center,
              style: style,
            )
          else
            TypingText(
              key: ValueKey<int>(i),
              text: widget.lines[i].text,
              style: style,
              onComplete: _onLineComplete,
            ),
        ],
      ],
    );
  }
}
