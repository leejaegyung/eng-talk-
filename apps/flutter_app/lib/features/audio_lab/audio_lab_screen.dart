import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/gen/app_localizations.dart';
import 'audio_lab_controller.dart';

class AudioLabScreen extends ConsumerWidget {
  const AudioLabScreen({super.key});

  static String _seconds(Duration d) =>
      (d.inMilliseconds / 1000).toStringAsFixed(1);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final s = ref.watch(audioLabProvider);
    final ctrl = ref.read(audioLabProvider.notifier);
    final recording = s.status == LabStatus.recording;
    final playing = s.status == LabStatus.playing;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.audioLabTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView(
            padding: const EdgeInsets.all(24),
            shrinkWrap: true,
            children: [
              Text(l10n.audioLabHint),
              const SizedBox(height: 24),
              if (s.status == LabStatus.micDenied)
                _Notice(l10n.audioLabMicDenied, Icons.mic_off),
              if (s.status == LabStatus.failed)
                _Notice(l10n.audioLabFailed, Icons.error_outline),
              Text(l10n.audioLabLevel(s.levelDb.toStringAsFixed(0))),
              const SizedBox(height: 8),
              // -60 dBFS (quiet room) .. 0 dBFS (full scale).
              LinearProgressIndicator(
                value: ((s.levelDb + 60) / 60).clamp(0.0, 1.0),
              ),
              const SizedBox(height: 16),
              Chip(
                avatar: Icon(
                  s.speaking ? Icons.record_voice_over : Icons.voice_over_off,
                ),
                label: Text(
                  s.speaking ? l10n.audioLabSpeaking : l10n.audioLabSilent,
                ),
              ),
              const SizedBox(height: 8),
              Text(l10n.audioLabSpeechTotal(_seconds(s.userSpeech))),
              Text(l10n.audioLabRecorded(_seconds(s.recorded))),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                children: [
                  FilledButton.icon(
                    onPressed: playing
                        ? null
                        : recording
                        ? ctrl.stopRecording
                        : ctrl.startRecording,
                    icon: Icon(recording ? Icons.stop : Icons.mic),
                    label: Text(
                      recording ? l10n.audioLabStop : l10n.audioLabRecord,
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: playing
                        ? ctrl.stopPlayback
                        : (s.hasRecording && !recording ? ctrl.play : null),
                    icon: Icon(playing ? Icons.stop : Icons.play_arrow),
                    label: Text(
                      playing ? l10n.audioLabStop : l10n.audioLabPlay,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice(this.text, this.icon);

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 16),
    child: ListTile(leading: Icon(icon), title: Text(text)),
  );
}
