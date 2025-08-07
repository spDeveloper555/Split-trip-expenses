import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:trip_split/styles.dart';
import '../../hive_modal/trip/trip.dart';
import '../Expenses_details/expenses_list.dart';

class SettlementDetailsPage extends StatelessWidget {
  final Box<Trip> tripsBox = Hive.box<Trip>('tripsBox');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trips Settlement'),
        backgroundColor: AppStyles.whiteColor,
      ),
      body: Container(
        color: AppStyles.whiteColor, // or any color like Color(0xFF25334A)
        child: ValueListenableBuilder<Box<Trip>>(
          valueListenable: tripsBox.listenable(),
          builder: (context, box, _) {
            final trips = box.values.toList();
            if (trips.isEmpty) {
              return Center(child: Text('No trips added yet.'));
            }

            return ListView.builder(
              itemCount: trips.length,
              itemBuilder: (context, index) {
                final trip = trips[index];
                List<String> members = trip.members ?? [];
                List<dynamic> transactions =
                    trip.expenses ?? []; // Ensure type is Expense

                if (transactions.isEmpty) return const SizedBox();

                double totalAmount = 0;
                for (var tx in transactions) {
                  totalAmount += (tx.amount).toInt(); // Use dot notation
                }

                double splitedAmount = totalAmount / members.length;

                Map<String, int> paidAmounts = {};
                for (var name in members) {
                  paidAmounts[name] = transactions
                      .where((tx) => tx.byName == name)
                      .fold(
                        0,
                        (sum, tx) => (sum + tx.amount).toInt(),
                      ); // Use dot notation
                }
                return Card(
                  elevation: 4,
                  color: AppStyles.blue_50,
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => ExpensesListPage(
                                trip: trip,
                                tripIndex: index,
                                tagOptions: trip.members ?? [],
                              ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Row
                          Text(
                            'Title: ${trip.title}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Total expenses: ₹ ${totalAmount}',
                            style: TextStyle(fontSize: 16),
                          ),
                          Center(
                            child: DataTable(
                              columns: const [
                                DataColumn(
                                  label: Text(
                                    'Name',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Paid',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ), // Paid icon
                                ),
                                DataColumn(
                                  label: Icon(
                                    Icons.call_received,
                                    size: 20,
                                    semanticLabel: 'Credit',
                                  ),
                                ),
                                DataColumn(
                                  label: Icon(
                                    Icons.call_made,
                                    size: 20,
                                    semanticLabel: 'Debit',
                                  ), // Debit icon
                                ),
                              ],
                              rows:
                                  members.map((name) {
                                    int paid = paidAmounts[name] ?? 0;
                                    double credit = splitedAmount;
                                    double creditPerPerson = paid - credit;
                                    if (creditPerPerson < 0)
                                      creditPerPerson = 0;
                                    double remaining = credit - paid;
                                    if (remaining < 0) remaining = 0;

                                    return DataRow(
                                      cells: [
                                        DataCell(Text(name)),
                                        DataCell(Text(paid.toString())),
                                        DataCell(
                                          Text(
                                            creditPerPerson.toStringAsFixed(0),
                                          ),
                                        ),
                                        DataCell(
                                          Text(remaining.toStringAsFixed(0)),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
