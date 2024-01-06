import 'package:flutter/material.dart';
import 'todo.dart';
import 'storage.dart';

class TodoListProvider extends ChangeNotifier {
  TodoListProvider() {
    refreshList();
  }

  Iterable<Todo> todos = Iterable.empty();

  refreshList() async {
    todos = await Todo.get();
    notifyListeners();
  }
}

class ThemeProvider extends ChangeNotifier {
  ThemeProvider() {
    getColor();
    getMode();
  }

  ThemeMode? _themeMode;
  Future<ThemeMode> getMode() async {
    var storedpref = (await sharedPrefs).getString('theme-mode');
    if (storedpref != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (themeMode) => themeMode.toString() == storedpref,
      );
      notifyListeners();
    }
    return _themeMode ?? ThemeMode.system;
  }

  ThemeMode getModeSync() {
    return _themeMode ?? ThemeMode.system;
  }

  Future<void> setMode(ThemeMode mode) async {
    _themeMode = mode;
    await (await sharedPrefs).setString('theme-mode', _themeMode.toString());
    notifyListeners();
  }

  Color? _color;
  Future<Color> getColor() async {
    var storedpref = (await sharedPrefs).getInt('app-color');
    if (storedpref != null) {
      _color = Color(storedpref);
      notifyListeners();
    }
    return _color ?? Colors.black;
  }

  Color getColorSync() {
    return _color ?? Colors.black;
  }

  Future<void> setColor(Color color) async {
    _color = color;
    await (await sharedPrefs).setInt('app-color', _color?.value ?? 0xFF000000);
    notifyListeners();
  }
}
