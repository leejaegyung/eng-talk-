import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_coach/domain/conversation/session_enums.dart';
import 'package:speaking_coach/domain/sessions/session_records.dart';
import 'package:speaking_coach/domain/settings/settings_store.dart';

import '../helpers/app_harness.dart';

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
    },
  );

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
