// Forced-close recovery on the real on-disk database (P1-A7):
//   flutter test integration_test/session_recovery_test.dart -d macos --dart-define=PHASE=crash
//   flutter test integration_test/session_recovery_test.dart -d macos --dart-define=PHASE=recover
// "crash" leaves a session active and exits without finishing it; a new
// launch must find it with its transcript.
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:speaking_coach/data/db/app_database.dart';
import 'package:speaking_coach/data/sessions/drift_session_repository.dart';
import 'package:speaking_coach/domain/conversation/session_enums.dart';
import 'package:speaking_coach/domain/sessions/session_records.dart';

const phase = String.fromEnvironment('PHASE');
const marker = 'itest-recovery';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('recovery phase "$phase"', (tester) async {
    final db = AppDatabase.open();
    final repo = DriftSessionRepository(db);
    switch (phase) {
      case 'crash':
        final id = await repo.start(
          const SessionSetup(topic: marker),
          DateTime.now(),
        );
        await repo.addTurn(
          id,
          TurnRecord(
            speaker: Speaker.user,
            text: 'Before the crash.',
            startedAt: DateTime.now(),
          ),
        );
      // No finish(), no close: the process ends here.
      case 'recover':
        final u = await repo.unfinished();
        expect(u, isNotNull);
        expect(u!.setup.topic, marker);
        final detail = await repo.load(u.id);
        expect(detail!.turns.single.text, 'Before the crash.');
        await repo.delete(u.id); // leave the user's data as it was
        expect(await repo.unfinished(), isNull);
        await db.close();
      default:
        fail('pass --dart-define=PHASE=crash|recover');
    }
  });
}
