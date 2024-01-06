import 'package:flutter/material.dart';
import 'package:moye_moye/main.dart';
import 'package:moye_moye/todo.dart';
import 'package:provider/provider.dart';

class PageNewTodo extends StatefulWidget {
  const PageNewTodo({super.key});

  @override
  State<PageNewTodo> createState() => _PageNewTodoState();
}

class _PageNewTodoState extends State<PageNewTodo> {
  bool _isDone = false;

  var _titleController = TextEditingController();
  var _bodyController = TextEditingController();

  void save() {
    var todo = Todo(
      title: _titleController.text,
      body: _bodyController.text,
      isDone: _isDone,
    );
    print(todo.toDbMap());
    todo.saveToDb();
    Navigator.pop(context);
    context.read<TodoListProvider>().refreshList();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(
          child: Text(
            "Todo Created",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        behavior: SnackBarBehavior.floating,
        shape: StadiumBorder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New Todo"),
      ),
      body: Column(
        children: [
          Expanded(
              child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  style: Theme.of(context).textTheme.headlineSmall,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Title",
                    hintStyle: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white60
                              : Colors.black54,
                        ),
                  ),
                  onChanged: (value) => _titleController.text = value,
                ),
                TextField(
                  controller: _bodyController,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Body...",
                      hintStyle: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white60
                            : Colors.black54,
                      )),
                  onChanged: (value) => _bodyController.text = value,
                  maxLines: null,
                )
              ],
            ),
          )),
          Divider(),
          Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              bottom: 8.0,
            ),
            child: Row(
              children: [
                Checkbox(
                  value: _isDone,
                  onChanged: (value) => setState(() {
                    _isDone = value ?? false;
                  }),
                ),
                Expanded(child: Text("Completed")),
                ElevatedButton(
                  onPressed: save,
                  child: Text("Create"),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
