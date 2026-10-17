import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/l10n/gen/app_localizations.dart';
import '../../app/router.dart';
import '../../domain/conversation/session_enums.dart';
import '../../domain/learning/learner_level.dart';
import '../common/mode_text.dart';
import 'scenarios.dart';
import 'setup_controller.dart';

/// S04 mode/level/length + S05 topic and role.
class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  final _topic = TextEditingController();
  final _role = TextEditingController();
  final _goal = TextEditingController();

  @override
  void initState() {
    super.initState();
    final s = ref.read(setupProvider);
    _topic.text = s.topic ?? '';
    _role.text = s.role ?? '';
    _goal.text = s.goal ?? '';
  }

  @override
  void dispose() {
    _topic.dispose();
    _role.dispose();
    _goal.dispose();
    super.dispose();
  }

  void _sync() {
    final s = ref.read(setupProvider);
    for (final (c, v) in [
      (_topic, s.topic),
      (_role, s.role),
      (_goal, s.goal),
    ]) {
      if (c.text != (v ?? '')) c.text = v ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final s = ref.watch(setupProvider);
    final ctrl = ref.read(setupProvider.notifier);
    final theme = Theme.of(context);

    Widget heading(String text) => Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(text, style: theme.textTheme.titleMedium),
    );

    final roleplay = s.mode == SessionMode.roleplay;
    final suggestions = topicSuggestions[s.mode] ?? const [];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.setupTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            children: [
              heading(l10n.setupMode),
              for (final mode in SessionMode.values)
                if (mode != SessionMode.assessment)
                  Card(
                    color: mode == s.mode
                        ? theme.colorScheme.primaryContainer
                        : null,
                    child: ListTile(
                      leading: Icon(modeIcon(mode)),
                      title: Text(modeName(l10n, mode)),
                      subtitle: Text(modeDescription(l10n, mode)),
                      selected: mode == s.mode,
                      onTap: () {
                        ctrl.setMode(mode);
                        _sync();
                      },
                    ),
                  ),
              heading(l10n.setupLevel),
              SegmentedButton<LearnerLevel>(
                segments: [
                  for (final l in LearnerLevel.values)
                    ButtonSegment(value: l, label: Text(l.label)),
                ],
                selected: {s.level},
                showSelectedIcon: false,
                onSelectionChanged: (v) => ctrl.setLevel(v.single),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  l10n.setupLevelNote,
                  style: theme.textTheme.bodySmall,
                ),
              ),
              if (s.mode == SessionMode.random) ...[
                heading(l10n.setupTopic),
                Text(l10n.setupRandomNote),
              ] else if (roleplay) ...[
                heading(l10n.setupScenario),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final sc in roleplayScenarios)
                      ChoiceChip(
                        label: Text(sc.labelKo),
                        selected: s.role == sc.role && s.topic == sc.situation,
                        onSelected: (_) {
                          ctrl.setScenario(sc);
                          _sync();
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _role,
                  decoration: InputDecoration(
                    labelText: l10n.setupRole,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: ctrl.setRole,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _topic,
                  decoration: InputDecoration(
                    labelText: l10n.setupSituation,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: ctrl.setTopic,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _goal,
                  decoration: InputDecoration(
                    labelText: l10n.setupGoal,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: ctrl.setGoal,
                ),
              ] else ...[
                heading(
                  s.mode == SessionMode.theme
                      ? l10n.setupTopic
                      : l10n.setupTopicOptional,
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final t in suggestions)
                      ChoiceChip(
                        label: Text(t),
                        selected: s.topic == t,
                        onSelected: (on) {
                          ctrl.setTopic(on ? t : null);
                          _sync();
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _topic,
                  decoration: InputDecoration(
                    hintText: l10n.setupTopicHint,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: ctrl.setTopic,
                ),
              ],
              heading(l10n.setupLength),
              SegmentedButton<int>(
                segments: [
                  for (final m in [20, 30, 45])
                    ButtonSegment(value: m, label: Text(l10n.setupMinutes(m))),
                ],
                selected: {s.length.inMinutes},
                showSelectedIcon: false,
                onSelectionChanged: (v) =>
                    ctrl.setLength(Duration(minutes: v.single)),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: ctrl.ready
                    ? () {
                        ctrl.start();
                        context.push(AppRoutes.conversation);
                      }
                    : null,
                icon: const Icon(Icons.mic),
                label: Text(l10n.setupStart),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
