import 'package:equatable/equatable.dart';

/// The installed app's version, e.g. 1.0.0 build 1.
class AppVersion extends Equatable {
  const AppVersion({required this.version, required this.buildNumber});

  final String version;
  final String buildNumber;

  @override
  List<Object> get props => [version, buildNumber];
}
