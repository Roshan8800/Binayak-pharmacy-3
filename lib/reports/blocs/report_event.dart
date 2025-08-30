import 'package:equatable/equatable.dart';

abstract class ReportEvent extends Equatable {
  const ReportEvent();

  @override
  List<Object> get props => [];
}

class LoadDailySalesReport extends ReportEvent {
  final DateTime date;

  const LoadDailySalesReport(this.date);

  @override
  List<Object> get props => [date];
}
