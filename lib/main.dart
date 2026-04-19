import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'services/hive_service.dart';
import 'screens/app_shell.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  runApp(const CrjtApp());
}

class CrjtApp extends StatelessWidget {
  const CrjtApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRJT',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('fr', 'FR')],
      home: const AppShell(),
    );
  }
}
