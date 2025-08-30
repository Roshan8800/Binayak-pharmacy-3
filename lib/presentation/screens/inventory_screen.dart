import 'package:binayak_pharmacy/presentation/screens/add_edit_medicine_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:binayak_pharmacy/blocs/medicine_bloc.dart';
import 'package:binayak_pharmacy/blocs/medicine_event.dart';
import 'package:binayak_pharmacy/blocs/medicine_state.dart';
import 'package:binayak_pharmacy/data/models/medicine_model.dart';

enum FilterOptions { all, lowStock, expiringSoon }

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  FilterOptions _selectedFilter = FilterOptions.all;

  @override
  void initState() {
    super.initState();
    context.read<MedicineBloc>().add(LoadMedicines());
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        actions: [
          PopupMenuButton<FilterOptions>(
            onSelected: (FilterOptions result) {
              setState(() {
                _selectedFilter = result;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<FilterOptions>>[
              const PopupMenuItem<FilterOptions>(
                value: FilterOptions.all,
                child: Text('All'),
              ),
              const PopupMenuItem<FilterOptions>(
                value: FilterOptions.lowStock,
                child: Text('Low Stock'),
              ),
              const PopupMenuItem<FilterOptions>(
                value: FilterOptions.expiringSoon,
                child: Text('Expiring Soon'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: BlocListener<MedicineBloc, MedicineState>(
              listener: (context, state) {
                if (state is MedicineAddSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Medicine added successfully')),
                  );
                } else if (state is MedicineUpdateSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Medicine updated successfully')),
                  );
                } else if (state is MedicineDeleteSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Medicine deleted successfully')),
                  );
                } else if (state is MedicineAddFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                } else if (state is MedicineUpdateFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                } else if (state is MedicineDeleteFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
              },
              child: BlocBuilder<MedicineBloc, MedicineState>(
                builder: (context, state) {
                  if (state is MedicineLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is MedicineLoaded) {
                    final medicines = state.medicines
                        .where((medicine) {
                          final nameMatches = medicine.name
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase());
                          if (_selectedFilter == FilterOptions.lowStock) {
                            return nameMatches && medicine.quantity <= 10;
                          }
                          if (_selectedFilter == FilterOptions.expiringSoon) {
                            return nameMatches &&
                                medicine.expiryDate.isBefore(
                                    DateTime.now().add(const Duration(days: 30)));
                          }
                          return nameMatches;
                        })
                        .toList();

                    if (medicines.isEmpty) {
                      return const Center(
                        child: Text('No medicines found.'),
                      );
                    }
                    return ListView.builder(
                      itemCount: medicines.length,
                      itemBuilder: (context, index) {
                        final medicine = medicines[index];
                        final isLowStock = medicine.quantity <= 10;
                        final isExpiringSoon = medicine.expiryDate
                            .isBefore(DateTime.now().add(const Duration(days: 30)));

                        return ListTile(
                          title: Text(medicine.name),
                          subtitle: Text('Quantity: ${medicine.quantity}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isLowStock)
                                const Icon(Icons.warning, color: Colors.orange),
                              if (isExpiringSoon)
                                const Icon(Icons.timer_off, color: Colors.red),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => BlocProvider.value(
                                        value: BlocProvider.of<MedicineBloc>(context),
                                        child: AddEditMedicineScreen(medicine: medicine),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  final bloc = BlocProvider.of<MedicineBloc>(context);
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Delete Medicine'),
                                        content: const Text(
                                            'Are you sure you want to delete this medicine?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              bloc.add(DeleteMedicine(medicine.id!));
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                  if (state is MedicineError) {
                    return Center(child: Text(state.message));
                  }
                  return Container();
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: BlocProvider.of<MedicineBloc>(context),
                child: const AddEditMedicineScreen(),
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
