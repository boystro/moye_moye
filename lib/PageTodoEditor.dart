import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers.dart';
import 'todo.dart';

class PageTodoEditor extends StatefulWidget {
  const PageTodoEditor({super.key, this.todo});

  final Todo? todo;

  @override
  State<PageTodoEditor> createState() => _PageTodoEditorState();
}

class _PageTodoEditorState extends State<PageTodoEditor> {
  var _isDone = false;
  var _title = '';
  var _body = '';

  var _titleController = TextEditingController();
  var _bodyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _title = _titleController.text = widget.todo?.title ?? '';
    _body = _bodyController.text = widget.todo?.body ?? '';
    _isDone = widget.todo?.isDone ?? false;
  }

  void save() {
    var todo = Todo(
      title: _title,
      body: _body,
      isDone: _isDone,
      id: widget.todo?.id ?? -1,
    );
    todo.saveToDb();
    Navigator.pop(context);
    context.read<TodoListProvider>().refreshList();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(
          child: Text(
            todo.id > 0 ? "Todo Updated" : "Todo Created",
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
        title: Text(widget.todo == null ? "New Todo" : "Edit Todo"),
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
                  onChanged: (value) => _title = value,
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
                  onChanged: (value) => _body = value,
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
                  child: Text(widget.todo == null ? "Create" : "Save"),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
