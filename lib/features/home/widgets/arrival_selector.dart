import 'package:flutter/material.dart';

import '../../../theme/app_spacing.dart';
import '../home_script.dart';
import 'arrival_card.dart';

/// The words for how someone is arriving, held in two quiet columns.
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
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double gap = AppSpacing.sm;
        final double width = constraints.maxWidth;
        final double itemWidth = width <= gap ? width : (width - gap) / 2;
        return Wrap(
          alignment: WrapAlignment.center,
          spacing: gap,
          runSpacing: gap,
          children: <Widget>[
            for (var i = 0; i < count; i++)
              SizedBox(
                width: itemWidth,
                child: ArrivalCard(
                  label: HomeScript.label(HomeScript.arrivals[i]),
                  selected: selected == HomeScript.arrivals[i],
                  onTap: () => onSelected(HomeScript.arrivals[i]),
                ),
              ),
          ],
        );
      },
    );
  }
}
