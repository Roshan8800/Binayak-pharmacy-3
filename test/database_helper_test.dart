import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:binayak_pharmacy/data/database_helper.dart';
import 'package:binayak_pharmacy/data/models/medicine_model.dart';
import 'package:path/path.dart';

void main() {
  // Initialize FFI
  sqfliteFfiInit();

  // Use a mock database factory for testing
  databaseFactory = databaseFactoryFfi;

  group('DatabaseHelper', () {
    late DatabaseHelper dbHelper;

    setUp(() async {
      // Ensure a new helper is created for each test
      dbHelper = DatabaseHelper();
      // Clean the database before each test to ensure a clean slate
      final db = await dbHelper.database;
      await db.delete('medicines');
      await db.delete('sales');
    });

    test('should insert a medicine into the database', () async {
      // Arrange
      final medicine = Medicine(
        name: 'Test Medicine',
        description: 'A test medicine',
        quantity: 10,
        price: 9.99,
        expiryDate: DateTime.now(),
      );

      // Act
      final db = await dbHelper.database;
      await db.insert('medicines', medicine.toMap());

      // Assert
      final maps = await db.query('medicines');
      expect(maps.length, 1);
      expect(maps.first['name'], 'Test Medicine');
    });
  });
}
