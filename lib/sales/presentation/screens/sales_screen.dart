import 'package:binayak_pharmacy/blocs/medicine_bloc.dart';
import 'package:binayak_pharmacy/sales/blocs/sale_bloc.dart';
import 'package:binayak_pharmacy/sales/blocs/sale_event.dart';
import 'package:binayak_pharmacy/sales/blocs/sale_state.dart';
import 'package:binayak_pharmacy/sales/presentation/screens/add_sale_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SaleBloc>().add(LoadSales());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales'),
      ),
      body: BlocListener<SaleBloc, SaleState>(
        listener: (context, state) {
          if (state is SaleSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sale added successfully')),
            );
          } else if (state is SaleFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: BlocBuilder<SaleBloc, SaleState>(
          builder: (context, state) {
            if (state is SaleInProgress) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is SaleFailure) {
              return Center(child: Text(state.message));
            }
            if (state is SaleSuccess) {
              if (state.sales.isEmpty) {
                return const Center(child: Text('No sales found.'));
              }
              return ListView.builder(
                itemCount: state.sales.length,
                itemBuilder: (context, index) {
                  final sale = state.sales[index];
                  return ListTile(
                    title: Text('Sale ID: ${sale.id}'),
                    subtitle: Text('Medicine ID: ${sale.medicineId}'),
                    trailing: Text('Quantity: ${sale.quantity}'),
                  );
                },
              );
            }
            return Container();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MultiBlocProvider(
                providers: [
                  BlocProvider.value(
                    value: BlocProvider.of<MedicineBloc>(context),
                  ),
                  BlocProvider.value(
                    value: BlocProvider.of<SaleBloc>(context),
                  ),
                ],
                child: const AddSaleScreen(),
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
