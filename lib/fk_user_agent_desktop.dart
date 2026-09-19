import 'dart:io';

/// Generates user agent properties for the desktop platforms (macOS, Linux and
/// Windows) where the plugin has no native MethodChannel implementation.
///
/// The returned [Map] mirrors the shape produced by the Android/iOS plugins so
/// that `FkUserAgent` keeps a consistent API across every supported target.
/// The user agent strings are browser-like, which lets servers that parse the
/// header still identify the operating system and architecture.
Map<String, dynamic> generateProperties() {
  final String systemName;
  final String systemVersion;
  final String userAgent;

  if (Platform.isMacOS) {
    systemName = 'Mac OS X';
    systemVersion = _joinVersion(Platform.operatingSystemVersion, '.');
    userAgent = 'Mozilla/5.0 (Macintosh; $_macModel Mac OS X '
        '${_joinVersion(Platform.operatingSystemVersion, '_')}) '
        'AppleWebKit/605.1.15 (KHTML, like Gecko) '
        'Version/$_safariVersion Safari/605.1.15';
  } else if (Platform.isWindows) {
    systemName = 'Windows';
    systemVersion = _windowsVersion(Platform.operatingSystemVersion);
    userAgent = 'Mozilla/5.0 (Windows NT $systemVersion; $_windowsArch) '
        'AppleWebKit/537.36 (KHTML, like Gecko) '
        'Chrome/$_chromeVersion Safari/537.36';
  } else {
    systemName = 'Linux';
    systemVersion = _joinVersion(Platform.operatingSystemVersion, '.');
    userAgent = 'Mozilla/5.0 (X11; $_linuxArch) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Chrome/$_chromeVersion Safari/537.36';
  }

  return <String, dynamic>{
    'systemName': systemName,
    'systemVersion': systemVersion,
    'userAgent': userAgent,
    'webViewUserAgent': userAgent,
    'packageUserAgent': userAgent,
    'applicationName': '',
    'applicationVersion': '',
    'applicationBuildNumber': 0,
    'architecture': _architecture(),
  };
}

const String _safariVersion = '17.2';
const String _chromeVersion = '120.0.0.0';

final RegExp _versionPattern = RegExp(r'(\d+)(?:\.(\d+))?(?:\.(\d+))?');

/// Extracts the numeric version components (up to three) of a raw operating
/// system version string, e.g. "Version 14.2.1 (Build 23C71)" -> "14.2.1" or
/// "Linux 7.0.0-31-generic ..." -> "7.0.0".
List<String> _parseVersion(String raw) {
  final Match? match = _versionPattern.firstMatch(raw);
  if (match == null) {
    return <String>[];
  }
  return <String>[
    match.group(1) ?? '',
    match.group(2) ?? '',
    match.group(3) ?? '',
  ].where((part) => part.isNotEmpty).toList();
}

String _joinVersion(String raw, String separator) {
  final List<String> parts = _parseVersion(raw);
  return parts.isEmpty ? '' : parts.join(separator);
}

String _windowsVersion(String raw) {
  final List<String> parts = _parseVersion(raw);
  if (parts.isEmpty) {
    return '';
  }
  return parts.length > 1 ? '${parts[0]}.${parts[1]}' : parts[0];
}

/// Derives the architecture token (e.g. "x64", "arm64") from
/// [Platform.version], which reports the ABI as `on "linux_x64"`,
/// `on "macos_arm64"`, `on "windows_x64"`, etc.
String _architecture() {
  final Match? match = RegExp(r'on "([^"]+)"').firstMatch(Platform.version);
  final String abi = (match?.group(1) ?? '').toLowerCase();
  if (abi.contains('arm64') || abi.contains('aarch64')) {
    return 'arm64';
  }
  return 'x64';
}

String get _macModel => _architecture() == 'arm64' ? 'ARM' : 'Intel';

String get _windowsArch => _architecture() == 'arm64' ? 'ARM64' : 'Win64; x64';

String get _linuxArch => _architecture() == 'arm64' ? 'aarch64' : 'x86_64';