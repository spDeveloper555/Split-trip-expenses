import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../../hive_modal/trip/trip.dart';
import '../../hive_modal/expenses/expenses.dart';
import '../../styles.dart';

class ExpensesListPage extends StatefulWidget {
  final Trip trip;
  final int tripIndex;
  final List<String> tagOptions;

  const ExpensesListPage({
    Key? key,
    required this.trip,
    required this.tripIndex,
    required this.tagOptions,
  }) : super(key: key);

  @override
  _ExpensesListPageState createState() => _ExpensesListPageState();
}

class _ExpensesListPageState extends State<ExpensesListPage> {
  late Box<Trip> tripsBox;
  late Box<Expenses> expensesBox;
  late Trip _currentTrip;
  List<Expenses> _expenses = [];

  @override
  void initState() {
    super.initState();
    tripsBox = Hive.box<Trip>('tripsBox');
    expensesBox = Hive.box<Expenses>('expenses');
    _loadTrip();
  }

  void _loadTrip() {
    _currentTrip = tripsBox.getAt(widget.tripIndex) ?? widget.trip;
    _expenses = _currentTrip.expenses?.toList() ?? [];
    setState(() {});
  }

  void _showExpenseDialog({Expenses? expense, int? index}) {
    final labelController = TextEditingController(text: expense?.label ?? '');
    final amountController = TextEditingController(
      text: expense?.amount.toString() ?? '',
    );
    String? selectedByName =
        expense?.byName ??
        (widget.tagOptions.isNotEmpty ? widget.tagOptions.first : null);

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: AppStyles.whiteColor,
            title: Text(expense == null ? 'Add Expense' : 'Edit Expense'),
            content: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: labelController,
                      decoration: InputDecoration(
                        labelText: 'Label',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: selectedByName,
                      dropdownColor: AppStyles.whiteColor,
                      items:
                          widget.tagOptions.map((name) {
                            return DropdownMenuItem(
                              value: name,
                              child: Text(name),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedByName = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Paid by',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: amountController,
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: AppStyles.headerColor),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final label = labelController.text.trim();
                  final amount = double.tryParse(amountController.text) ?? 0.0;

                  final Trip currentTrip = tripsBox.getAt(widget.tripIndex)!;
                  HiveList<Expenses> updatedExpenses =
                      currentTrip.expenses ?? HiveList(expensesBox);

                  if (expense == null) {
                    final newExpense = Expenses(
                      label: label,
                      byName: selectedByName ?? '',
                      amount: amount,
                      currentTime: DateTime.now(),
                    );
                    await expensesBox.add(newExpense);
                    updatedExpenses.add(newExpense);
                  } else {
                    expense.label = label;
                    expense.amount = amount;
                    expense.byName = selectedByName ?? '';
                    expense.currentTime = DateTime.now();
                    await expense.save();
                  }

                  currentTrip.expenses = updatedExpenses;
                  await currentTrip.save();
                  _loadTrip();
                  Navigator.pop(context);

                },
                style: AppStyles.buttonStyle,
                child: Text(expense == null ? 'Add' : 'Update'),
              ),
            ],
          ),
    );
  }

  void _deleteExpense(int index) async {
    final Trip currentTrip = tripsBox.getAt(widget.tripIndex)!;

    final HiveList<Expenses> updatedExpenses =
    HiveList<Expenses>(expensesBox)..addAll(currentTrip.expenses ?? []);

    final expenseToDelete = updatedExpenses[index];

    updatedExpenses.removeAt(index);
    currentTrip.expenses = updatedExpenses;

    await currentTrip.save();

    await expenseToDelete.delete();

    _loadTrip();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_currentTrip.title} Expenses'),
        backgroundColor: AppStyles.whiteColor,
      ),
      body: Container(
        color: AppStyles.whiteColor, // or any color like Color(0xFF25334A)
        child:
            _expenses.isEmpty
                ? Center(child: Text('No expenses yet.'))
                : ListView.builder(
                  itemCount: _expenses.length,
                  itemBuilder: (_, index) {
                    final expense = _expenses[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      elevation: 4,
                      color: AppStyles.blue_50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        title: Text(
                          expense.label,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('By: ${expense.byName}'),
                            Text('₹ ${expense.amount.toStringAsFixed(2)}'),
                            Text(
                              'Time: ${DateFormat('yyyy-MM-dd – kk:mm').format(expense.currentTime)}',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed:
                                  () => _showExpenseDialog(
                                    expense: expense,
                                    index: index,
                                  ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteExpense(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppStyles.whiteColor,
        onPressed: () => _showExpenseDialog(),
        child: Icon(Icons.add),
      ),
    );
  }
}
