import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_language.dart';
import '../../app/l10n/gen/app_localizations.dart';

/// Device / 한국어 / English. Labels stay in their own language so they
/// can be found whatever is shown now.
class LanguagePicker extends ConsumerWidget {
  const LanguagePicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final current = ref.watch(appLanguageProvider).value?.languageCode;
    return SegmentedButton<String>(
      segments: [
        ButtonSegment(value: 'system', label: Text(l10n.languageSystem)),
        ButtonSegment(value: 'ko', label: Text(l10n.languageKo)),
        ButtonSegment(value: 'en', label: Text(l10n.languageEn)),
      ],
      selected: {current ?? 'system'},
      showSelectedIcon: false,
      onSelectionChanged: (v) => ref
          .read(appLanguageProvider.notifier)
          .set(v.single == 'system' ? null : v.single),
    );
  }
}
