import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:binayak_pharmacy/data/database_helper.dart';
import 'package:binayak_pharmacy/data/models/medicine_model.dart';
import 'package:binayak_pharmacy/sales/blocs/sale_bloc.dart';
import 'package:binayak_pharmacy/sales/blocs/sale_event.dart';
import 'package:binayak_pharmacy/sales/blocs/sale_state.dart';
import 'package:binayak_pharmacy/sales/data/models/sale_model.dart';
import 'package:matcher/matcher.dart';

void main() {
  late DatabaseHelper databaseHelper;
  late SaleBloc saleBloc;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    databaseHelper = DatabaseHelper();
  });

  setUp(() async {
    saleBloc = SaleBloc(databaseHelper);
    final db = await databaseHelper.database;
    await db.delete('sales');
    await db.delete('medicines');
  });

  tearDown(() {
    saleBloc.close();
  });

  tearDownAll(() {
    databaseHelper.close();
  });

  group('SaleBloc Integration Test', () {
    test('initial state is SaleInitial', () {
      expect(saleBloc.state, isA<SaleInitial>());
    });

    test('emits [SaleInProgress, SaleSuccess] with empty list when no sales exist', () async {
      final expectedResponse = [
        isA<SaleInProgress>(),
        isA<SaleSuccess>().having((s) => s.sales, 'sales', isEmpty),
      ];

      expectLater(saleBloc.stream, emitsInOrder(expectedResponse));

      saleBloc.add(LoadSales());
    });

    test('emits [SaleInProgress, SaleAddSuccess] when AddSale is added successfully', () async {
      // Arrange: Insert a medicine to sell
      final db = await databaseHelper.database;
      await db.insert(
        'medicines',
        Medicine(
          id: 1,
          name: 'Test Med',
          description: 'A medicine for testing',
          quantity: 10,
          price: 5.0,
          expiryDate: DateTime.now().add(const Duration(days: 365)),
        ).toMap(),
      );

      final expectedResponse = [
        isA<SaleInProgress>(),
        isA<SaleAddSuccess>(),
      ];

      expectLater(saleBloc.stream, emitsInOrder(expectedResponse)).then((_) async {
        // Verify that the medicine quantity was updated
        final db = await databaseHelper.database;
        final medicine = await db.query('medicines', where: 'id = ?', whereArgs: [1]);
        expect(medicine.first['quantity'], 8);
        // Verify that the sale was recorded
        final sales = await db.query('sales');
        expect(sales.length, 1);
        expect(sales.first['medicineId'], 1);
      });

      // Act
      final sale = Sale(
        medicineId: 1,
        quantity: 2,
        totalPrice: 10.0,
        date: DateTime.now(),
      );
      saleBloc.add(AddSale(sale));
    });

    test('emits [SaleInProgress, SaleFailure] when adding a sale with insufficient stock', () async {
      // Arrange: Insert a medicine with low stock
      final db = await databaseHelper.database;
       await db.insert(
          'medicines',
          Medicine(
            id: 1,
            name: 'Test Med',
            description: 'A medicine for testing',
            quantity: 1,
            price: 5.0,
            expiryDate: DateTime.now().add(const Duration(days: 365)),
          ).toMap(),
        );

      final expectedResponse = [
        isA<SaleInProgress>(),
        isA<SaleFailure>().having((e) => e.message, 'message', contains('Not enough stock')),
      ];

      expectLater(saleBloc.stream, emitsInOrder(expectedResponse)).then((_) async {
        // Verify that the medicine quantity was NOT updated
        final db = await databaseHelper.database;
        final medicine = await db.query('medicines', where: 'id = ?', whereArgs: [1]);
        expect(medicine.first['quantity'], 1);
        // Verify that no sale was recorded
        final sales = await db.query('sales');
        expect(sales.isEmpty, isTrue);
      });

      // Act
      final sale = Sale(
        medicineId: 1,
        quantity: 2, // Trying to sell more than available
        totalPrice: 10.0,
        date: DateTime.now(),
      );
      saleBloc.add(AddSale(sale));
    });
  });
}
