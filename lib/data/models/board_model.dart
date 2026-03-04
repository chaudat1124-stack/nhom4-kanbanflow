import '../../domain/entities/board.dart';

class BoardModel extends Board {
  const BoardModel({
    required String id,
    required String title,
    required String createdAt,
  }) : super(id: id, title: title, createdAt: createdAt);

  factory BoardModel.fromMap(Map<String, dynamic> map) {
    return BoardModel(
      id: map['id'] as String,
      title: map['title'] as String,
      createdAt: map['createdAt'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title, 'createdAt': createdAt};
  }
}
