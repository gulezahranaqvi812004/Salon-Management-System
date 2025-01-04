import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CashFlowScreen extends StatefulWidget {
  const CashFlowScreen({Key? key}) : super(key: key);

  @override
  _CashFlowScreenState createState() => _CashFlowScreenState();
}

class _CashFlowScreenState extends State<CashFlowScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _employeeController = TextEditingController();
  final _serviceTypeController = TextEditingController();
  final _dateController = TextEditingController();
  String? _selectedCategory; // Store selected category for Cash Out
  bool isCashIn = true; // Toggle between Cash In (Income) and Cash Out (Expense)

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // List of service types for cash in (Salon Services)
  final List<String> _serviceTypes = [
    'Haircut',
    'Facial',
    'Massage',
    'Manicure',
    'Pedicure',
    'Hair Coloring',
    'Other'
  ];

  // List of categories for cash out (Salary, Expenses, etc.)
  final List<String> _expenseCategories = [
    'Salary',
    'Miscellaneous',
    'Supplies',
    'Rent',
    'Utilities',
    'Staff Payment',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    // Set the current date to the date controller
    _dateController.text = DateTime.now().toLocal().toString().split(' ')[0];
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Determine the type of transaction (Cash In or Cash Out)
        if (isCashIn) {
          // Add Cash In (Income) transaction
          await _firestore.collection('cash_in').add({
            'amount': double.parse(_amountController.text),
            'serviceType': _serviceTypeController.text,
            'date': _dateController.text,
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cash In transaction added successfully!')),
          );
        } else {
          // Add Cash Out (Expense) transaction
          await _firestore.collection('cash_out').add({
            'amount': double.parse(_amountController.text),
            'employee': _employeeController.text,
            'expenseCategory': _selectedCategory,
            'date': _dateController.text,
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cash Out transaction added successfully!')),
          );
        }

        // Clear the form
        _amountController.clear();
        _employeeController.clear();
        _serviceTypeController.clear();
        setState(() {
          _selectedCategory = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cash Flow Management'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toggle between Cash In and Cash Out
            ToggleButtons(
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text('Cash In'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text('Cash Out'),
                ),
              ],
              isSelected: [isCashIn, !isCashIn],
              onPressed: (index) {
                setState(() {
                  isCashIn = index == 0;
                });
              },
            ),
            const SizedBox(height: 20),

            // Form to capture Cash In / Cash Out data
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Amount Field
                  TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(labelText: 'Amount'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the amount';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),

                  // If Cash In (Income), show Service Type dropdown
                  if (isCashIn) ...[
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Service Type'),
                      value: _serviceTypeController.text.isNotEmpty
                          ? _serviceTypeController.text
                          : null,
                      items: _serviceTypes.map((String serviceType) {
                        return DropdownMenuItem<String>(
                          value: serviceType,
                          child: Text(serviceType),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _serviceTypeController.text = newValue!;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a service type';
                        }
                        return null;
                      },
                    ),
                  ],

                  // If Cash Out (Expense), show Employee and Expense Category fields
                  if (!isCashIn) ...[
                    TextFormField(
                      controller: _employeeController,
                      decoration: const InputDecoration(labelText: 'Employee/Recipient Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the employee or recipient name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Expense Category'),
                      value: _selectedCategory,
                      items: _expenseCategories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCategory = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select an expense category';
                        }
                        return null;
                      },
                    ),
                  ],

                  const SizedBox(height: 10),

                  // Date Field (Read-only)
                  TextFormField(
                    controller: _dateController,
                    decoration: const InputDecoration(labelText: 'Date'),
                    enabled: false, // Make it read-only since it's auto-filled
                  ),
                  const SizedBox(height: 20),

                  // Submit Button
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
