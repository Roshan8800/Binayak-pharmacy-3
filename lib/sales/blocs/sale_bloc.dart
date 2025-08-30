import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:binayak_pharmacy/sales/blocs/sale_event.dart';
import 'package:binayak_pharmacy/sales/blocs/sale_state.dart';
import 'package:binayak_pharmacy/data/database_helper.dart';
import 'package:binayak_pharmacy/data/models/medicine_model.dart';
import 'package:binayak_pharmacy/sales/data/models/sale_model.dart';

class SaleBloc extends Bloc<SaleEvent, SaleState> {
  final DatabaseHelper _databaseHelper;

  SaleBloc(this._databaseHelper) : super(SaleInitial()) {
    on<AddSale>(_onAddSale);
    on<LoadSales>(_onLoadSales);
  }

  Future<void> _onAddSale(AddSale event, Emitter<SaleState> emit) async {
    emit(SaleInProgress());
    try {
      final db = await _databaseHelper.database;
      await db.transaction((txn) async {
        final medicine = await txn.query(
          'medicines',
          where: 'id = ?',
          whereArgs: [event.sale.medicineId],
        );
        final currentQuantity = medicine.first['quantity'] as int;
        if (currentQuantity >= event.sale.quantity) {
          final updatedQuantity = currentQuantity - event.sale.quantity;
          await txn.update(
            'medicines',
            {'quantity': updatedQuantity},
            where: 'id = ?',
            whereArgs: [event.sale.medicineId],
          );
          await txn.insert('sales', event.sale.toMap());
        } else {
          throw Exception('Not enough stock');
        }
      });
      emit(SaleAddSuccess());
    } catch (e) {
      emit(SaleFailure(e.toString()));
    }
  }

  Future<void> _onLoadSales(LoadSales event, Emitter<SaleState> emit) async {
    emit(SaleInProgress());
    try {
      final db = await _databaseHelper.database;
      final maps = await db.query('sales');
      final sales = maps.map((map) => Sale.fromMap(map)).toList();
      emit(SaleSuccess(sales: sales));
    } catch (e) {
      emit(SaleFailure(e.toString()));
    }
  }
}
