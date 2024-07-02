import 'dart:async';
import 'dart:io';

import 'package:database_flutter_app/models/note.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static DatabaseHelper? _databaseHelper; // Make _databaseHelper nullable
  static Database? _database; // Make _database nullable

  String noteTable = 'note_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colDate = 'date';
  String colPriority = 'priority';

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    _databaseHelper ??= DatabaseHelper._createInstance(); // Initialize if null
    return _databaseHelper!;
  }

  Future<Database> get database async {
    _database ??= await initializeDatabase(); // Initialize if null
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, "notes.db");

    var notesDatabase = await openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colDescription TEXT, $colPriority INTEGER, $colDate TEXT)');
  }

  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await this.database;
    var result = await db.query(noteTable, orderBy: '$colPriority ASC');
    return result;
  }

  Future<int> insert(Note note) async {
    Database db = await this.database;
    int resultId = await db.insert(noteTable, note.toMap());
    return resultId;
  }

  Future<int> update(Note note) async {
    Database db = await this.database;
    var result = await db.update(noteTable, note.toMap(),
        where: '$colId = ?', whereArgs: [note.id]);
    return result;
  }

  Future<int> delete(int id) async {
    var db = await this.database;
    var result =
        await db.delete(noteTable, where: '$colId = ?', whereArgs: [id]);
    return result;
  }

  Future<int> getCount() async {
    var db = await this.database;
    List<Map<String, dynamic>> list =
        await db.rawQuery('SELECT COUNT (*) from $noteTable');
    int result = Sqflite.firstIntValue(list)!; // Add non-null assertion operator
    return result;
  }

  Future<List<Note>> getNotesList() async {
    List<Map<String, dynamic>> notesMapList = await getNoteMapList();
    int count = notesMapList.length;
    List<Note> notesList = []; // Use empty list literal
    for (int i = 0; i < count; i++) {
      notesList.add(Note.fromMapObject(notesMapList[i]));
    }
    return notesList;
  }
}