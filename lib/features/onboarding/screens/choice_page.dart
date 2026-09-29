import 'package:flutter/material.dart';

import '../../../theme/app_spacing.dart';
import '../widgets/chip_selector.dart';
import '../widgets/conversation_page.dart';
import '../widgets/minimal_button.dart';

class ChoicePage extends StatefulWidget {
  const ChoicePage({
    super.key,
    required this.question,
    required this.options,
    required this.hint,
    required this.onSubmit,
  });

  final String question;
  final List<String> options;
  final String hint;
  final ValueChanged<String> onSubmit;

  @override
  State<ChoicePage> createState() => _ChoicePageState();
}

class _ChoicePageState extends State<ChoicePage> {
  String _answer = '';

  void _changed(String value) {
    setState(() => _answer = value.trim());
  }

  void _submit() {
    if (_answer.isEmpty) {
      return;
    }
    widget.onSubmit(_answer);
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return ConversationPage(
      footer: MinimalButton(
        label: 'Continue',
        onPressed: _answer.isEmpty ? null : _submit,
      ),
      child: Column(
        children: <Widget>[
          SizedBox(
            width: double.infinity,
            child: Text(
              widget.question,
              textAlign: TextAlign.center,
              style: text.headlineMedium,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          ChipSelector(
            options: widget.options,
            hint: widget.hint,
            onChanged: _changed,
          ),
        ],
      ),
    );
  }
}
