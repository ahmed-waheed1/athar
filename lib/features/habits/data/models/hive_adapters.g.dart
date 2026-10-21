// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_adapters.dart';

// **************************************************************************
// AdaptersGenerator
// **************************************************************************

class HabitModelAdapter extends TypeAdapter<HabitModel> {
  @override
  final typeId = 0;

  @override
  HabitModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HabitModel(
      id: fields[0] as String,
      name: fields[1] as String,
      iconKey: fields[2] as String,
      colorKey: fields[3] as String,
      createdAt: fields[4] as DateTime,
      reminderHour: (fields[5] as num?)?.toInt(),
      reminderMinute: (fields[6] as num?)?.toInt(),
      completedDates: fields[7] == null
          ? const []
          : (fields[7] as List).cast<String>(),
      celebratedMilestones: fields[8] == null
          ? const []
          : (fields[8] as List).cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, HabitModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.iconKey)
      ..writeByte(3)
      ..write(obj.colorKey)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.reminderHour)
      ..writeByte(6)
      ..write(obj.reminderMinute)
      ..writeByte(7)
      ..write(obj.completedDates)
      ..writeByte(8)
      ..write(obj.celebratedMilestones);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
