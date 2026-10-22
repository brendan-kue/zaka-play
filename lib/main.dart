import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'state.dart';
import 'theme.dart';
import 'screens/start.dart';
import 'screens/shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final state = AppState();
  await state.load();
  runApp(ChangeNotifierProvider.value(value: state, child: const ZakaApp()));
}

class ZakaApp extends StatelessWidget {
  const ZakaApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zaka Play',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const Root(),
    );
  }
}

class Root extends StatelessWidget {
  const Root({super.key});
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    if (s.signedIn) return const Shell();
    return const SplashScreen();
  }
}
