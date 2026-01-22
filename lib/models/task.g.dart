// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 0;

  @override
  Task read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    // Backwards compatible reading: older boxes might not have the sync
    // metadata fields. Provide sensible defaults when fields are missing.
    final id = fields[0] as String;
    final title = fields[1] as String;
    final description = fields[2] as String;
    final categoryId = fields[3] as String?;
    final isCompleted = fields[4] as bool;
    final createdAt = fields[5] as DateTime;
    final isSynced = (fields[6] as bool?) ?? true;
    final syncAction = (fields[7] as String?) ?? '';
    final updatedAt = (fields[8] as DateTime?) ?? DateTime.now();

    return Task(
      id: id,
      title: title,
      description: description,
      categoryId: categoryId,
      isCompleted: isCompleted,
      createdAt: createdAt,
      isSynced: isSynced,
      syncAction: syncAction,
      updatedAt: updatedAt,
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.categoryId)
      ..writeByte(4)
      ..write(obj.isCompleted)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.isSynced)
      ..writeByte(7)
      ..write(obj.syncAction)
      ..writeByte(8)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
