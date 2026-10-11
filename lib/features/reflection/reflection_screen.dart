import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_durations.dart';
import '../../theme/app_spacing.dart';
import '../../ui/conversation_page.dart';
import '../../ui/minimal_button.dart';
import '../../ui/question_input.dart';
import '../../ui/quiet_fade.dart';
import 'reflection_script.dart';

/// One question, one answer, one reply. Then it is finished.
class ReflectionScreen extends StatefulWidget {
  const ReflectionScreen({
    super.key,
    required this.draft,
    required this.onDraft,
    required this.onLeave,
  });

  /// Words from earlier in this visit. Nothing is written to disk.
  final String draft;
  final ValueChanged<String> onDraft;
  final VoidCallback onLeave;

  @override
  State<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends State<ReflectionScreen> {
  late final TextEditingController _words;
  final GlobalKey _replyKey = GlobalKey();

  Timer? _reply;
  bool _reduce = false;
  bool _hasWords = false;
  bool _offered = false;
  bool _heard = false;
  bool _left = false;
  String _kept = '';

  @override
  void initState() {
    super.initState();
    _words = TextEditingController(text: widget.draft);
    _hasWords = widget.draft.trim().isNotEmpty;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduce = MediaQuery.disableAnimationsOf(context);
  }

  @override
  void dispose() {
    if (!_left) {
      widget.onDraft(_words.text);
    }
    _reply?.cancel();
    _words.dispose();
    super.dispose();
  }

  void _changed(String value) {
    widget.onDraft(value);
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
      _revealReply();
      return;
    }
    _reply = Timer(ReflectionScript.replyDelay, () {
      if (!mounted) {
        return;
      }
      setState(() => _heard = true);
      _revealReply();
    });
  }

  void _leave() {
    _left = true;
    widget.onDraft('');
    widget.onLeave();
  }

  /// Brings the reply into view once it exists. The page stays still until then.
  void _revealReply() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final BuildContext? target = _replyKey.currentContext;
      if (target == null || !target.mounted) {
        return;
      }
      Scrollable.ensureVisible(
        target,
        alignment: 1,
        duration: AppDurations.resolve(target, AppDurations.fade),
        curve: AppDurations.curve,
      );
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
              bringIntoView: false,
              style: text.headlineSmall,
              onChanged: _changed,
            ),
          if (_heard) ...<Widget>[
            const SizedBox(height: AppSpacing.xl),
            KeyedSubtree(
              key: _replyKey,
              child: QuietFade(
                child: Text(
                  ReflectionScript.response,
                  textAlign: TextAlign.center,
                  style: text.headlineSmall,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget? _footer() {
    if (_heard) {
      return MinimalButton(label: ReflectionScript.leave, onPressed: _leave);
    }
    if (!_offered && _hasWords) {
      return MinimalButton(label: ReflectionScript.offer, onPressed: _offer);
    }
    return null;
  }
}
