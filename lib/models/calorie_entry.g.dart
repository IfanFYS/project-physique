// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calorie_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CalorieEntryAdapter extends TypeAdapter<CalorieEntry> {
  @override
  final int typeId = 6;

  @override
  CalorieEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CalorieEntry(
      amount: fields[0] as int,
      timestamp: fields[1] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CalorieEntry obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.amount)
      ..writeByte(1)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalorieEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
