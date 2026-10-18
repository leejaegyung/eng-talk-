// Full Phase 1 journey on the real macOS app (docs/qa/phase-1-checklist.md):
// real ChatGPT plan (no API charges), real on-device voice, real SQLite on a
// temporary file. Only the microphone is scripted, since nobody speaks
// during the run; the user's own data and settings are not touched.
//   flutter test integration_test/mac_e2e_test.dart -d macos
// With --dart-define=AI=scripted the AI is scripted too, so the run needs
// no ChatGPT sign-in (and no keychain prompt) — everything else stays real.
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:speaking_coach/app/app.dart';
import 'package:speaking_coach/app/providers.dart';
import 'package:speaking_coach/core/logging/app_logger.dart';
import 'package:speaking_coach/data/db/app_database.dart' show AppDatabase;
import 'package:speaking_coach/domain/audio/speech_io.dart';
import 'package:speaking_coach/domain/conversation/session_enums.dart';
import 'package:speaking_coach/domain/conversation/session_types.dart';
import 'package:speaking_coach/domain/credentials/provider_account.dart';
import 'package:speaking_coach/domain/providers/ai_provider.dart';
import 'package:speaking_coach/domain/sessions/export.dart';
import 'package:speaking_coach/features/assessment/assessment_controller.dart';
import 'package:speaking_coach/features/conversation/conversation_controller.dart';
import 'package:speaking_coach/features/home/home_controller.dart';
import 'package:speaking_coach/features/setup/setup_controller.dart';

const _log = AppLogger('e2e');
const _scriptedAi = String.fromEnvironment('AI') == 'scripted';

class SignedIn implements ProviderAccount {
  @override
  Future<bool> isSignedIn() async => true;

  @override
  Future<void> signIn() async {}

  @override
  Future<bool> signOut() async => true;
}

/// Streams replies shaped like the model's for each of the app's prompts.
class ScriptedLlm implements LlmProvider {
  @override
  Future<List<String>> listModels() async => const ['scripted'];

  @override
  Stream<ChatChunk> streamChat({
    required String model,
    required List<ChatMessage> messages,
    int maxOutputTokens = 200,
  }) async* {
    final system = messages.first.content;
    final String reply;
    if (system.contains('You review an English speaking practice')) {
      final line = RegExp(r'\[t(\d+)\] learner: (.+)')
          .firstMatch(messages[1].content)!;
      reply =
          '{"strengths": ["You explained what you wanted clearly"], '
          '"corrections": [{"turn_id": ${line[1]}, "original": "${line[2]}", '
          '"suggested": "Hi, I have a reservation for two nights under Kim.", '
          '"explanation_ko": "문장 부호와 연결을 다듬었어요", '
          '"severity": "medium", "category": "structure", '
          '"practice_prompt": "How would you check in?"}], '
          '"expressions": [{"phrase": "I booked a room for", '
          '"meaning_ko": "~로 방을 예약했어요"}], "next_topic": "Ordering room service"}';
    } else if (system.contains('placement conversation')) {
      reply =
          '{"relevance": 4, "sentence_formation": 3, "vocabulary": 3, '
          '"continuity": 3, "comment_ko": "질문에 맞게 잘 답했어요"}';
    } else {
      reply = 'Welcome to our hotel! Could you tell me your name, please?';
    }
    for (final word in reply.split(' ')) {
      await Future<void>.delayed(const Duration(milliseconds: 20));
      yield TextDelta('$word ');
    }
  }
}

/// Answers in place of the microphone, with partial results spread out so
/// the speaking-time estimate is measured.
class ScriptedMic implements SpeechInput {
  final queue = <String>[];
  final hints = <List<String>>[];

  @override
  Future<bool> ensureAvailable() async => true;

  @override
  Future<String> listenOnce({
    void Function(String partial)? onPartial,
    List<String> hints = const [],
  }) async {
    this.hints.add(hints);
    final text = queue.isEmpty ? '' : queue.removeAt(0);
    final words = text.split(' ');
    for (var i = 1; i <= words.length; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      onPartial?.call(words.take(i).join(' '));
    }
    return text;
  }

  @override
  Future<void> stop() async {}
}

class KeptExport implements DataExporter {
  Map<String, String>? files;

