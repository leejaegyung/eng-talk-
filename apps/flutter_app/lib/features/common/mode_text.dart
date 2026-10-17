import 'package:flutter/material.dart';

import '../../app/l10n/gen/app_localizations.dart';
import '../../domain/conversation/session_enums.dart';

String modeName(AppLocalizations l10n, SessionMode m) => switch (m) {
  SessionMode.daily => l10n.conversationModeDaily,
  SessionMode.theme => l10n.modeTheme,
  SessionMode.roleplay => l10n.modeRoleplay,
  SessionMode.random => l10n.modeRandom,
  SessionMode.storytelling => l10n.modeStorytelling,
  SessionMode.opinion => l10n.modeOpinion,
  SessionMode.assessment => l10n.modeAssessment,
};

String modeDescription(AppLocalizations l10n, SessionMode m) => switch (m) {
  SessionMode.daily => l10n.modeDailyDesc,
  SessionMode.theme => l10n.modeThemeDesc,
  SessionMode.roleplay => l10n.modeRoleplayDesc,
  SessionMode.random => l10n.modeRandomDesc,
  SessionMode.storytelling => l10n.modeStorytellingDesc,
  SessionMode.opinion => l10n.modeOpinionDesc,
  SessionMode.assessment => l10n.modeAssessment,
};

IconData modeIcon(SessionMode m) => switch (m) {
  SessionMode.daily => Icons.wb_sunny_outlined,
  SessionMode.theme => Icons.topic_outlined,
  SessionMode.roleplay => Icons.theater_comedy_outlined,
  SessionMode.random => Icons.casino_outlined,
  SessionMode.storytelling => Icons.auto_stories_outlined,
  SessionMode.opinion => Icons.forum_outlined,
  SessionMode.assessment => Icons.assignment_outlined,
};
