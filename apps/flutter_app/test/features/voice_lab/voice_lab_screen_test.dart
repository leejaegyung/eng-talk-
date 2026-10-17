import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_coach/app/l10n/gen/app_localizations.dart';
import 'package:speaking_coach/app/providers.dart';
import 'package:speaking_coach/domain/providers/ai_provider.dart';
import 'package:speaking_coach/domain/providers/provider_failure.dart';
import 'package:speaking_coach/features/voice_lab/voice_lab_screen.dart';

import '../../helpers/fakes.dart';

const fakeKey = 'sk-FAKE-screen-test-0000000000';

void main() {
  late MemoryVault vault;

  Future<void> pumpLab(
    WidgetTester tester,
    Future<ModelSelection> Function() selectModels,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          credentialVaultProvider.overrideWithValue(vault),
          audioInputProvider.overrideWithValue(FakeInput()),
          audioOutputProvider.overrideWithValue(FakeOutput()),
          llmProviderProvider.overrideWithValue(FakeAi()),
          voiceProviderProvider.overrideWithValue(FakeAi()),
          modelSelectorProvider.overrideWithValue(selectModels),
        ],
        child: const MaterialApp(
          locale: Locale('ko'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: VoiceLabScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() => vault = MemoryVault());

  final messages = {
    ProviderFailure.invalidKey: 'API 키가 올바르지 않아요',
    ProviderFailure.insufficientQuota: '사용 가능한 크레딧이 없어요',
    ProviderFailure.rateLimited: '요청이 너무 많아요',
    ProviderFailure.network: '네트워크에 연결할 수 없어요',
  };

  messages.forEach((failure, text) {
    testWidgets('shows a message for $failure', (tester) async {
      await pumpLab(tester, () async => throw ProviderException(failure));

      await tester.enterText(find.byType(TextField), fakeKey);
      await tester.tap(find.text('저장'));
      await tester.pumpAndSettle();

      expect(find.textContaining(text), findsOneWidget);
      expect(find.text('말하기'), findsOneWidget);
      final talk = tester.widget<FilledButton>(
        find.ancestor(
          of: find.text('말하기'),
          matching: find.byType(FilledButton),
        ),
      );
      expect(talk.onPressed, isNull, reason: 'no models → cannot talk');
    });
  });

  testWidgets('saving a key clears the field and enables talking', (
    tester,
  ) async {
    await pumpLab(
      tester,
      () async =>
          const ModelSelection(chat: 'c', transcription: 's', speech: 't'),
    );

    await tester.enterText(find.byType(TextField), fakeKey);
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();

    expect(vault.values[openAiKeyRef], fakeKey);
    expect(find.text('키 저장됨'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.textContaining(fakeKey), findsNothing);
  });
}
