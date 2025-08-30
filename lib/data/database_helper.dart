import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'binayak_pharmacy.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE medicines(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        expiryDate TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE sales(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        medicineId INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        totalPrice REAL NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (medicineId) REFERENCES medicines (id)
      )
    ''');
    await db.execute('CREATE INDEX idx_medicines_name ON medicines (name)');
    await db.execute('CREATE INDEX idx_medicines_expiryDate ON medicines (expiryDate)');
    await db.execute('CREATE INDEX idx_sales_date ON sales (date)');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  Future<List<Map<String, dynamic>>> getSalesForDay(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return await db.query(
      'sales',
      where: 'date >= ? AND date < ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
    );
  }
}
