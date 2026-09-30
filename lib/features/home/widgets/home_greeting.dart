import 'package:flutter/material.dart';

/// The time, and a name only when they offered one.
class HomeGreeting extends StatelessWidget {
  const HomeGreeting({super.key, required this.greeting, this.name = ''});

  final String greeting;
  final String name;

  @override
  Widget build(BuildContext context) {
    final String trimmed = name.trim();
    final String line = trimmed.isEmpty ? '$greeting.' : '$greeting, $trimmed.';
    return Text(
      line,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.headlineMedium,
    );
  }
}
