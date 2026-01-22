// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CategoryAdapter extends TypeAdapter<Category> {
  @override
  final int typeId = 1;

  @override
  Category read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    // Backwards-compatible reading: older Hive boxes may not contain the
    // sync metadata fields. Use sensible defaults when missing.
    final id = fields[0] as String;
    final name = fields[1] as String;
    final colorValue = fields[2] as int;
    final isSynced = (fields[3] as bool?) ?? true;
    final syncAction = (fields[4] as String?) ?? '';
    final updatedAt = (fields[5] as DateTime?) ?? DateTime.now();

    return Category(
      id: id,
      name: name,
      colorValue: colorValue,
    )
      ..isSynced = isSynced
      ..syncAction = syncAction
      ..updatedAt = updatedAt;
  }

  @override
  void write(BinaryWriter writer, Category obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.colorValue)
      ..writeByte(3)
      ..write(obj.isSynced)
      ..writeByte(4)
      ..write(obj.syncAction)
      ..writeByte(5)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
