import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  String? categoryId;

  @HiveField(4)
  bool isCompleted;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  bool isSynced;

  @HiveField(7)
  String syncAction;

  @HiveField(8)
  DateTime updatedAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    this.categoryId,
    this.isCompleted = false,
    required this.createdAt,
    this.isSynced = true,
    this.syncAction = '',
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();


  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'].toString(),
      title: json['todo'] ?? json['title'] ?? '',
      description: json['description'] ?? '',
      categoryId: json['categoryId'],
      isCompleted: json['completed'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      isSynced: json['isSynced'] ?? true,
      syncAction: json['syncAction'] ?? '',
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'todo': title,
      'description': description,
      'categoryId': categoryId,
      'completed': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'isSynced': isSynced,
      'syncAction': syncAction,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }


  Map<String, dynamic> toApiJson() {
    return {
      'title': title,
      'description': description,
      'categoryId': categoryId,
      'completed': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
