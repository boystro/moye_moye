import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers.dart';
import 'HomePage.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  get _themer => context.watch<ThemeProvider>();
  get _themeMode => _themer.getModeSync();
  get _colorSchemeSeed => _themer.getColorSync();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: _themeMode,
      theme: ThemeData(
        colorSchemeSeed: _colorSchemeSeed,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: _colorSchemeSeed,
        brightness: Brightness.dark,
      ),
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
