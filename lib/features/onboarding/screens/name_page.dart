import 'package:flutter/material.dart';

import '../../../theme/app_spacing.dart';
import '../onboarding_script.dart';
import '../widgets/conversation_page.dart';
import '../widgets/minimal_button.dart';
import '../widgets/question_input.dart';

class NamePage extends StatefulWidget {
  const NamePage({super.key, required this.onSubmit, this.initialName = ''});

  final ValueChanged<String> onSubmit;
  final String initialName;

  @override
  State<NamePage> createState() => _NamePageState();
}

class _NamePageState extends State<NamePage> {
  late final TextEditingController _name;
  late bool _hasName;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initialName);
    _hasName = widget.initialName.trim().isNotEmpty;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _changed(String value) {
    final bool hasName = value.trim().isNotEmpty;
    if (hasName == _hasName) {
      return;
    }
    setState(() => _hasName = hasName);
  }

  void _submit() {
    if (!_hasName) {
      return;
    }
    widget.onSubmit(_name.text);
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return ConversationPage(
      footer: MinimalButton(
        label: 'Continue',
        onPressed: _hasName ? _submit : null,
      ),
      child: Column(
        children: <Widget>[
          SizedBox(
            width: double.infinity,
            child: Text(
              OnboardingScript.nameQuestion,
              textAlign: TextAlign.center,
              style: text.headlineMedium,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          QuestionInput(
            controller: _name,
            hint: OnboardingScript.nameHint,
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            autofillHints: const <String>[AutofillHints.givenName],
            style: text.headlineLarge,
            onChanged: _changed,
            onSubmitted: _submit,
          ),
        ],
      ),
    );
  }
}
