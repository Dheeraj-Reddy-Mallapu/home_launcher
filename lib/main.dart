import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:home_launcher/apps_screen.dart';
import 'package:home_launcher/provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final defaultLightColorScheme = ColorScheme.fromSeed(seedColor: Colors.blueGrey);
    final defaultDarkColorScheme = ColorScheme.fromSeed(seedColor: Colors.blueGrey, brightness: Brightness.dark);

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return ChangeNotifierProvider(
          create: (context) => AppsProvider()..getApplications(),
          child: MaterialApp(
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: lightDynamic ?? defaultLightColorScheme,
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: darkDynamic ?? defaultDarkColorScheme,
            ),
            home: const AppsScreen(),
          ),
        );
      },
    );
  }
}
