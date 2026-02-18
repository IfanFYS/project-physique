// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyLogAdapter extends TypeAdapter<DailyLog> {
  @override
  final int typeId = 2;

  @override
  DailyLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyLog(
      date: fields[0] as String,
      weight: fields[1] as double?,
      calories: fields[2] as int,
      sleepDuration: fields[3] as int?,
      photoPath: fields[4] as String?,
      calorieEntries: (fields[5] as List?)?.cast<CalorieEntry>(),
      neck: fields[6] as double?,
      waist: fields[7] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, DailyLog obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.weight)
      ..writeByte(2)
      ..write(obj.calories)
      ..writeByte(3)
      ..write(obj.sleepDuration)
      ..writeByte(4)
      ..write(obj.photoPath)
      ..writeByte(5)
      ..write(obj.calorieEntries)
      ..writeByte(6)
      ..write(obj.neck)
      ..writeByte(7)
      ..write(obj.waist);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
