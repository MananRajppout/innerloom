import 'package:flutter/material.dart';

import '../../../theme/app_spacing.dart';

/// The words can scroll. The action stays on screen.
class ConversationPage extends StatelessWidget {
  const ConversationPage({super.key, required this.child, this.footer});

  final Widget child;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double verticalPadding = AppSpacing.lg * 2;
              final double minHeight = constraints.maxHeight > verticalPadding
                  ? constraints.maxHeight - verticalPadding
                  : 0;
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screen,
                  vertical: AppSpacing.lg,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: minHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[child],
                  ),
                ),
              );
            },
          ),
        ),
        if (footer != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.sm,
              AppSpacing.screen,
              AppSpacing.xl,
            ),
            child: footer!,
          ),
      ],
    );
  }
}
