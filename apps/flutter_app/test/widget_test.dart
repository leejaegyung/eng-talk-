import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_coach/app/app.dart';

void main() {
  testWidgets('app boots to the home screen in Korean', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('ko')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(const ProviderScope(child: SpeakingCoachApp()));
    await tester.pumpAndSettle();

    expect(find.text('오늘도 영어로 말해볼까요?'), findsOneWidget);
    expect(find.text('대화 시작'), findsOneWidget);
  });

  testWidgets('home opens the audio test screen', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('ko')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(const ProviderScope(child: SpeakingCoachApp()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('오디오 테스트 (개발용)'));
    await tester.pumpAndSettle();

    expect(find.text('오디오 테스트'), findsOneWidget);
    expect(find.text('녹음'), findsOneWidget);
  });
}
