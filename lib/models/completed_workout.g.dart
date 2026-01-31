// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'completed_workout.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CompletedWorkoutAdapter extends TypeAdapter<CompletedWorkout> {
  @override
  final int typeId = 4;

  @override
  CompletedWorkout read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CompletedWorkout(
      id: fields[0] as String,
      date: fields[1] as String,
      workoutDayId: fields[2] as String,
      workoutDayName: fields[3] as String,
      exercises: (fields[4] as List).cast<CompletedExercise>(),
      completedAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CompletedWorkout obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.workoutDayId)
      ..writeByte(3)
      ..write(obj.workoutDayName)
      ..writeByte(4)
      ..write(obj.exercises)
      ..writeByte(5)
      ..write(obj.completedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompletedWorkoutAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CompletedExerciseAdapter extends TypeAdapter<CompletedExercise> {
  @override
  final int typeId = 5;

  @override
  CompletedExercise read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CompletedExercise(
      exerciseId: fields[0] as String,
      name: fields[1] as String,
      targetSets: fields[2] as int,
      details: fields[3] as String,
      actualSets: (fields[4] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, CompletedExercise obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.exerciseId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.targetSets)
      ..writeByte(3)
      ..write(obj.details)
      ..writeByte(4)
      ..write(obj.actualSets);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompletedExerciseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
