import 'package:equatable/equatable.dart';
import 'package:binayak_pharmacy/data/models/medicine_model.dart';

abstract class MedicineState extends Equatable {
  const MedicineState();

  @override
  List<Object> get props => [];
}

class MedicineLoading extends MedicineState {}

class MedicineLoaded extends MedicineState {
  final List<Medicine> medicines;

  const MedicineLoaded({this.medicines = const <Medicine>[]});

  @override
  List<Object> get props => [medicines];
}

class MedicineError extends MedicineState {
  final String message;

  const MedicineError(this.message);

  @override
  List<Object> get props => [message];
}
