import 'package:flutter/material.dart';
import 'add_person_screen.dart'; // Import Add Person screen
import 'cashflow_screen.dart';
import 'reporting_screen.dart'; // Import Reporting screen

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // List of screens
  final List<Widget> _screens = [
    const AddPersonScreen(),
    const CashFlowScreen(),
    const ReportingScreen(),
  ];

  // Function to change screen based on the selected index
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: _screens[_selectedIndex], // Display selected screen
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: 'Add Person',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Cash Flow',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Reporting',
          ),
        ],
      ),
    );
  }
}
