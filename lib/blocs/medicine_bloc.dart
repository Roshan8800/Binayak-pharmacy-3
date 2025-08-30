import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:binayak_pharmacy/blocs/medicine_event.dart';
import 'package:binayak_pharmacy/blocs/medicine_state.dart';
import 'package:binayak_pharmacy/data/database_helper.dart';
import 'package:binayak_pharmacy/data/models/medicine_model.dart';

class MedicineBloc extends Bloc<MedicineEvent, MedicineState> {
  final DatabaseHelper _databaseHelper;

  MedicineBloc(this._databaseHelper) : super(MedicineLoading()) {
    on<LoadMedicines>(_onLoadMedicines);
    on<AddMedicine>(_onAddMedicine);
    on<UpdateMedicine>(_onUpdateMedicine);
    on<DeleteMedicine>(_onDeleteMedicine);
  }

  Future<void> _onLoadMedicines(LoadMedicines event, Emitter<MedicineState> emit) async {
    emit(MedicineLoading());
    try {
      final db = await _databaseHelper.database;
      final maps = await db.query('medicines');
      final medicines = maps.map((map) => Medicine.fromMap(map)).toList();
      emit(MedicineLoaded(medicines: medicines));
    } catch (e) {
      emit(MedicineError(e.toString()));
    }
  }

  Future<void> _onAddMedicine(AddMedicine event, Emitter<MedicineState> emit) async {
    try {
      final db = await _databaseHelper.database;
      await db.insert('medicines', event.medicine.toMap());
      emit(MedicineAddSuccess());
    } catch (e) {
      emit(MedicineAddFailure(e.toString()));
    }
  }

  Future<void> _onUpdateMedicine(UpdateMedicine event, Emitter<MedicineState> emit) async {
    try {
      final db = await _databaseHelper.database;
      await db.update(
        'medicines',
        event.medicine.toMap(),
        where: 'id = ?',
        whereArgs: [event.medicine.id],
      );
      emit(MedicineUpdateSuccess());
    } catch (e) {
      emit(MedicineUpdateFailure(e.toString()));
    }
  }

  Future<void> _onDeleteMedicine(DeleteMedicine event, Emitter<MedicineState> emit) async {
    try {
      final db = await _databaseHelper.database;
      await db.delete(
        'medicines',
        where: 'id = ?',
        whereArgs: [event.id],
      );
      emit(MedicineDeleteSuccess());
    } catch (e) {
      emit(MedicineDeleteFailure(e.toString()));
    }
  }
}
