import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';

/// An outline only. Nothing about it asks to be the loudest thing on screen.
class MinimalButton extends StatelessWidget {
  const MinimalButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final TextStyle? textStyle = Theme.of(context).textTheme.titleSmall;
    return OutlinedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.textTertiary;
          }
          return AppColors.textPrimary;
        }),
        side: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
          final Color color = states.contains(WidgetState.disabled)
              ? AppColors.outlineSoft
              : AppColors.outline;
          return BorderSide(color: color);
        }),
        minimumSize: const WidgetStatePropertyAll<Size>(Size(48, 48)),
        padding: const WidgetStatePropertyAll<EdgeInsets>(
          EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
        ),
        shape: const WidgetStatePropertyAll<OutlinedBorder>(
          RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
        ),
        textStyle: WidgetStatePropertyAll<TextStyle?>(textStyle),
      ),
      child: Text(label),
    );
  }
}
