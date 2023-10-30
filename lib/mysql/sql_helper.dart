import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SqlHelper {
  static const _databaseName = "data.db";
  static const _databaseVersion = 1;

  static const table = 'my_table';

  static const columnId = '_id';
  static const columnName = 'name';
  static const columnAge = 'age';

  Future<Database> createDatabase() async {
    final database = await openDatabase(
      join(await getDatabasesPath(), "data.db"),
      onCreate: (db, version) {
        return db.execute('CREATE TABLE eData(id INTEGER PRIMARY KEY, '
            'emp_id TEXT, '
            'in_out TEXT, '
            'lat TEXT, '
            'long TEXT, '
            'emp_photo TEXT, '
            'capture_time TEXT'
            ')');
      },
      version: 1,
    );
    return database;
  }

  Future<bool> insertData(Map<String, dynamic> data) async {
    try {
      final db = await createDatabase();

      await db.insert(
        'eData',
        data,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<String>> getData() async {
    final db = await createDatabase();

    final List<Map<String, dynamic>> maps = await db.query('eData');

    return List.generate(maps.length, (index) {
      return maps[index]['capture_time'];
    });
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await createDatabase();

    final List<Map<String, dynamic>> maps = await db.query('eData');
    return maps;
  }

  Future<void> deleteRecord(int id) async {
    // Get a reference to the database.
    final db = await createDatabase();

    // Remove the Dog from the database.
    await db.delete(
      'eData',
      // Use a `where` clause to delete a specific dog.
      where: 'id = ?',
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }

  Future<int> countRecord() async {
    final db = await createDatabase();
    final result = await db.rawQuery('SELECT COUNT(*) FROM eData');
    final count = Sqflite.firstIntValue(result);
    return count ?? 0;
  }
}
