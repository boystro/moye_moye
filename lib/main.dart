import "package:flex_color_picker/flex_color_picker.dart";
import "package:flutter/material.dart";
import "package:moye_moye/helper.dart";
import "package:moye_moye/new_todo.dart";
import "package:moye_moye/todo.dart";
import "package:provider/provider.dart";
import "package:moye_moye/storage.dart";

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Themer()),
        ChangeNotifierProvider(create: (context) => TodoListProvider()),
      ],
      child: App(),
    ),
  );
}

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

class Themer extends ChangeNotifier {
  Themer() {
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

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  get _themer => context.watch<Themer>();
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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Themer get themer => context.read<Themer>();
  Iterable<Todo> get todos => context.watch<TodoListProvider>().todos;
  var searchController = TextEditingController();

  Widget _buildAppbarItem(Widget widget) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: widget,
    );
  }

  Widget _buildTodo(Todo todo) {
    _buildTodoBody() {
      if (todo.body.isNotEmpty) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Text(
            todo.body,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white54
                  : Colors.black54,
            ),
          ),
        );
      } else {
        return SizedBox.shrink();
      }
    }

    return Opacity(
      opacity: todo.isDone ? 0.5 : 1.0,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 1,
        child: InkWell(
          onTap: () => null,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Checkbox(
                        value: todo.isDone,
                        onChanged: (value) async {
                          Todo.update(Todo(
                            id: todo.id,
                            title: todo.title,
                            body: todo.body,
                            isDone: value ?? todo.isDone,
                          ));
                          context.read<TodoListProvider>().refreshList();
                        }),
                    Expanded(
                      child: Text(
                        todo.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        todo.delete().then(
                              (value) => context
                                  .read<TodoListProvider>()
                                  .refreshList(),
                            );
                      },
                      icon: Icon(Icons.delete),
                      iconSize: 20.0,
                    ),
                  ],
                ),
                _buildTodoBody(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTodoViewer(String filter) {
    return ListView(
      children: todos
          .where((item) => item.title.contains(filter))
          .map((e) => _buildTodo(e))
          .toList(),
    );
  }

  AppBar _buildAppbar() {
    return AppBar(
      title: Text("App"),
      actions: [
        _buildAppbarItem(
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () async {
              themer.setMode(switch (await themer.getMode()) {
                ThemeMode.system => ThemeMode.light,
                ThemeMode.light => ThemeMode.dark,
                _ => ThemeMode.system,
              });
            },
            onLongPress: () async {
              final Color initialColor = await themer.getColor();
              var newColor = await showColorPickerDialog(
                context,
                initialColor,
                width: 32,
                height: 32,
                borderRadius: 32,
                spacing: 8,
                runSpacing: 8,
                pickersEnabled: {
                  ColorPickerType.both: false,
                  ColorPickerType.primary: true,
                  ColorPickerType.accent: false,
                  ColorPickerType.bw: false,
                  ColorPickerType.custom: false,
                  ColorPickerType.wheel: false,
                },
                heading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "App Theme Color",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                enableShadesSelection: false,
              );
              themer.setColor(newColor);
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                switch (themer.getModeSync()) {
                  ThemeMode.light => Icons.light_mode,
                  ThemeMode.dark => Icons.dark_mode,
                  _ => Icons.brightness_auto,
                },
                color: themer.getColorSync(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppbar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SearchBar(
                controller: searchController,
                elevation: MaterialStatePropertyAll<double>(0),
                onChanged: (value) => setState(() {
                  searchController.text = value;
                }),
                hintText: "Search",
                leading: IconButton(
                  icon: Icon(
                    Icons.add,
                    size: 16,
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PageNewTodo()),
                  ),
                ),
              ),
              Expanded(
                  child: Container(
                      child: _buildTodoViewer(searchController.text))),
            ],
          ),
        ),
      ),
    );
  }
}
