import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:binayak_pharmacy/blocs/medicine_bloc.dart';
import 'package:binayak_pharmacy/blocs/medicine_event.dart';
import 'package:binayak_pharmacy/blocs/medicine_state.dart';
import 'package:binayak_pharmacy/data/models/medicine_model.dart';
import 'package:binayak_pharmacy/sales/blocs/sale_bloc.dart';
import 'package:binayak_pharmacy/sales/blocs/sale_event.dart';
import 'package:binayak_pharmacy/sales/blocs/sale_state.dart';
import 'package:binayak_pharmacy/sales/data/models/sale_model.dart';

class AddSaleScreen extends StatefulWidget {
  const AddSaleScreen({super.key});

  @override
  _AddSaleScreenState createState() => _AddSaleScreenState();
}

class _AddSaleScreenState extends State<AddSaleScreen> {
  final _formKey = GlobalKey<FormState>();
  Medicine? _selectedMedicine;
  final _quantityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Sale'),
      ),
      body: BlocListener<SaleBloc, SaleState>(
        listener: (context, state) {
          if (state is SaleAddSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sale added successfully')),
            );
            context.read<SaleBloc>().add(LoadSales());
            context.read<MedicineBloc>().add(LoadMedicines());
            Navigator.of(context).pop();
          } else if (state is SaleFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to add sale: ${state.message}')),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                BlocBuilder<MedicineBloc, MedicineState>(
                  builder: (context, state) {
                    if (state is MedicineLoaded) {
                      return DropdownButtonFormField<Medicine>(
                        value: _selectedMedicine,
                        items: state.medicines.map((medicine) {
                          return DropdownMenuItem<Medicine>(
                            value: medicine,
                            child: Text(medicine.name),
                          );
                        }).toList(),
                        onChanged: (medicine) {
                          setState(() {
                            _selectedMedicine = medicine;
                          });
                        },
                        decoration: const InputDecoration(labelText: 'Medicine'),
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a medicine';
                          }
                          return null;
                        },
                      );
                    }
                    return const CircularProgressIndicator();
                  },
                ),
                TextFormField(
                  controller: _quantityController,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || int.tryParse(value) == null) {
                      return 'Please enter a valid quantity';
                    }
                    if (int.parse(value) <= 0) {
                      return 'Quantity must be greater than 0';
                    }
                    if (_selectedMedicine != null &&
                        int.parse(value) > _selectedMedicine!.quantity) {
                      return 'Not enough stock';
                    }
                    return null;
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final sale = Sale(
                        medicineId: _selectedMedicine!.id!,
                        quantity: int.parse(_quantityController.text),
                        totalPrice: _selectedMedicine!.price *
                            int.parse(_quantityController.text),
                        date: DateTime.now(),
                      );
                      context.read<SaleBloc>().add(AddSale(sale));
                    }
                  },
                  child: const Text('Add Sale'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
