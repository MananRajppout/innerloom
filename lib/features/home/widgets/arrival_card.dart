import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_durations.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import 'quiet_fade.dart';

/// One word. A tap is the whole choice.
class ArrivalCard extends StatelessWidget {
  const ArrivalCard({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return QuietFade(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: AnimatedContainer(
          duration: AppDurations.resolve(context, AppDurations.fade),
          curve: AppDurations.curve,
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 48),
          decoration: BoxDecoration(
            color: selected ? AppColors.surfaceRaised : AppColors.surface,
            borderRadius: AppRadius.borderLg,
            border: Border.all(
              color: selected ? AppColors.orbMid : AppColors.outline,
            ),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onTap,
              borderRadius: AppRadius.borderLg,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                child: Center(
                  child: ExcludeSemantics(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
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
      ),
    );
  }
}
