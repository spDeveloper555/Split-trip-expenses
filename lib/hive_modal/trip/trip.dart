import 'package:hive/hive.dart';
import '../expenses/expenses.dart';
part 'trip.g.dart';

@HiveType(typeId: 0)
class Trip extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  String description;

  @HiveField(3)
  List<String>? members;

  @HiveField(4)
  HiveList<Expenses>? expenses;

  Trip({
    required this.title,
    required this.description,
    required this.date,
    required this.members,
    this.expenses,
  });

  Trip copyWith({HiveList<Expenses>? expenses}) {
    return Trip(
      title: this.title,
      description: this.description,
      date: this.date,
      members: this.members,
      expenses: this.expenses,
    );
  }
}
