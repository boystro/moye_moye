import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers.dart';
import 'App.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => TodoListProvider()),
      ],
      child: const App(),
    ),
  );
}
