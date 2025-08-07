import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:trip_split/modules/trip_details/trip_manage.dart';
import '../../hive_modal/trip/trip.dart';
import '../../styles.dart';
import '../Expenses_details/expenses_list.dart';

class TripDetailsPage extends StatelessWidget {
  final Box<Trip> tripsBox = Hive.box<Trip>('tripsBox');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Trips'),
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

                return Card(
                  elevation: 4,
                  color: Colors.blue[50],
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Trip No: ${index + 1}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.grey),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => TripFormScreen(trip: trip),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.close, color: Colors.red),
                                    onPressed:
                                        () => _confirmDelete(context, trip),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Title: ${trip.title}',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Description: ${trip.description}',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Date: ${DateFormat('yyyy-MM-dd').format(trip.date)}',
                            style: TextStyle(fontSize: 16),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppStyles.whiteColor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TripFormScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Trip trip) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: AppStyles.whiteColor,
            title: Text('Delete Trip'),
            content: Text('Are you sure you want to delete this trip?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: AppStyles.textColor),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  trip.delete();
                  Navigator.pop(ctx);
                },
                child: Text('Delete', style: TextStyle(color: AppStyles.whiteColor),),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],
          ),
    );
  }
}
