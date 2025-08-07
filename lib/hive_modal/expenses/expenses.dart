import 'package:hive/hive.dart';

part 'expenses.g.dart';

@HiveType(typeId: 1)
class Expenses extends HiveObject {
  @HiveField(0)
  String label;

  @HiveField(1)
  String byName;

  @HiveField(2)
  double amount;

  @HiveField(3)
  DateTime currentTime;

  Expenses({
    required this.label,
    required this.byName,
    required this.amount,
    required this.currentTime,
  });
}
