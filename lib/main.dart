import 'package:afmnziyo/firebase_options.dart';
import 'package:afmnziyo/pages/home_page.dart';
import 'package:afmnziyo/services/theme_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const AfmApp());
}

class AfmApp extends StatefulWidget {
  const AfmApp({super.key});

  @override
  State<AfmApp> createState() => _AfmAppState();
}

class _AfmAppState extends State<AfmApp> {
  final ThemeService _themeService = ThemeService();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _themeService,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: _themeService.getThemeData(),
          home: AfmHomePage(themeService: _themeService),
        );
      },
    );
  }
}
