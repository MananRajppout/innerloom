import 'package:flutter/material.dart';

import '../../../theme/app_spacing.dart';
import '../home_script.dart';
import 'arrival_card.dart';

/// The words for how someone is arriving, shown as they become ready.
class ArrivalSelector extends StatelessWidget {
  const ArrivalSelector({
    super.key,
    required this.visibleCount,
    required this.selected,
    required this.onSelected,
  });

  final int visibleCount;
  final Arrival? selected;
  final ValueChanged<Arrival> onSelected;

  @override
  Widget build(BuildContext context) {
    final int total = HomeScript.arrivals.length;
    final int count = visibleCount < 0
        ? 0
        : (visibleCount > total ? total : visibleCount);
    return Column(
      children: <Widget>[
        for (var i = 0; i < count; i++) ...<Widget>[
          if (i > 0) const SizedBox(height: AppSpacing.md),
          ArrivalCard(
            label: HomeScript.label(HomeScript.arrivals[i]),
            selected: selected == HomeScript.arrivals[i],
            onTap: () => onSelected(HomeScript.arrivals[i]),
          ),
        ],
      ],
    );
  }
}
