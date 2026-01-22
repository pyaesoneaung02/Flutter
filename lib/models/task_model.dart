class TaskModel {
  final int? id;
  final String title;
  final String? description;
  final String? dueDate;
  final String? category;
  final bool isCompleted;
  final DateTime createdAt;

  TaskModel({
    this.id,
    required this.title,
    this.description,
    this.dueDate,
    this.category,
    this.isCompleted = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'due_date': dueDate,
      'category': category,
      'is_completed': isCompleted ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      dueDate: map['due_date'],
      category: map['category'],
      isCompleted: map['is_completed'] == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }
}
