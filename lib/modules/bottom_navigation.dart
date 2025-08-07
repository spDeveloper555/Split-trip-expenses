import 'package:flutter/material.dart';
import 'package:trip_split/modules/settlement_details/settlement_list.dart';
import 'package:trip_split/modules/trip_details/trip_list.dart';
import '../styles.dart';
import 'analytic_charts/expenses_analytic.dart';

class BottomNavScreen extends StatefulWidget {
  final int index;
  BottomNavScreen({required this.index});
  @override
  _BottomNavScreenState createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.index;
  }

  final List<Widget> _screens = [
    TripDetailsPage(),
    ExpensesAnalyticPage(),
    SettlementDetailsPage(),
  ];

  @override
  void dispose() {
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(65), // Set the height you want
        child: AppBar(
          title: Text(
            'Split trip expenses',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.white,
            ),
          ),
          elevation: 0,
          backgroundColor: AppStyles.headerColor,
          centerTitle: false,
        ),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Trip details',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.area_chart),
            label: 'Analytic',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.splitscreen),
            label: 'Settlement',
          ),
        ],
        selectedItemColor: AppStyles.whiteColor,
        backgroundColor: AppStyles.headerColor,
        unselectedItemColor: AppStyles.blueGrey,
      ),
    );
  }
}
