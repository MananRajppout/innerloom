import 'dart:async';

import 'package:flutter/material.dart';

import '../../../theme/app_durations.dart';

/// Reveals one sentence at a speaking pace. A period holds a little longer.
class TypingText extends StatefulWidget {
  const TypingText({
    super.key,
    required this.text,
    required this.style,
    this.onComplete,
  });

  final String text;
  final TextStyle style;
  final VoidCallback? onComplete;

  @override
  State<TypingText> createState() => _TypingTextState();
}

class _TypingTextState extends State<TypingText> {
  Timer? _timer;
  int _count = 0;
  bool _completed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_completed || _timer != null) {
      return;
    }
    if (MediaQuery.disableAnimationsOf(context) || widget.text.isEmpty) {
      _finish();
      return;
    }
    _scheduleNext();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _scheduleNext() {
    if (_count >= widget.text.length) {
      _finish();
      return;
    }
    final Duration delay = _count == 0
        ? AppDurations.typing
        : (_holds(widget.text[_count - 1])
              ? AppDurations.beat
              : AppDurations.typing);
    _timer = Timer(delay, () {
      if (!mounted || _completed) {
        return;
      }
      setState(() => _count += 1);
      _scheduleNext();
    });
  }

  bool _holds(String character) {
    return character == '.' ||
        character == ',' ||
        character == '?' ||
        character == '…';
  }

  void _finish() {
    _timer?.cancel();
    if (_completed) {
      return;
    }
    _completed = true;
    if (_count != widget.text.length) {
      setState(() => _count = widget.text.length);
    }
    final VoidCallback? onComplete = widget.onComplete;
    if (onComplete == null) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        onComplete();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final String visible = widget.text.substring(0, _count);
    return Semantics(
      label: widget.text,
      child: ExcludeSemantics(
        child: Stack(
          children: <Widget>[
            Opacity(
              opacity: 0,
              child: Text(
                widget.text,
                style: widget.style,
                textAlign: TextAlign.center,
              ),
            ),
            Text(
              visible,
              style: widget.style,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
