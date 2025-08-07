import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../hive_modal/trip/trip.dart';
import '../../styles.dart';

class ExpensesAnalyticPage extends StatefulWidget {
  @override
  _ExpensesAnalyticPageState createState() => _ExpensesAnalyticPageState();
}

class _ExpensesAnalyticPageState extends State<ExpensesAnalyticPage> {
  late Box<Trip> tripsBox;

  @override
  void initState() {
    super.initState();
    tripsBox = Hive.box<Trip>('tripsBox');
  }

  @override
  Widget build(BuildContext context) {
    final List<Trip> allTrips = tripsBox.values.toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Expense Analytics'),
        backgroundColor: AppStyles.whiteColor,
      ),
      body: Container(
        color: AppStyles.whiteColor, // or any color like Color(0xFF25334A)
        child:
            allTrips.isEmpty
                ? const Center(child: Text('No trip data available'))
                : ListView.builder(
                  itemCount: allTrips.length,
                  itemBuilder: (context, index) {
                    final trip = allTrips[index];
                    final List<dynamic> tripExpenses = trip.expenses ?? [];
                    if (tripExpenses.isEmpty)
                      return const SizedBox(); // Skip if no expenses

                    Map<String, double> totals = {};
                    for (var member in trip.members ?? []) {
                      totals.update(
                        member,
                        (value) => value,
                        ifAbsent: () => 0,
                      );
                    }
                    for (var expense in tripExpenses) {
                      totals.update(
                        expense.byName,
                        (value) => value + expense.amount,
                        ifAbsent: () => expense.amount,
                      );
                    }

                    List<GrowthData> chartData =
                        totals.entries
                            .map((entry) => GrowthData(entry.key, entry.value))
                            .toList();
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      elevation: 4,
                      color: AppStyles.blue_50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            Text(
                              trip.title ?? 'Untitled Trip',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SfCircularChart(
                              series: <RadialBarSeries<GrowthData, String>>[
                                RadialBarSeries<GrowthData, String>(
                                  dataSource: chartData,
                                  radius: '100%',
                                  innerRadius: '20%',
                                  gap: '5%',
                                  trackOpacity: 0.1,
                                  useSeriesColor: true,
                                  cornerStyle: CornerStyle.bothCurve,
                                  xValueMapper:
                                      (GrowthData data, _) => data.name,
                                  yValueMapper:
                                      (GrowthData data, _) => data.amount,
                                  dataLabelSettings: const DataLabelSettings(
                                    isVisible: true,
                                    labelAlignment: ChartDataLabelAlignment.top,
                                    useSeriesColor: false,
                                    textStyle: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  dataLabelMapper:
                                      (GrowthData data, _) =>
                                          '${data.name} - ${data.amount}',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}

class GrowthData {
  final String name;
  final double amount;
  GrowthData(this.name, this.amount);
}
