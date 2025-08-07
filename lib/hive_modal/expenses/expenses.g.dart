// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expenses.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExpensesAdapter extends TypeAdapter<Expenses> {
  @override
  final int typeId = 1;

  @override
  Expenses read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Expenses(
      label: fields[0] as String,
      byName: fields[1] as String,
      amount: fields[2] as double,
      currentTime: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Expenses obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.label)
      ..writeByte(1)
      ..write(obj.byName)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.currentTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpensesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
