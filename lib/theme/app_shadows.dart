import 'package:flutter/painting.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

/// Shadows for surfaces that need to lift slightly off the room.
///
/// Future Self's orb does not use these. Its light is a glow, not a drop shadow.
abstract final class AppShadows {
  static const List<BoxShadow> resting = <BoxShadow>[
    BoxShadow(
      color: AppColors.shadow,
      blurRadius: 28,
      offset: Offset(0, AppSpacing.sm),
    ),
  ];
}
