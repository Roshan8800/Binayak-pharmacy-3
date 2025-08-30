import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:binayak_pharmacy/blocs/medicine_bloc.dart';
import 'package:binayak_pharmacy/blocs/medicine_event.dart';
import 'package:binayak_pharmacy/data/models/medicine_model.dart';
import 'package:intl/intl.dart';

class AddEditMedicineScreen extends StatefulWidget {
  final Medicine? medicine;

  const AddEditMedicineScreen({super.key, this.medicine});

  @override
  _AddEditMedicineScreenState createState() => _AddEditMedicineScreenState();
}

class _AddEditMedicineScreenState extends State<AddEditMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _description;
  late int _quantity;
  late double _price;
  late DateTime _expiryDate;

  @override
  void initState() {
    super.initState();
    _name = widget.medicine?.name ?? '';
    _description = widget.medicine?.description ?? '';
    _quantity = widget.medicine?.quantity ?? 0;
    _price = widget.medicine?.price ?? 0.0;
    _expiryDate = widget.medicine?.expiryDate ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.medicine == null ? 'Add Medicine' : 'Edit Medicine'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Description'),
                onSaved: (value) => _description = value!,
              ),
              TextFormField(
                initialValue: _quantity.toString(),
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || int.tryParse(value) == null) {
                    return 'Please enter a valid quantity';
                  }
                  if (int.parse(value) < 0) {
                    return 'Quantity cannot be negative';
                  }
                  return null;
                },
                onSaved: (value) => _quantity = int.parse(value!),
              ),
              TextFormField(
                initialValue: _price.toString(),
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || double.tryParse(value) == null) {
                    return 'Please enter a valid price';
                  }
                  if (double.parse(value) < 0) {
                    return 'Price cannot be negative';
                  }
                  return null;
                },
                onSaved: (value) => _price = double.parse(value!),
              ),
              FormField<DateTime>(
                builder: (FormFieldState<DateTime> state) {
                  return InkWell(
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _expiryDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null && pickedDate != _expiryDate) {
                        setState(() {
                          _expiryDate = pickedDate;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Expiry Date',
                        errorText: state.errorText,
                      ),
                      child: Text(DateFormat.yMd().format(_expiryDate)),
                    ),
                  );
                },
                validator: (value) {
                  if (_expiryDate.isBefore(DateTime.now())) {
                    return 'Expiry date cannot be in the past';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final medicine = Medicine(
                      id: widget.medicine?.id,
                      name: _name,
                      description: _description,
                      quantity: _quantity,
                      price: _price,
                      expiryDate: _expiryDate,
                    );
                    if (widget.medicine == null) {
                      context.read<MedicineBloc>().add(AddMedicine(medicine));
                    } else {
                      context.read<MedicineBloc>().add(UpdateMedicine(medicine));
                    }
                    Navigator.of(context).pop();
                  }
                },
                child: Text(widget.medicine == null ? 'Add' : 'Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
