import '../entities/task.dart';
import '../repositories/task_repository.dart';

// Usecase: Lấy danh sách công việc
class GetTasks {
  final TaskRepository repository;
  GetTasks(this.repository);

  Future<List<Task>> call({
    String? boardId,
    String? query,
    String? status,
  }) async {
    return await repository.getTasks(
      boardId: boardId,
      query: query,
      status: status,
    );
  }
}

// Usecase: Thêm công việc mới
class AddTask {
  final TaskRepository repository;
  AddTask(this.repository);

  Future<void> call(Task task) async {
    return await repository.addTask(task);
  }
}

// Usecase: Cập nhật công việc
class UpdateTask {
  final TaskRepository repository;
  UpdateTask(this.repository);

  Future<void> call(Task task) async {
    return await repository.updateTask(task);
  }
}

// Usecase: Xóa công việc
class DeleteTask {
  final TaskRepository repository;
  DeleteTask(this.repository);

  Future<void> call(String id) async {
    return await repository.deleteTask(id);
  }
}
