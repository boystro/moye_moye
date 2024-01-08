import 'storage.dart';

class Todo {
  final int id;
  final String title;
  final String body;
  final bool isDone;

  const Todo({
    this.id = -1,
    required this.title,
    this.body = "",
    this.isDone = false,
  });

  /// table name in sqflite for [Todo]
  static const tableName = 'todos';

  /// Query used to create a table for [Todo]
  static const createTableQuery = """CREATE TABLE $tableName (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title STRING NOT NULL,
    body STRING,
    isDone INTEGER
  )""";

  /// Converts a valid [Map] to [Todo]
  factory Todo.fromDbMap(Map<String, dynamic> _dbmap) {
    return Todo(
      id: _dbmap['id'],
      title: _dbmap['title'].toString(),
      body: _dbmap['body'],
      isDone: _dbmap['isDone'] == 1,
    );
  }

  static Future<int> update(Todo data) async {
    return await (await db).update(
      tableName,
      data.toDbMap(),
      where: "id = ${data.id}",
    );
  }

  /// Converts current [Todo] to [Map]
  Map<String, dynamic> toDbMap() {
    if (id < 1) {
      return {
        'title': title,
        'body': body,
        'isDone': isDone ? 1 : 0,
      };
    } else {
      return {
        'id': id,
        'title': title,
        'body': body,
        'isDone': isDone ? 1 : 0,
      };
    }
  }

  /// Saves Current [Todo] to db.
  Future<int> saveToDb() async {
    if (id > 0) {
      return await update(this);
    }
    return await (await db).insert(tableName, this.toDbMap());
  }

  Future<int> delete() async {
    return await (await db).delete(tableName, where: "id = $id");
  }

  /// Gets [Todo] with [Todo.id] == [_id]
  static Future<Todo?> getOne(int _id) async {
    var queryResult = await (await db).query(tableName, where: "id = $_id");
    var todo = queryResult.firstOrNull;
    if (todo != null) {
      return Todo.fromDbMap(todo);
    }
    return null;
  }

  /// if [_ids] is provided, then gets [Todo]s with matching id
  /// else gets all [Todo].
  static Future<Iterable<Todo>> get([List<int>? _ids]) async {
    if (_ids == null) {
      var queryResult = await (await db).query(tableName);
      return queryResult.map((item) => Todo.fromDbMap(item));
    } else {
      var condition = "id in (${_ids.join(',')})";
      var queryResult = await (await db).query(tableName, where: condition);
      return queryResult.map((item) => Todo.fromDbMap(item));
    }
  }
}
