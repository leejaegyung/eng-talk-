// Persisted by name — renaming a value needs a DB migration.

enum SessionMode {
  daily,
  theme,
  roleplay,
  random,
  storytelling,
  opinion,
  assessment,
}

enum SessionStatus { active, paused, completed, abandoned }

enum Speaker { user, assistant }