  @override
  Future<String> export(Map<String, String> files) async {
    this.files = files;
    return '(kept in memory)';
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('phase 1 journey on macOS', (tester) async {
    final dir = await Directory.systemTemp.createTemp('speaking-coach-e2e');
    addTearDown(() => dir.delete(recursive: true));
    final dbFile = File('${dir.path}/e2e.sqlite');
    final mic = ScriptedMic();
    final exporter = KeptExport();

    ProviderContainer boot() {
      final c = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWith((ref) {
            final db = AppDatabase(NativeDatabase(dbFile));
            ref.onDispose(db.close);
            return db;
          }),
          speechInputProvider.overrideWithValue(mic),
          dataExporterProvider.overrideWithValue(exporter),
          if (_scriptedAi) ...[
            chatGptAccountProvider.overrideWithValue(SignedIn()),
            chatGptLlmProvider.overrideWithValue(ScriptedLlm()),
            chatGptModelSelectorProvider.overrideWithValue(
              () async => 'scripted',
            ),
          ],
        ],
      );
      return c;
    }

    tester.platformDispatcher.localesTestValue = const [Locale('ko')];
    // Typed text comes from the test, not the macOS keyboard.
    tester.binding.testTextInput.register();
    addTearDown(tester.binding.testTextInput.unregister);
    var container = boot();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const SpeakingCoachApp(),
      ),
    );

    Future<void> until(
      bool Function() done, {
      String what = '',
      Duration timeout = const Duration(seconds: 90),
    }) async {
      final end = DateTime.now().add(timeout);
      while (!done()) {
        if (DateTime.now().isAfter(end)) {
          final shown = [
            for (final e in find.byType(Text).evaluate())
              ?(e.widget as Text).data,
          ];
          fail('timed out waiting: $what\nOn screen: $shown');
        }
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    Future<void> waitFor(Finder f, {Duration? timeout}) => until(
      () => f.evaluate().isNotEmpty,
      what: '$f',
      timeout: timeout ?? const Duration(seconds: 90),
    );

    Future<void> tap(Finder f) async {
      await waitFor(f);
      await tester.ensureVisible(f.first);
      await tester.pump();
      await tester.tap(f.first);
      await tester.pump(const Duration(milliseconds: 300));
    }

    Future<void> tapText(String text) => tap(find.text(text));

    /// Scrolls the screen's list until [f] is built and visible.
    Future<void> scrollTo(Finder f) async {
      if (f.evaluate().isEmpty) {
        await tester.scrollUntilVisible(
          f,
          300,
          scrollable: find.byType(Scrollable).first,
        );
      }
      await tap(f);
    }

    final clock = Stopwatch()..start();
    void step(String name) {
      final line = '[${clock.elapsed.inSeconds}s] $name';
      _log.info(line);
      // Visible in `flutter test` output: the run report for a human.
      debugPrint('E2E $line');
    }

    // 1. Onboarding with goals, already signed in to ChatGPT.
    step('start (AI: ${_scriptedAi ? 'scripted' : 'ChatGPT plan'})');
    final signedIn = await tester.runAsync(
      () => container.read(chatGptAccountProvider).isSignedIn(),
    );
    step('onboarding (signed in: $signedIn)');
    expect(signedIn, isTrue, reason: 'sign in with ChatGPT in the app first');
    await tapText('다음');
    await tapText('확인했어요');
    await waitFor(find.text('학습 목표'));
    await tapText('여행');
    await tapText('20분');
    await tapText('다음');
    await waitFor(find.text('연결됐어요'), timeout: const Duration(seconds: 30));
    await tapText('시작하기');
    await waitFor(find.text('오늘 0분 / 목표 20분'));
    expect(find.text('여행 목표 추천: 상황 역할극'), findsOneWidget);

    // 2. Placement: mic check by voice, answers typed, graded by the model.
    step('placement');
    await tapText('진단 시작');
    mic.queue.add('Hello can you hear me');
    await tap(find.byTooltip('말하기'));
    await waitFor(find.text('들린 말: Hello can you hear me'));
    await tapText('다음');
    const answers = [
      'My name is Kim and I work at a design company in Seoul.',
      'On weekends I usually go hiking with my friends because I like nature.',
      'Last year I traveled to Japan and I ate a lot of delicious food there.',
      'I think working from home is good because I can save time, but it is lonely.',
      'In five years I want to speak English more freely at work.',
    ];
    for (final (i, a) in answers.indexed) {
      await waitFor(find.text('질문 ${i + 1} / 5'));
      await tester.enterText(find.byType(TextField), a);
      await tester.pump();
      step(
        'answer ${i + 1} kept: '
        '"${container.read(assessmentProvider).currentAnswer}"',
      );
      await tapText(i == 4 ? '결과 보기' : '다음');
    }
    await waitFor(find.textContaining('추천 레벨: L'));
    final level =
        (find.textContaining('추천 레벨: L').evaluate().first.widget as Text).data;
    step('placement → $level');
    await tapText('이 레벨로 시작');
    await waitFor(find.text('오늘 0분 / 목표 20분'));

    // 3. Setup preselected from the travel goal; pick a hotel scenario.
    step('setup');
    await tap(find.widgetWithText(FilledButton, '대화 시작'));
    step(
      'setup preselected: ${container.read(setupProvider).mode.name}, '
      '${container.read(setupProvider).length.inMinutes} min',
    );
    expect(container.read(setupProvider).mode, SessionMode.roleplay);
    await scrollTo(find.text('호텔 체크인'));
    // Hands-free (on by default) hears this once the AI has spoken.
    mic.queue.add('Hi I have a reservation for two nights under Kim');
    await scrollTo(find.widgetWithText(FilledButton, '대화 시작'));

    // 4. Conversation: the AI opens, a hands-free voice answer, then typed.
    ConversationState conv() => container.read(conversationProvider);
    Future<void> learnerTurnDone(int answersBefore) => until(
      () =>
          conv().learnerAnswers > answersBefore &&
          conv().phase == SessionPhase.listening,
      what: 'reply to answer ${answersBefore + 1}',
    );
    await learnerTurnDone(0);
    step('AI opened: ${conv().turns.first.text}');
    expect(conv().turns.first.speaker, Speaker.assistant);
    expect(conv().turns.first.text, contains('?'));
    expect(conv().handsFree, isTrue);
    expect(conv().turns[1].text, startsWith('Hi I have a reservation'));
    expect(find.textContaining('점수'), findsNothing);
    step('hands-free voice turn → ${conv().turns.last.text}');
    expect(mic.hints.last, isNotEmpty, reason: 'recognition hints sent');

    await tester.enterText(
      find.byType(TextField),
      'Can I get a quiet room? I go to bed early because I have meeting tomorrow.',
    );
    await tapText('보내기');
    await learnerTurnDone(1);
    step('typed turn → ${conv().turns.last.text}');

    await tap(find.widgetWithText(ActionChip, '힌트'));
    await until(
      () =>
          conv().phase == SessionPhase.listening &&
          conv().turns.last.speaker == Speaker.assistant,
      what: 'hint reply',
    );
    step('hint → ${conv().turns.last.text}');

    // Away from the app while the AI answers: paused, then it answers.
    await tester.enterText(
      find.byType(TextField),
      'Also, is breakfast included in the price?',
    );
    await tapText('보내기');
    for (final s in [AppLifecycleState.inactive, AppLifecycleState.hidden]) {
      tester.binding.handleAppLifecycleStateChanged(s);
    }
    await tester.pump(const Duration(milliseconds: 300));
    expect(conv().pauseReason, PauseReason.background);
    for (final s in [AppLifecycleState.inactive, AppLifecycleState.resumed]) {
      tester.binding.handleAppLifecycleStateChanged(s);
    }
    await waitFor(find.textContaining('앱을 벗어나서 일시정지했어요'));
    await tapText('이어하기');
    await learnerTurnDone(2);
    expect(conv().turns.last.speaker, Speaker.assistant);
    step('after background → ${conv().turns.last.text}');

    // 5. End → result with real feedback.
    await tap(find.text('종료'));
    await waitFor(find.text('대화 결과'));
    step('result');
    await until(
      () => find.text('대화 내용으로 피드백을 만드는 중…').evaluate().isEmpty,
      what: 'feedback',
    );
    await waitFor(find.text('고쳐 말해볼 문장'));
    if (find.text('다시 말하기').evaluate().isNotEmpty) {
      mic.queue.add(
        'I am going to bed early because I have a meeting tomorrow',
      );
      await tapText('다시 말하기');
      await waitFor(find.textContaining('방금 말한 문장:'));
    }

    // 6. Home: today's practice counts toward the goal; growth dashboard.
    await tapText('홈으로');
    await waitFor(find.textContaining('목표 20분'));
    final home = await container.read(homeProvider.future);
    step(
      'home: practice ${home.stats.todayPractice}, '
      'reviews ${home.stats.reviewsDue}',
    );
    expect(home.stats.completed, 1);
    await tap(find.byTooltip('성장 기록'));
    await waitFor(find.text('자주 고친 부분'));
    expect(find.text('1회'), findsWidgets);
    await tap(find.byType(BackButton));
    await tester.pump(const Duration(milliseconds: 500));

    // 7. Review the corrections.
    if (home.stats.reviewsDue > 0) {
      await tapText('복습할 문장');
      await tapText('말해봤어요');
      await tap(find.byType(BackButton));
      await tester.pump(const Duration(milliseconds: 500));
    }

    // 8. History search.
    await tap(find.byTooltip('학습 기록'));
    await tester.enterText(find.byType(TextField), 'reservation');
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.textContaining('상황 역할극'), findsWidgets);
    await tap(find.byType(BackButton));
    await tester.pump(const Duration(milliseconds: 500));

    // 9. Export holds the transcript, never sign-in tokens.
    await tap(find.byIcon(Icons.settings_outlined));
    await scrollTo(find.text('대화 기록 내보내기 (JSON·CSV)'));
    await until(() => exporter.files != null, what: 'export');
    final all = exporter.files!.values.join();
    expect(all, contains('reservation'));
    for (final secret in ['access_token', 'refresh_token', 'id_token']) {
      expect(all, isNot(contains(secret)));
    }
    step('export ok (${all.length} chars)');

    // 10. Restart on the same database: everything is still there.
    await tester.pumpWidget(const SizedBox());
    container.dispose();
    container = boot();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const SpeakingCoachApp(),
      ),
    );
    await waitFor(find.textContaining('목표 20분'));
    final again = await container.read(homeProvider.future);
    expect(again.stats.completed, 1);
    expect(again.placed, isTrue);
    step('restart ok');
    await tester.pumpWidget(const SizedBox());
    container.dispose();
    tester.platformDispatcher.clearLocalesTestValue();
  }, timeout: const Timeout(Duration(minutes: 15)));
}
