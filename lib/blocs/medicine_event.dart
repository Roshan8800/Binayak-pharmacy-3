import 'package:equatable/equatable.dart';
import 'package:binayak_pharmacy/data/models/medicine_model.dart';

abstract class MedicineEvent extends Equatable {
  const MedicineEvent();

  @override
  List<Object> get props => [];
}

class LoadMedicines extends MedicineEvent {}

class AddMedicine extends MedicineEvent {
  final Medicine medicine;

  const AddMedicine(this.medicine);

  @override
  List<Object> get props => [medicine];
}

class UpdateMedicine extends MedicineEvent {
  final Medicine medicine;

  const UpdateMedicine(this.medicine);

  @override
  List<Object> get props => [medicine];
}

class DeleteMedicine extends MedicineEvent {
  final int id;

  const DeleteMedicine(this.id);

  @override
  List<Object> get props => [id];
}
