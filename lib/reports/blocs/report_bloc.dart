import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:binayak_pharmacy/reports/blocs/report_event.dart';
import 'package:binayak_pharmacy/reports/blocs/report_state.dart';
import 'package:binayak_pharmacy/data/database_helper.dart';
import 'package:binayak_pharmacy/sales/data/models/sale_model.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final DatabaseHelper _databaseHelper;

  ReportBloc(this._databaseHelper) : super(ReportInitial()) {
    on<LoadDailySalesReport>(_onLoadDailySalesReport);
  }

  Future<void> _onLoadDailySalesReport(
      LoadDailySalesReport event, Emitter<ReportState> emit) async {
    emit(ReportLoading());
    try {
      final sales = await _databaseHelper.getSalesForDay(event.date);
      emit(ReportLoaded(sales: sales.map((map) => Sale.fromMap(map)).toList()));
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }
}
