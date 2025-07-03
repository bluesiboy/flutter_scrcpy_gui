import 'dart:io';

class PathHistory {
  static final Set<String> scrcpyPaths = <String>{};
  static final Set<String> adbPaths = <String>{};
  static final Map<String, String> scrcpyVersions = {};
  static final Map<String, String> adbVersions = {};

  static void addScrcpyPath(String? path) {
    if (path != null && path.isNotEmpty) {
      scrcpyPaths.add(path);
      _fetchScrcpyVersion(path);
    }
  }

  static void addAdbPath(String? path) {
    if (path != null && path.isNotEmpty) {
      adbPaths.add(path);
      _fetchAdbVersion(path);
    }
  }

  static List<String> getScrcpyPaths() => scrcpyPaths.toList();
  static List<String> getAdbPaths() => adbPaths.toList();

  static List<String> getScrcpyDisplayList() {
    return scrcpyPaths.map((p) {
      final v = scrcpyVersions[p];
      return v != null ? '$p  ($v)' : p;
    }).toList();
  }

  static List<String> getAdbDisplayList() {
    return adbPaths.map((p) {
      final v = adbVersions[p];
      return v != null ? '$p  ($v)' : p;
    }).toList();
  }

  static void clear() {
    scrcpyPaths.clear();
    adbPaths.clear();
    scrcpyVersions.clear();
    adbVersions.clear();
  }

  /// 扫描环境变量 PATH 下所有 scrcpy/adb 可执行文件
  static Future<void> scanExecutablesFromEnv() async {
    final envPath = Platform.environment['PATH'] ?? '';
    final paths = envPath.split(Platform.isWindows ? ';' : ':');
    final exeNames = Platform.isWindows ? ['scrcpy.exe', 'adb.exe'] : ['scrcpy', 'adb'];
    for (final dir in paths) {
      try {
        final d = Directory(dir);
        if (!await d.exists()) continue;
        final files = await d.list().toList();
        for (final file in files) {
          if (file is File) {
            final name = file.uri.pathSegments.last;
            if (name == exeNames[0]) addScrcpyPath(file.path);
            if (name == exeNames[1]) addAdbPath(file.path);
          }
        }
      } catch (_) {}
    }
  }

  static Future<void> _fetchScrcpyVersion(String path) async {
    if (scrcpyVersions.containsKey(path)) return;
    try {
      final result = await Process.run(path, ['--version']);
      if (result.exitCode == 0) {
        final lines = result.stdout.toString().split('\n');
        final versionLine = lines.firstWhere((l) => l.trim().isNotEmpty, orElse: () => '').trim();
        final match = RegExp(r'(\d+\.\d+(?:\.\d+)*)').firstMatch(versionLine);
        final version = match != null ? match.group(0) : null;
        if (version != null && version.isNotEmpty) {
          scrcpyVersions[path] = 'v$version';
        }
      }
    } catch (_) {}
  }

  static Future<void> _fetchAdbVersion(String path) async {
    if (adbVersions.containsKey(path)) return;
    try {
      final result = await Process.run(path, ['version']);
      if (result.exitCode == 0) {
        final lines = result.stdout.toString().split('\n');
        final versionLine = lines.firstWhere((l) => l.contains('version'), orElse: () => '').trim();
        final match = RegExp(r'(\d+\.\d+(?:\.\d+)*)').firstMatch(versionLine);
        final version = match != null ? match.group(0) : null;
        if (version != null && version.isNotEmpty) {
          adbVersions[path] = 'v$version';
        }
      }
    } catch (_) {}
  }
}
