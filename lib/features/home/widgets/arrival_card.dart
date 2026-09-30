import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_durations.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';

/// One word. A tap is the whole choice.
class ArrivalCard extends StatefulWidget {
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
  State<ArrivalCard> createState() => _ArrivalCardState();
}

class _ArrivalCardState extends State<ArrivalCard> {
  double _opacity = 0;
  bool _armed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_armed) {
      return;
    }
    _armed = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _opacity = 1;
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _opacity = 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool selected = widget.selected;
    return AnimatedOpacity(
      opacity: _opacity,
      duration: AppDurations.resolve(context, AppDurations.fade),
      curve: AppDurations.curve,
      child: Semantics(
        button: true,
        selected: selected,
        label: widget.label,
        child: AnimatedContainer(
          duration: AppDurations.resolve(context, AppDurations.fade),
          curve: AppDurations.curve,
          constraints: const BoxConstraints(minHeight: AppSpacing.huge),
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
              onTap: widget.onTap,
              borderRadius: AppRadius.borderLg,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.lg,
                ),
                child: Center(
                  child: ExcludeSemantics(
                    child: Text(
                      widget.label,
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
