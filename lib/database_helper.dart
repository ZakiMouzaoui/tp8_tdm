import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
class DatabaseHelper {
  static const _databaseName = "MusicPlayer.db";
  static const _databaseVersion = 1;
  static const table = 'favorites';
  static const columnId = '_id';
  static const columnName = 'name';
  static const columnArtist = 'artist';
  static const columnURI = 'uri';
  static const isFavorite = 'isFavorite';

  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  // only have a single app-wide reference to the database
  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();
  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

// SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute(''' 
 CREATE TABLE $table ( 
 $columnId INTEGER PRIMARY KEY, 
 $columnName TEXT NOT NULL, 
 $columnArtist TEXT NOT NULL,
 $columnURI TEXT NOT NULL,
 $isFavorite INTEGER
 ) 
 ''');
  }
  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(table);
  }
  
  void delete(String uri) async{
    Database db = await instance.database;
    await db.rawDelete("DELETE FROM $table WHERE uri = ?", [uri]);
  }

  Future<List<Map<String, dynamic>>> getSongs(String uri) async{
    Database db = await instance.database;

    return await db.rawQuery("SELECT * FROM $table WHERE uri = ?", [uri]);
  }

  void close() async{
    Database db = await instance.database;
    await db.close();
  }
}
