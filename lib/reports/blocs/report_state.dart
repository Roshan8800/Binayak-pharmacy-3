import 'package:equatable/equatable.dart';
import 'package:binayak_pharmacy/sales/data/models/sale_model.dart';

abstract class ReportState extends Equatable {
  const ReportState();

  @override
  List<Object> get props => [];
}

class ReportInitial extends ReportState {}

class ReportLoading extends ReportState {}

class ReportLoaded extends ReportState {
  final List<Sale> sales;

  const ReportLoaded({this.sales = const <Sale>[]});

  @override
  List<Object> get props => [sales];
}

class ReportError extends ReportState {
  final String message;

  const ReportError(this.message);

  @override
  List<Object> get props => [message];
}
