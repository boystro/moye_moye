import 'package:moye_moye/todo.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

const String dbName = "master.db";
Database? _db;
Future<Database> get db async {
  _db ??= await _initDB();
  return _db!;
}

Future<SharedPreferences> get sharedPrefs async {
  return await SharedPreferences.getInstance();
}

Future<Database> _initDB() async {
  var dbPath = await getDatabasesPath();

  return await openDatabase(
    path.join(dbPath, dbName),
    version: 1,
    onCreate: (db, v) {
      db.execute(Todo.createTableQuery);
    },
  );
}
