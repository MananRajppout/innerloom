import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_durations.dart';

/// One field. No label. The hint is the only instruction.
class QuestionInput extends StatefulWidget {
  const QuestionInput({
    super.key,
    required this.controller,
    required this.hint,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.sentences,
    this.style,
    this.autofillHints,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final TextStyle? style;
  final Iterable<String>? autofillHints;

  @override
  State<QuestionInput> createState() => _QuestionInputState();
}

class _QuestionInputState extends State<QuestionInput> {
  void _keepInView() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      Scrollable.ensureVisible(
        context,
        alignment: 0.4,
        duration: AppDurations.resolve(context, AppDurations.fade),
        curve: AppDurations.curve,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle style =
        widget.style ??
        Theme.of(context).textTheme.headlineMedium ??
        const TextStyle();
    return TextField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      textCapitalization: widget.textCapitalization,
      textAlign: TextAlign.center,
      textInputAction: TextInputAction.done,
      style: style,
      cursorColor: AppColors.orbMid,
      autofillHints: widget.autofillHints,
      autocorrect: widget.keyboardType != TextInputType.name,
      enableSuggestions: widget.keyboardType != TextInputType.name,
      onChanged: widget.onChanged,
      onSubmitted: (_) => widget.onSubmitted?.call(),
      onTap: _keepInView,
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: style.copyWith(color: AppColors.textTertiary),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.outline),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.outline),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.orbMid),
        ),
      ),
    );
  }
}
