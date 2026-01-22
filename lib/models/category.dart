import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 1)
class Category extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int colorValue;

  Category({
    required this.id,
    required this.name,
    required this.colorValue,
  });


  @HiveField(3)
  bool isSynced = true;

  @HiveField(4)
  String syncAction = '';

  @HiveField(5)
  DateTime updatedAt = DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'colorValue': colorValue,
      'isSynced': isSynced,
      'syncAction': syncAction,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }


  Map<String, dynamic> toApiJson() {
    return {
      'id': int.tryParse(id) ?? id,
      'name': name,
      'colorValue': colorValue,
    };
  }


  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      colorValue: json['colorValue'] ?? 0,
    )
      ..isSynced = true
      ..syncAction = ''
      ..updatedAt = DateTime.now();
  }
}
