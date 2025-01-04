import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportingScreen extends StatefulWidget {
  const ReportingScreen({Key? key}) : super(key: key);

  @override
  _ReportingScreenState createState() => _ReportingScreenState();
}

class _ReportingScreenState extends State<ReportingScreen> {
  bool isPersonSelected = true; // Toggle between 'Person' and 'Cash Flow'
  String? _selectedServiceType;
  String? _selectedDate;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Filter controllers
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _serviceTypeController = TextEditingController();

  // Service types for filtering
  final List<String> _serviceTypes = [
    'Haircut', 'Facial', 'Massage', 'Manicure', 'Pedicure', 'Hair Coloring', 'Other'
  ];

  @override
  void initState() {
    super.initState();
    _dateController.text = DateTime.now().toLocal().toString().split(' ')[0]; // Default to today's date
  }

  // Function to fetch Persons data
  Stream<QuerySnapshot> _getPersonsData() {
    return _firestore.collection('persons').snapshots();
  }

  // Function to fetch Cash Flow data (Cash In and Cash Out)
  Stream<QuerySnapshot> _getCashFlowData() {
    Query query = _firestore.collectionGroup('cash_in');
    // Apply Date filter
    if (_selectedDate != null && _selectedDate!.isNotEmpty) {
      query = query.where('date', isEqualTo: _selectedDate);
    }
    // Apply Service Type filter
    if (_selectedServiceType != null && _selectedServiceType!.isNotEmpty) {
      query = query.where('serviceType', isEqualTo: _selectedServiceType);
    }
    return query.snapshots();
  }

  // Function to fetch Cash Out data
  Stream<QuerySnapshot> _getCashOutData() {
    Query query = _firestore.collection('cash_out');
    // Apply Date filter
    if (_selectedDate != null && _selectedDate!.isNotEmpty) {
      query = query.where('date', isEqualTo: _selectedDate);
    }
    return query.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporting Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toggle between Person and Cash Flow
            ToggleButtons(
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text('Person'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text('Cash Flow'),
                ),
              ],
              isSelected: [isPersonSelected, !isPersonSelected],
              onPressed: (index) {
                setState(() {
                  isPersonSelected = index == 0;
                });
              },
            ),
            const SizedBox(height: 20),

            // Filters for Cash Flow (Date & Service Type)
            if (!isPersonSelected) ...[
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: 'Date'),
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _dateController.text = pickedDate.toLocal().toString().split(' ')[0];
                      _selectedDate = _dateController.text;
                    });
                  }
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Service Type'),
                value: _selectedServiceType,
                items: _serviceTypes.map((String serviceType) {
                  return DropdownMenuItem<String>(
                    value: serviceType,
                    child: Text(serviceType),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedServiceType = newValue;
                  });
                },
              ),
              const SizedBox(height: 20),
            ],

            // Display the data based on selection
            Expanded(
              child: isPersonSelected
                  ? _buildPersonList() // Person data display
                  : _buildCashFlowList(), // Cash Flow data display
            ),
          ],
        ),
      ),
    );
  }

  // Function to build Person list
  Widget _buildPersonList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getPersonsData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No persons found.'));
        }
        final persons = snapshot.data!.docs;
        return ListView.builder(
          itemCount: persons.length,
          itemBuilder: (context, index) {
            final person = persons[index];
            return ListTile(
              title: Text(person['name']),
              subtitle: Text('${person['address']}, ${person['contact']}'),
            );
          },
        );
      },
    );
  }

  // Function to build Cash Flow list
  Widget _buildCashFlowList() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: const [
              Tab(text: 'Cash In'),
              Tab(text: 'Cash Out'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Cash In
                StreamBuilder<QuerySnapshot>(
                  stream: _getCashFlowData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No cash in records.'));
                    }
                    final cashIn = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: cashIn.length,
                      itemBuilder: (context, index) {
                        final transaction = cashIn[index];
                        return ListTile(
                          title: Text('Amount: ${transaction['amount']}'),
                          subtitle: Text('Service: ${transaction['serviceType']}, Date: ${transaction['date']}'),
                        );
                      },
                    );
                  },
                ),
                // Cash Out
                StreamBuilder<QuerySnapshot>(
                  stream: _getCashOutData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No cash out records.'));
                    }
                    final cashOut = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: cashOut.length,
                      itemBuilder: (context, index) {
                        final transaction = cashOut[index];
                        return ListTile(
                          title: Text('Amount: ${transaction['amount']}'),
                          subtitle: Text('Category: ${transaction['expenseCategory']}, Date: ${transaction['date']}'),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
