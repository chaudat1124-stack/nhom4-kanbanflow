import '../../domain/entities/task.dart';

class TaskModel extends Task {
  const TaskModel({
    required String id,
    required String boardId,
    required String title,
    required String description,
    required String status,
  }) : super(
         id: id,
         boardId: boardId,
         title: title,
         description: description,
         status: status,
       );

  // Chuyển từ SQLite (Map) sang Model
  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as String,
      boardId: map['boardId'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      status: map['status'] as String,
    );
  }

  // Chuyển từ Model sang SQLite (Map) để lưu trữ
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'boardId': boardId,
      'title': title,
      'description': description,
      'status': status,
    };
  }
}
