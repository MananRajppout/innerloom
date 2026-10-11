import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../home/widgets/quiet_fade.dart';
import '../onboarding/widgets/conversation_page.dart';
import '../onboarding/widgets/minimal_button.dart';
import '../onboarding/widgets/question_input.dart';
import 'reflection_script.dart';

/// One question, one answer, one reply. Then it is finished.
class ReflectionScreen extends StatefulWidget {
  const ReflectionScreen({super.key, required this.onLeave});

  final VoidCallback onLeave;

  @override
  State<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends State<ReflectionScreen> {
  final TextEditingController _words = TextEditingController();

  Timer? _reply;
  bool _reduce = false;
  bool _hasWords = false;
  bool _offered = false;
  bool _heard = false;
  String _kept = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduce = MediaQuery.disableAnimationsOf(context);
  }

  @override
  void dispose() {
    _reply?.cancel();
    _words.dispose();
    super.dispose();
  }

  void _changed(String value) {
    final bool hasWords = value.trim().isNotEmpty;
    if (hasWords == _hasWords) {
      return;
    }
    setState(() => _hasWords = hasWords);
  }

  void _offer() {
    final String words = _words.text.trim();
    if (words.isEmpty || _offered) {
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _kept = words;
      _offered = true;
      if (_reduce) {
        _heard = true;
      }
    });
    if (_reduce) {
      return;
    }
    _reply = Timer(ReflectionScript.replyDelay, () {
      if (!mounted) {
        return;
      }
      setState(() => _heard = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return ConversationPage(
      footer: _footer(),
      child: Column(
        children: <Widget>[
          Text(
            ReflectionScript.question,
            textAlign: TextAlign.center,
            style: text.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.xxl),
          if (_offered)
            Text(
              _kept,
              textAlign: TextAlign.center,
              style: text.headlineSmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          else
            QuestionInput(
              controller: _words,
              hint: ReflectionScript.hint,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              minLines: 1,
              maxLines: 8,
              style: text.headlineSmall,
              onChanged: _changed,
            ),
          if (_heard) ...<Widget>[
            const SizedBox(height: AppSpacing.xl),
            QuietFade(
              child: Text(
                ReflectionScript.response,
                textAlign: TextAlign.center,
                style: text.headlineSmall,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget? _footer() {
    if (_heard) {
      return MinimalButton(
        label: ReflectionScript.leave,
        onPressed: widget.onLeave,
      );
    }
    if (!_offered && _hasWords) {
      return MinimalButton(label: ReflectionScript.offer, onPressed: _offer);
    }
    return null;
  }
}
