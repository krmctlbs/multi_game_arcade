import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:multi_game_arcade/services/auth/auth_service.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/my_weather_widget.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  
  final themeOptions = {
    ThemeMode.system: 'System Default',
    ThemeMode.dark: 'Dark',
    ThemeMode.light: 'Light',
  };

  void signOut() {
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    ThemeMode currentMode = MyApp.themeNotifier.value;
    final userEmail = FirebaseAuth.instance.currentUser?.email ?? 'Not logged in';
    final userName = userEmail.split('@').first;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),

      body: Container(
        child: Column(
          children: [
            const SizedBox(height: 16),
            ListTile(
              title: const Text("Theme"),
              trailing: DropdownButton<ThemeMode>(
                value: currentMode,
                items: themeOptions.entries.map((entry) {
                  return DropdownMenuItem<ThemeMode>(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (ThemeMode? newMode) {
                  if (newMode != null) {
                    setState(() {
                      MyApp.themeNotifier.value = newMode;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.email),
              title: Text("Hi, $userName I hope you're enjoying:)"),
              subtitle: Text(userEmail),
              trailing: IconButton(
                onPressed: signOut,
                icon: const Icon(Icons.logout),
              ) ,
            ),
            MyWeatherWidget()
          ],

        ),

      ),
    );
  }
}
