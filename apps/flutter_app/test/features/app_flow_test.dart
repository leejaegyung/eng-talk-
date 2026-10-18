import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_coach/domain/audio/speech_io.dart';
import 'package:speaking_coach/domain/conversation/session_enums.dart';
import 'package:speaking_coach/domain/sessions/session_records.dart';
import 'package:speaking_coach/domain/settings/settings_store.dart';
import 'package:speaking_coach/features/setup/setup_controller.dart';
import 'package:speaking_coach/features/setup/setup_screen.dart';

import '../helpers/app_harness.dart';
import '../helpers/fakes.dart';

/// End-to-end flows through the real screens with a scripted AI and an
/// in-memory database.
void main() {
  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.ensureVisible(find.text(text).first);
    await tester.tap(find.text(text).first);
    await settle(tester);
  }

  testWidgets(
    'setup → roleplay → talk → end → result with feedback → review on home',
    (tester) async {
      final h = Harness();
      await h.boot(tester);

      await tapText(tester, '대화 시작');
      expect(find.text('대화 준비'), findsOneWidget);
      await tapText(tester, '상황 역할극');
      await tapText(tester, '호텔 체크인');
      final start = find.widgetWithText(FilledButton, '대화 시작');
      await tester.ensureVisible(start);
      await tester.tap(start);
      await settle(tester);

      // S06
      expect(find.text('상황 역할극 · L2'), findsOneWidget);
      expect(find.text('Nice! Where do you hike?'), findsOneWidget);
      expect(
        h.ai.chats.first.first.content,
        contains('your_role: "hotel front desk clerk"'),
      );
      expect(find.textContaining('점수'), findsNothing);

      await tester.tap(find.widgetWithText(ActionChip, '힌트'));
      await settle(tester);
      expect(find.text('Could you give me a hint?'), findsOneWidget);

      await tester.enterText(
        find.byType(TextField),
        'I want a room for two night',
      );
      await tester.tap(find.text('보내기'));
      await settle(tester);
      expect(find.text('I want a room for two night'), findsOneWidget);

      h.now = h.now.add(const Duration(minutes: 4));
      await tester.tap(find.text('종료'));
      await settle(tester);

      // S08 + S07
      expect(find.text('대화 결과'), findsOneWidget);
      expect(find.text('4분 0초'), findsOneWidget);
      expect(find.text('Kept the conversation going'), findsOneWidget);
      expect(find.text('I want a room for two night'), findsOneWidget);
      expect(find.text('Fixed sentence.'), findsOneWidget);
      expect(find.text('Weekend plans'), findsOneWidget);

      h.mic.queue.add('I want a room for two nights.');
      await tester.ensureVisible(find.text('다시 말하기'));
      await tester.tap(find.text('다시 말하기'));
      await settle(tester);
      expect(
        find.textContaining('방금 말한 문장: I want a room for two nights.'),
        findsOneWidget,
      );

      await tester.ensureVisible(find.text('홈으로'));
      await tester.tap(find.text('홈으로'));
      await settle(tester);
      expect(find.text('복습할 문장'), findsOneWidget);
      expect(find.text('1개'), findsOneWidget);
      expect(find.text('1회 · 완료율 100%'), findsOneWidget);
      expect(find.text('추천 주제: Weekend plans'), findsOneWidget);

      // Review
      await tapText(tester, '복습할 문장');
      expect(find.text('Fixed sentence.'), findsOneWidget);
      await tapText(tester, '말해봤어요');
      expect(find.textContaining('지금 복습할 문장이 없어요'), findsOneWidget);

      // Expressions from the feedback, said in a sentence.
      expect(find.text('최근 배운 표현'), findsOneWidget);
      h.mic.queue.add('That reminds me of my trip to Busan');
      await tapText(tester, '넣어서 말하기');
      expect(find.text('표현을 넣어 말했어요'), findsOneWidget);
    },
  );

  testWidgets('goals preset the setup; daily goal and growth dashboard', (
    tester,
  ) async {
    final h = Harness(
      settings: MemorySettings({
        SettingKeys.onboardingDone: 'true',
        SettingKeys.learningGoal: 'work',
        SettingKeys.dailyGoalMinutes: '45',
      }),
    );
    await h.boot(tester);
    expect(find.text('오늘 0분 / 목표 45분'), findsOneWidget);
    expect(find.text('업무·회의 목표 추천: 의견·토론'), findsOneWidget);

    await tapText(tester, '대화 시작');
    final setup = ProviderScope.containerOf(
      tester.element(find.byType(SetupScreen)),
    ).read(setupProvider);
    expect(setup.mode, SessionMode.opinion);
    expect(setup.length, const Duration(minutes: 45));
    final start = find.widgetWithText(FilledButton, '대화 시작');
    await tester.ensureVisible(start);
    await tester.tap(start);
    await settle(tester);
    await tester.enterText(find.byType(TextField), 'I go to work by bus');
    await tester.tap(find.text('보내기'));
    await settle(tester);
    h.now = h.now.add(const Duration(minutes: 12));
    await tester.tap(find.text('종료'));
    await settle(tester);
    expect(find.text('Fixed sentence.'), findsOneWidget, reason: 'feedback');

    await tester.ensureVisible(find.text('홈으로'));
    await tester.tap(find.text('홈으로'));
    await settle(tester);
    expect(find.text('오늘 12분 / 목표 45분'), findsOneWidget);

    await tapText(tester, '성장 기록');
    expect(find.text('12분'), findsOneWidget);
    expect(find.text('1회'), findsNWidgets(2), reason: 'sessions, grammar');
    expect(find.text('문법 (시제·관사·전치사)'), findsOneWidget);
    expect(find.text('레벨 진단 기록이 없어요.'), findsOneWidget);
    await tapText(tester, '30일');
    expect(find.text('12분'), findsOneWidget);
  });

  testWidgets('phone width: home with goals and the dashboard fit', (
    tester,
  ) async {
    final h = Harness(
      settings: MemorySettings({
        SettingKeys.onboardingDone: 'true',
        SettingKeys.learningGoal: 'interview',
        SettingKeys.dailyGoalMinutes: '30',
      }),
    );
    await h.boot(tester);
    tester.view.physicalSize = const Size(360, 780);
    await settle(tester);
    expect(find.text('오늘 0분 / 목표 30분'), findsOneWidget);
    await tester.tap(find.byTooltip('성장 기록'));
    await settle(tester);
    await tapText(tester, '30일');
    expect(find.text('이 기간에 끝낸 대화가 없어요.'), findsOneWidget);
  });

  testWidgets('hands-free: answers are heard without tapping the mic', (
    tester,
  ) async {
    final h = Harness(
      settings: MemorySettings({SettingKeys.onboardingDone: 'true'}),
    );
    h.mic.queue.add('I went to the beach.');
    await h.boot(tester);
    await tapText(tester, '대화 시작');
    final start = find.widgetWithText(FilledButton, '대화 시작');
    await tester.ensureVisible(start);
    await tester.tap(start);
    await settle(tester);
    expect(find.text('I went to the beach.'), findsOneWidget);
    expect(find.text('Nice! Where do you hike?'), findsNWidgets(2));

    await tester.tap(find.byTooltip('자동 듣기 켜짐 (끄기)'));
    await settle(tester);
    expect(find.byTooltip('자동 듣기 꺼짐 (켜기)'), findsOneWidget);
    expect(h.settings.values[SettingKeys.handsFree], 'false');
  });

  testWidgets('check speech: heard text lands in the box to fix', (
    tester,
  ) async {
    final h = Harness(
      settings: MemorySettings({
        SettingKeys.onboardingDone: 'true',
        SettingKeys.handsFree: 'false',
        SettingKeys.confirmSpeech: 'true',
      }),
    );
    await h.boot(tester);
    await tapText(tester, '대화 시작');
    final start = find.widgetWithText(FilledButton, '대화 시작');
    await tester.ensureVisible(start);
    await tester.tap(start);
    await settle(tester);

    h.mic.queue.add('I go to beach');
    await tester.tap(find.byTooltip('말하기'));
    await settle(tester);
    expect(find.textContaining('들린 문장이에요'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'I go to beach',
    );
    await tester.enterText(find.byType(TextField), 'I went to the beach');
    await tester.tap(find.text('보내기'));
    await settle(tester);
    expect(find.text('I went to the beach'), findsOneWidget);
    expect(find.text('I go to beach'), findsNothing);
  });

  testWidgets('mic problems are explained on the conversation screen', (
    tester,
  ) async {
    final h = Harness();
    await h.boot(tester);
    await tapText(tester, '대화 시작');
    final start = find.widgetWithText(FilledButton, '대화 시작');
    await tester.ensureVisible(start);
    await tester.tap(start);
    await settle(tester);

    h.mic.issue = SpeechIssue.audio;
    await tester.tap(find.byTooltip('말하기'));
    await settle(tester);
    expect(find.textContaining('이어폰·마이크 연결을 확인'), findsOneWidget);

    h.mic.issue = SpeechIssue.permission;
    await tester.tap(find.byTooltip('말하기'));
    await settle(tester);
    expect(find.text('마이크나 음성 인식을 쓸 수 없어요'), findsOneWidget);
    expect(
      find.byType(TextField),
      findsOneWidget,
      reason: 'typing still works',
    );
  });

  testWidgets('Gemini: free key in settings, then conversations use it', (
    tester,
  ) async {
    final h = Harness();
    await h.boot(tester);
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await settle(tester);

    await tapText(tester, 'Gemini (무료 키)');
    expect(find.textContaining('Google 서비스 개선에 쓰이고'), findsWidgets);
    expect(find.textContaining('키가 없어요'), findsWidgets);
    final keyField = find.widgetWithText(TextField, 'Gemini API 키');
    await tester.ensureVisible(keyField);
    await tester.enterText(keyField, 'FAKE-gemini-test-key');
    await tapText(tester, '저장하고 확인');
    expect(h.vault.values['provider.gemini'], 'FAKE-gemini-test-key');
    expect(h.settings.values[SettingKeys.aiProvider], 'gemini');
    expect(find.text('연결됨 · 모델 gemini-test (자동 선택)'), findsOneWidget);
    expect(
      tester.widget<TextField>(keyField).controller!.text,
      isEmpty,
      reason: 'the key is not left on screen',
    );
    expect(find.textContaining('FAKE-gemini'), findsNothing);

    await tester.tap(find.byType(BackButton));
    await settle(tester);
    await tapText(tester, '대화 시작');
    final start = find.widgetWithText(FilledButton, '대화 시작');
    await tester.ensureVisible(start);
    await tester.tap(start);
    await settle(tester);
    expect(find.text('Hello from Gemini. How are you?'), findsOneWidget);
    expect(h.geminiAi.chats, isNotEmpty);
    expect(h.ai.chats, isEmpty, reason: 'ChatGPT not used');
  });

  testWidgets('Gemini chosen without a key: conversation asks to connect', (
    tester,
  ) async {
    final h = Harness(
      settings: MemorySettings({
        SettingKeys.onboardingDone: 'true',
        SettingKeys.handsFree: 'false',
        SettingKeys.aiProvider: 'gemini',
      }),
    );
    await h.boot(tester);
    await tapText(tester, '대화 시작');
    final start = find.widgetWithText(FilledButton, '대화 시작');
    await tester.ensureVisible(start);
    await tester.tap(start);
    await settle(tester);
    expect(find.text('설정에서 연결하기'), findsOneWidget);
    expect(h.geminiAi.chats, isEmpty);
  });

  testWidgets('setup: random topic and random roleplay scenario', (
    tester,
  ) async {
    final h = Harness();
    await h.boot(tester);
    await tapText(tester, '대화 시작');
    await tapText(tester, '테마 대화');
    await tapText(tester, '🎲 랜덤 (AI가 정해요)');
    expect(find.textContaining('AI가 매번 다른 주제를 골라'), findsOneWidget);
    await tapText(tester, '상황 역할극');
    await tapText(tester, '🎲 랜덤 상황 (AI가 정해요)');
    final start = find.widgetWithText(FilledButton, '대화 시작');
    await tester.ensureVisible(start);
    await tester.tap(start);
    await settle(tester);
    expect(h.ai.chats.first.first.content, contains('Invent a realistic'));
    expect(find.text('Nice! Where do you hike?'), findsOneWidget);
  });

  testWidgets('app to the background pauses the conversation', (tester) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    final h = Harness();
    await h.boot(tester);
    await tapText(tester, '대화 시작');
    final start = find.widgetWithText(FilledButton, '대화 시작');
    await tester.ensureVisible(start);
    await tester.tap(start);
    await settle(tester);
    expect(find.text('Nice! Where do you hike?'), findsOneWidget);

    // No frames are drawn while hidden; check once the learner is back.
    for (final state in [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(state);
    }
    await settle(tester);
    expect(find.textContaining('앱을 벗어나서 일시정지했어요'), findsOneWidget);
    await tapText(tester, '이어하기');
    expect(find.textContaining('앱을 벗어나서'), findsNothing);
    expect(find.text('Nice! Where do you hike?'), findsOneWidget);
  });

  testWidgets('unfinished session: banner → continue with its transcript', (
    tester,
  ) async {
    final h = Harness();
    final id = await h.repo.start(const SessionSetup(topic: 'Travel'), h.now);
    await h.repo.addTurn(
      id,
      TurnRecord(
        speaker: Speaker.assistant,
        text: 'Where did you go?',
        startedAt: h.now,
      ),
    );
    await h.repo.addTurn(
      id,
      TurnRecord(
        speaker: Speaker.user,
        text: 'I went to Busan.',
        startedAt: h.now,
      ),
    );
    await h.boot(tester);

    expect(find.text('끝나지 않은 대화가 있어요'), findsOneWidget);
    await tapText(tester, '이어서 하기');
    expect(find.text('I went to Busan.'), findsOneWidget);
    expect(h.ai.chats.single.first.content, contains('back after a break'));
    await tester.tap(find.text('종료'));
    await settle(tester);
    expect(find.text('대화 결과'), findsOneWidget);
  });

  testWidgets('unfinished session: end it and see the result', (tester) async {
    final h = Harness();
    final id = await h.repo.start(const SessionSetup(), h.now);
    await h.repo.addTurn(
      id,
      TurnRecord(speaker: Speaker.user, text: 'Hello there.', startedAt: h.now),
    );
    await h.boot(tester);

    await tapText(tester, '끝내고 결과 보기');
    expect(find.text('대화 결과'), findsOneWidget);
    expect((await h.repo.load(id))!.summary.status, SessionStatus.completed);
    expect(find.text('Fixed sentence.'), findsOneWidget);
  });

  testWidgets('history: search and delete', (tester) async {
    final h = Harness();
    for (final topic in ['Travel', 'Food']) {
      final id = await h.repo.start(
        SessionSetup(mode: SessionMode.theme, topic: topic),
        h.now,
      );
      await h.repo.finish(id, status: SessionStatus.completed, endedAt: h.now);
    }
    await h.boot(tester);
    await tester.tap(find.byTooltip('학습 기록'));
    await settle(tester);
    expect(find.textContaining('Travel'), findsOneWidget);
    expect(find.textContaining('Food'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Food');
    await settle(tester);
    expect(find.textContaining('Travel'), findsNothing);

    await tester.tap(find.byTooltip('삭제'));
    await settle(tester);
    await tester.tap(find.widgetWithText(FilledButton, '삭제'));
    await settle(tester);
    expect(find.text('검색 결과가 없어요.'), findsOneWidget);
    expect(await h.repo.list(), hasLength(1));
  });

  testWidgets('placement: mic check, five answers, suggested level saved', (
    tester,
  ) async {
    final h = Harness();
    await h.boot(tester);
    await tapText(tester, '진단 시작');
    expect(find.textContaining('다섯 가지 질문'), findsOneWidget);

    h.mic.queue.add('Hello, nice to meet you');
    await tester.tap(find.byTooltip('말하기'));
    await settle(tester);
    expect(find.text('들린 말: Hello, nice to meet you'), findsOneWidget);
    await tapText(tester, '다음');

    for (var i = 1; i <= 5; i++) {
      expect(find.text('질문 $i / 5'), findsOneWidget);
      await tester.enterText(
        find.byType(TextField),
        'I usually wake up early and go to work by subway because it is fast and cheap.',
      );
      await tapText(tester, i == 5 ? '결과 보기' : '다음');
    }
    expect(h.voice.spoken, hasLength(5), reason: 'questions are read aloud');
    expect(find.text('추천 레벨: L3'), findsOneWidget);
    expect(find.text('3 / 5'), findsNWidgets(4));
    expect(find.textContaining('발음과 유창성은 평가하지 않았어요'), findsOneWidget);

    await tapText(tester, '이 레벨로 시작');
    expect(find.text('오늘도 영어로 말해볼까요?'), findsOneWidget);
    expect(h.settings.values[SettingKeys.learnerLevel], 'l3');
    expect(find.text('레벨 진단부터 해볼까요?'), findsNothing);
    final saved = await h.repo.list();
    expect(saved.single.setup.mode, SessionMode.assessment);
  });

  testWidgets('settings: diagnostics export has errors, no conversations', (
    tester,
  ) async {
    final h = Harness();
    final id = await h.repo.start(const SessionSetup(), h.now);
    await h.repo.addTurn(
      id,
      TurnRecord(
        speaker: Speaker.user,
        text: 'My secret answer.',
        startedAt: h.now,
      ),
    );
    await h.journal.record(StateError('boom'), null, source: 'flutter');
    await h.boot(tester);
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await settle(tester);
    expect(find.textContaining('최근 1건'), findsOneWidget);

    await tapText(tester, '진단 정보 내보내기');
    final text = h.exporter.exports.single['speaking-coach-diagnostics.txt']!;
    expect(text, contains('StateError: Bad state: boom'));
    expect(text, isNot(contains('My secret answer')));

    await tapText(tester, '오류 기록 지우기');
    expect(await h.journal.entries(), isEmpty);
    expect(find.textContaining('최근 0건'), findsOneWidget);
  });

  testWidgets('language: switch to English and back, saved', (tester) async {
    final h = Harness();
    await h.boot(tester);
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await settle(tester);
    expect(find.text('설정'), findsOneWidget);
    await tapText(tester, 'English');
    expect(find.text('Settings'), findsOneWidget);
    expect(h.settings.values[SettingKeys.appLanguage], 'en');
    await tapText(tester, 'Device');
    expect(find.text('설정'), findsOneWidget);
    expect(h.settings.values[SettingKeys.appLanguage], 'system');
  });

  testWidgets('backup: export, then restore into a fresh install', (
    tester,
  ) async {
    final old = Harness(
      settings: MemorySettings({
        SettingKeys.onboardingDone: 'true',
        SettingKeys.learningGoal: 'work',
        SettingKeys.dailyGoalMinutes: '45',
      }),
    );
    final id = await old.repo.start(const SessionSetup(topic: 'Mars'), old.now);
    await old.repo.addTurn(
      id,
      TurnRecord(
        speaker: Speaker.user,
        text: 'I like rockets.',
        startedAt: old.now,
      ),
    );
    await old.repo.finish(
      id,
      status: SessionStatus.completed,
      endedAt: old.now.add(const Duration(minutes: 3)),
    );
    await old.boot(tester);
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await settle(tester);
    await tapText(tester, '대화 기록 내보내기 (JSON·CSV)');
    final backup = old.exporter.exports.single['speaking-coach.json']!;
    expect(backup, contains('"learner.goal": "work"'));

    // A new install: the old app (and its database) is gone.
    await tester.pumpWidget(const SizedBox());
    final fresh = Harness()..backupPicker.content = backup;
    await fresh.boot(tester);
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await settle(tester);
    await tapText(tester, '백업 파일에서 복원');
    expect(find.text('대화 1개를 복원했어요 (이미 있던 0개는 건너뜀)'), findsOneWidget);
    expect((await fresh.repo.list()).single.setup.topic, 'Mars');
    expect(fresh.settings.values[SettingKeys.learningGoal], 'work');

    await tapText(tester, '백업 파일에서 복원');
    expect(find.text('대화 0개를 복원했어요 (이미 있던 1개는 건너뜀)'), findsOneWidget);

    fresh.backupPicker.content = '{"not": "a backup"}';
    await tapText(tester, '백업 파일에서 복원');
    expect(find.textContaining('백업 파일이 아니에요'), findsOneWidget);
  });

  testWidgets('settings: export has no credentials; delete all', (
    tester,
  ) async {
    final h = Harness();
    h.vault.values['byok.provider.openai'] = 'sk-FAKE-0123456789abcdefghij';
    h.vault.values['byok.chatgpt.session'] = '{"access_token":"tok-FAKE-xyz"}';
    final id = await h.repo.start(const SessionSetup(), h.now);
    await h.repo.addTurn(
      id,
      TurnRecord(speaker: Speaker.user, text: 'My answer.', startedAt: h.now),
    );
    await h.boot(tester);
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await settle(tester);

    await tapText(tester, '대화 기록 내보내기 (JSON·CSV)');
    final files = h.exporter.exports.single;
    final all = files.values.join();
    expect(all, contains('My answer.'));
    expect(all, isNot(contains('sk-FAKE')));
    expect(all, isNot(contains('tok-FAKE')));
    expect(
      jsonDecode(files['speaking-coach.json']!),
      isA<Map<String, Object?>>(),
    );
    expect(find.text('저장 위치: /tmp/export'), findsOneWidget);

    await tapText(tester, '모든 대화 기록 삭제');
    await tester.tap(find.widgetWithText(FilledButton, '삭제'));
    await settle(tester);
    expect(await h.repo.list(), isEmpty);
    expect(h.vault.values, hasLength(2), reason: 'sign-in is kept');
  });
}
