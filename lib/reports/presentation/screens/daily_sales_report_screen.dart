import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:binayak_pharmacy/reports/blocs/report_bloc.dart';
import 'package:binayak_pharmacy/reports/blocs/report_event.dart';
import 'package:binayak_pharmacy/reports/blocs/report_state.dart';
import 'package:intl/intl.dart';

class DailySalesReportScreen extends StatefulWidget {
  const DailySalesReportScreen({super.key});

  @override
  _DailySalesReportScreenState createState() => _DailySalesReportScreenState();
}

class _DailySalesReportScreenState extends State<DailySalesReportScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    context.read<ReportBloc>().add(LoadDailySalesReport(_selectedDate));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Sales Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (pickedDate != null && pickedDate != _selectedDate) {
                setState(() {
                  _selectedDate = pickedDate;
                  context.read<ReportBloc>().add(LoadDailySalesReport(_selectedDate));
                });
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<ReportBloc, ReportState>(
        builder: (context, state) {
          if (state is ReportLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ReportError) {
            return Center(child: Text(state.message));
          }
          if (state is ReportLoaded) {
            if (state.sales.isEmpty) {
              return const Center(child: Text('No sales for this day.'));
            }
            final totalSales = state.sales.fold<double>(0, (sum, sale) => sum + sale.totalPrice);
            final totalMedicinesSold = state.sales.fold<int>(0, (sum, sale) => sum + sale.quantity);

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Report for: ${DateFormat.yMd().format(_selectedDate)}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Text('Total Sales: \$${totalSales.toStringAsFixed(2)}'),
                      Text('Total Medicines Sold: $totalMedicinesSold'),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.sales.length,
                    itemBuilder: (context, index) {
                      final sale = state.sales[index];
                      return ListTile(
                        title: Text('Sale ID: ${sale.id}'),
                        subtitle: Text('Medicine ID: ${sale.medicineId}'),
                        trailing: Text('Quantity: ${sale.quantity}'),
                      );
                    },
                  ),
                ),
              ],
            );
          }
          return Container();
        },
      ),
    );
  }
}
