import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import 'question_input.dart';

/// One answer, either from a chip or from the person's own words.
class ChipSelector extends StatefulWidget {
  const ChipSelector({
    super.key,
    required this.options,
    required this.hint,
    required this.onChanged,
    this.onSubmitted,
    this.initialValue = '',
  });

  final List<String> options;
  final String hint;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final String initialValue;

  @override
  State<ChipSelector> createState() => _ChipSelectorState();
}

class _ChipSelectorState extends State<ChipSelector> {
  late final TextEditingController _custom;
  String? _selected;
  bool _suppressCustom = false;

  @override
  void initState() {
    super.initState();
    final String initial = widget.initialValue.trim();
    if (widget.options.contains(initial)) {
      _selected = initial;
      _custom = TextEditingController();
    } else {
      _custom = TextEditingController(text: initial);
    }
  }

  @override
  void dispose() {
    _custom.dispose();
    super.dispose();
  }

  void _select(String option) {
    setState(() => _selected = option);
    _suppressCustom = true;
    _custom.clear();
    _suppressCustom = false;
    widget.onChanged(option);
  }

  void _onCustom(String value) {
    if (_suppressCustom) {
      return;
    }
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      if (value.isNotEmpty && _selected != null) {
        _suppressCustom = true;
        _custom.clear();
        _suppressCustom = false;
      }
      widget.onChanged(_selected ?? '');
      return;
    }
    setState(() => _selected = null);
    widget.onChanged(trimmed);
  }

  void _submitCustom() {
    final String trimmed = _custom.text.trim();
    final String answer = trimmed.isNotEmpty ? trimmed : (_selected ?? '');
    if (answer.isEmpty) {
      return;
    }
    widget.onSubmitted?.call(answer);
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Column(
      children: <Widget>[
        SizedBox(
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: <Widget>[
              for (final String option in widget.options)
                _ChoiceChip(
                  label: option,
                  selected: _selected == option,
                  onTap: () => _select(option),
                  textStyle: text.titleSmall,
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        QuestionInput(
          controller: _custom,
          hint: widget.hint,
          onChanged: _onCustom,
          onSubmitted: _submitCustom,
          style: text.titleLarge,
        ),
      ],
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.textStyle,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: selected ? AppColors.surfaceRaised : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderPill,
          side: BorderSide(
            color: selected ? AppColors.orbMid : AppColors.outline,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          customBorder: const RoundedRectangleBorder(
            borderRadius: AppRadius.borderPill,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Center(
                child: ExcludeSemantics(
                  child: Text(
                    label,
                    style: textStyle?.copyWith(
                      color: selected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
