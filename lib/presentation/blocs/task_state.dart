import '../../domain/entities/task.dart';

abstract class TaskState {}

// Trạng thái ban đầu (chưa làm gì cả)
class TaskInitial extends TaskState {}

// Trạng thái đang tải dữ liệu (để UI hiện vòng xoay)
class TaskLoading extends TaskState {}

// Trạng thái đã tải xong (chứa danh sách Task để UI vẽ 3 cột)
class TaskLoaded extends TaskState {
  final List<Task> tasks;
  TaskLoaded(this.tasks);
}

// Trạng thái lỗi (để UI hiện dòng chữ đỏ báo lỗi)
class TaskError extends TaskState {
  final String message;
  TaskError(this.message);
}
