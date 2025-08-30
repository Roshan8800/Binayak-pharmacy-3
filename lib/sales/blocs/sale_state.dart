import 'package:equatable/equatable.dart';
import 'package:binayak_pharmacy/sales/data/models/sale_model.dart';

abstract class SaleState extends Equatable {
  const SaleState();

  @override
  List<Object> get props => [];
}

class SaleInitial extends SaleState {}

class SaleInProgress extends SaleState {}

class SaleSuccess extends SaleState {
  final List<Sale> sales;

  const SaleSuccess({this.sales = const <Sale>[]});

  @override
  List<Object> get props => [sales];
}

class SaleFailure extends SaleState {
  final String message;

  const SaleFailure(this.message);

  @override
  List<Object> get props => [message];
}

class SaleAddSuccess extends SaleState {}
