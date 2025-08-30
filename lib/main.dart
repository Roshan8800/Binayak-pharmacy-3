import 'package:binayak_pharmacy/blocs/medicine_bloc.dart';
import 'package:binayak_pharmacy/data/database_helper.dart';
import 'package:binayak_pharmacy/presentation/screens/inventory_screen.dart';
import 'package:binayak_pharmacy/reports/blocs/report_bloc.dart';
import 'package:binayak_pharmacy/sales/blocs/sale_bloc.dart';
import 'package:binayak_pharmacy/reports/presentation/screens/daily_sales_report_screen.dart';
import 'package:binayak_pharmacy/sales/presentation/screens/sales_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => MedicineBloc(DatabaseHelper()),
        ),
        BlocProvider(
          create: (context) => SaleBloc(DatabaseHelper()),
        ),
        BlocProvider(
          create: (context) => ReportBloc(DatabaseHelper()),
        ),
      ],
      child: MaterialApp(
        title: 'Binayak Pharmacy',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          textTheme: GoogleFonts.latoTextTheme(
            Theme.of(context).textTheme,
          ),
          useMaterial3: true,
        ),
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    InventoryScreen(),
    SalesScreen(),
    DailySalesReportScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sell),
            label: 'Sales',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
