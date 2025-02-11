import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:multi_game_arcade/firebase_options.dart';
import 'package:multi_game_arcade/services/auth/auth_gate.dart';
import 'package:multi_game_arcade/services/auth/auth_service.dart';
import 'package:multi_game_arcade/services/db/firebase_api.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseApi().initNotifications();
  runApp(
    ChangeNotifierProvider(create: (context) => AuthService(),
    child: const MyApp(),
    ),
  );

}

class MyApp extends StatelessWidget {
  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (context, ThemeMode currentThemeMode, child) {
          return MaterialApp(
            title: 'Multi Game Arcade',
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: currentThemeMode,
            debugShowCheckedModeBanner: false,
            home: const AuthGate(), // Use the new AuthGate for initial route
          );
        },
      );
  }
}
