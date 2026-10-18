import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_coach/app/pasted_callback.dart';
import 'package:speaking_coach/domain/providers/provider_failure.dart';

import '../helpers/app_harness.dart';

void main() {
  testWidgets('web sign-in: paste prompt validates and completes', (
    tester,
  ) async {
    final h = Harness();
    await h.boot(tester);
    // The app's instance, as the sign-in code would use it.
    final container = h.container(tester);
    final real = container.read(pastedCallbackProvider);
    final result = real.request();
    await settle(tester);
    expect(find.text('ChatGPT 로그인 마무리'), findsOneWidget);

    await tester.enterText(find.byType(TextField).last, 'https://example.com');
    await tester.tap(find.text('확인'));
    await settle(tester);
    expect(find.textContaining('로그인 후 받은 주소가 아니에요'), findsOneWidget);

    await tester.enterText(
      find.byType(TextField).last,
      'http://127.0.0.1:1455/auth/callback?code=c&state=s',
    );
    await tester.tap(find.text('확인'));
    await settle(tester);
    expect(await result, {'code': 'c', 'state': 's'});
    expect(find.text('ChatGPT 로그인 마무리'), findsNothing);

    final cancelled = expectLater(
      real.request(),
      throwsA(
        isA<ProviderException>().having(
          (e) => e.failure,
          'failure',
          ProviderFailure.signInRequired,
        ),
      ),
    );
    await settle(tester);
    await tester.tap(find.text('취소'));
    await settle(tester);
    await cancelled;
  });
}
