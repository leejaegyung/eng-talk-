/// `X.Y.Z` release versions (ADR-018). Local builds have none.
final class AppVersion implements Comparable<AppVersion> {
  const AppVersion(this.major, this.minor, this.patch);

  final int major;
  final int minor;
  final int patch;

  static final _pattern = RegExp(r'^v?(\d+)\.(\d+)\.(\d+)$');

  /// "0.9.0" or "v0.9.0"; null for anything else (pre-releases included,
  /// so nobody is pushed onto one).
  static AppVersion? tryParse(String? text) {
    final m = _pattern.firstMatch(text?.trim() ?? '');
    if (m == null) return null;
    return AppVersion(int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3]!));
  }

  @override
  int compareTo(AppVersion other) => major != other.major
      ? major.compareTo(other.major)
      : minor != other.minor
      ? minor.compareTo(other.minor)
      : patch.compareTo(other.patch);

  bool operator >(AppVersion other) => compareTo(other) > 0;

  @override
  bool operator ==(Object other) =>
      other is AppVersion && compareTo(other) == 0;

  @override
  int get hashCode => Object.hash(major, minor, patch);

  @override
  String toString() => '$major.$minor.$patch';
}

/// The newest published version and where to get it.
final class AppRelease {
  const AppRelease({required this.version, required this.page, this.apk});

  final AppVersion version;

  /// Release page with every installer.
  final Uri page;

  /// The Android installer, when the release has one.
  final Uri? apk;
}

/// Where the newest version is looked up.
abstract interface class ReleaseFeed {
  /// Null when it can't be told (offline, no release, unexpected reply).
  Future<AppRelease?> latest();
}

/// Brings the app to [AppRelease.version] the way the platform allows.
abstract interface class AppUpdater {
  /// What [apply] does here.
  UpdateMethod get method;

  /// Throws when it couldn't; [onProgress] gets 0..1 while downloading.
  Future<void> apply(AppRelease release, {void Function(double)? onProgress});
}

enum UpdateMethod {
  /// Android: download the APK and open the system installer.
  install,

  /// Web: load the new version.
  reload,

  /// Desktop: open the release page to download it.
  openPage,
}

/// [latest] when it's newer than [current]; never for local builds.
AppRelease? newerRelease(AppVersion? current, AppRelease? latest) =>
    current != null && latest != null && latest.version > current
    ? latest
    : null;
