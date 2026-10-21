import 'package:package_info_plus/package_info_plus.dart';

import '../../domain/entities/app_version.dart';

/// Reads the version the platform reports for the installed app.
class AppInfoDataSource {
  const AppInfoDataSource();

  Future<AppVersion> readVersion() async {
    final info = await PackageInfo.fromPlatform();
    return AppVersion(version: info.version, buildNumber: info.buildNumber);
  }
}
