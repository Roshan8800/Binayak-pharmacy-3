import 'package:equatable/equatable.dart';
import 'package:binayak_pharmacy/sales/data/models/sale_model.dart';

abstract class SaleEvent extends Equatable {
  const SaleEvent();

  @override
  List<Object> get props => [];
}

class AddSale extends SaleEvent {
  final Sale sale;

  const AddSale(this.sale);

  @override
  List<Object> get props => [sale];
}

class LoadSales extends SaleEvent {}
