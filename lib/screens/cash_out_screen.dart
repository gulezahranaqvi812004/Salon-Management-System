import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CashOutScreen extends StatefulWidget {
  const CashOutScreen({Key? key}) : super(key: key);

  @override
  _CashOutScreenState createState() => _CashOutScreenState();
}

class _CashOutScreenState extends State<CashOutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _employeeController = TextEditingController();
  final _dateController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
  String? _selectedCategory; // Store the selected expense category

  @override
  void initState() {
    super.initState();
    // Set the current date to the date controller
    _dateController.text = DateTime.now().toLocal().toString().split(' ')[0];
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Add data to Firestore (Cash Out Collection)
        await _firestore.collection('cash_out').add({
          'amount': double.parse(_amountController.text),
          'employee': _employeeController.text,
          'expenseCategory': _selectedCategory,
          'date': _dateController.text,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cash out transaction added successfully!')),
        );
        // Clear the form
        _amountController.clear();
        _employeeController.clear();
        setState(() {
          _selectedCategory = null; // Reset category selection
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
        title: const Text('Add Cash Out (Salary/Expenses)'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
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
              // Employee Name Field
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
              // Dropdown for Expense Category
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
      ),
    );
  }
}
