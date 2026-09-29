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
  });

  final List<String> options;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  State<ChipSelector> createState() => _ChipSelectorState();
}

class _ChipSelectorState extends State<ChipSelector> {
  final TextEditingController _custom = TextEditingController();
  String? _selected;

  @override
  void dispose() {
    _custom.dispose();
    super.dispose();
  }

  void _select(String option) {
    _custom.clear();
    setState(() => _selected = option);
    widget.onChanged(option);
  }

  void _onCustom(String value) {
    final String trimmed = value.trim();
    setState(() {
      if (trimmed.isNotEmpty) {
        _selected = null;
      }
    });
    widget.onChanged(trimmed);
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
