import 'package:flutter/widgets.dart';

import 'config/app_config.dart';
import 'di/bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = AppConfig.fromEnvironment();
  final app = await bootstrapWithYouApp(config);
  runApp(app);
}
