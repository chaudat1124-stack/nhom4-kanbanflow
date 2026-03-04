import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/task_bloc.dart';
import '../blocs/task_event.dart';
import '../blocs/task_state.dart';
import '../blocs/board_bloc.dart';
import '../blocs/board_event.dart';
import '../blocs/board_state.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/board.dart';

class BoardScreen extends StatefulWidget {
  const BoardScreen({super.key});

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  String? selectedBoardId;
  bool isSearching = false;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (selectedBoardId != null) {
      context.read<TaskBloc>().add(
        LoadTasks(boardId: selectedBoardId, query: searchController.text),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isSearching
            ? TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  hintText: 'Tìm kiếm công việc...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                autofocus: true,
              )
            : const Text('KanbanFlow - Nhóm 4'),
        centerTitle: !isSearching,
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (isSearching) {
                  isSearching = false;
                  searchController.clear();
                } else {
                  isSearching = true;
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (selectedBoardId != null) {
                context.read<TaskBloc>().add(
                  LoadTasks(
                    boardId: selectedBoardId,
                    query: searchController.text,
                  ),
                );
              }
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: selectedBoardId == null
          ? const Center(
              child: Text('Vui lòng chọn hoặc tạo Board từ Menu bên trái'),
            )
          : _buildBoardContent(context),
      floatingActionButton: selectedBoardId == null
          ? null
          : FloatingActionButton(
              onPressed: () => _showAddTaskDialog(context),
              child: const Icon(Icons.add),
            ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Center(
              child: Text(
                'Danh sách Boards',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
          ),
          Expanded(
            child: BlocConsumer<BoardBloc, BoardState>(
              listener: (context, state) {
                if (state is BoardLoaded &&
                    selectedBoardId == null &&
                    state.boards.isNotEmpty) {
                  _selectBoard(state.boards.first.id);
                } else if (state is BoardLoaded && state.boards.isEmpty) {
                  setState(() {
                    selectedBoardId = null;
                  });
                }
              },
              builder: (context, state) {
                if (state is BoardLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is BoardLoaded) {
                  final boards = state.boards;
                  if (boards.isEmpty) {
                    return const Center(child: Text('Chưa có Board nào.'));
                  }
                  return ListView.builder(
                    itemCount: boards.length,
                    itemBuilder: (context, index) {
                      final board = boards[index];
                      return ListTile(
                        leading: const Icon(Icons.dashboard),
                        title: Text(board.title),
                        selected: board.id == selectedBoardId,
                        onTap: () {
                          _selectBoard(board.id);
                          Navigator.pop(context); // Close drawer
                        },
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              _showDeleteBoardDialog(context, board),
                        ),
                      );
                    },
                  );
                } else if (state is BoardError) {
                  return Center(child: Text('Lỗi: ${state.message}'));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Thêm Board mới'),
            onTap: () {
              Navigator.pop(context);
              _showAddBoardDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _selectBoard(String id) {
    setState(() {
      selectedBoardId = id;
    });
    context.read<TaskBloc>().add(
      LoadTasks(boardId: id, query: searchController.text),
    );
  }

  Widget _buildBoardContent(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        if (state is TaskLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is TaskLoaded) {
          return Row(
            children: [
              _buildColumn(context, 'To Do', 'todo', state.tasks),
              _buildColumn(context, 'Doing', 'doing', state.tasks),
              _buildColumn(context, 'Done', 'done', state.tasks),
            ],
          );
        } else if (state is TaskError) {
          return Center(child: Text('Lỗi: ${state.message}'));
        }
        return const Center(child: Text('Chưa có dữ liệu'));
      },
    );
  }

  Widget _buildColumn(
    BuildContext context,
    String title,
    String status,
    List<Task> allTasks,
  ) {
    final tasks = allTasks.where((t) => t.status == status).toList();

    return Expanded(
      child: DragTarget<Task>(
        onWillAcceptWithDetails: (details) {
          return details.data.status !=
              status; // Only accept if status is different
        },
        onAcceptWithDetails: (details) {
          final droppedTask = details.data;
          final updatedTask = Task(
            id: droppedTask.id,
            boardId: droppedTask.boardId,
            title: droppedTask.title,
            description: droppedTask.description,
            status: status, // Update to new status
          );
          context.read<TaskBloc>().add(UpdateTaskEvent(updatedTask));
        },
        builder: (context, candidateData, rejectedData) {
          return Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: candidateData.isNotEmpty
                  ? Colors.blue.withOpacity(0.2)
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              border: candidateData.isNotEmpty
                  ? Border.all(color: Colors.blue, width: 2)
                  : null,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '$title (${tasks.length})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Draggable<Task>(
                        data: task,
                        feedback: Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 250,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  task.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  task.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.3,
                          child: _buildTaskCard(task),
                        ),
                        child: _buildTaskCard(task),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      child: ListTile(
        title: Text(
          task.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(task.description),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
          onPressed: () =>
              context.read<TaskBloc>().add(DeleteTaskEvent(task.id)),
        ),
      ),
    );
  }

  void _showAddBoardDialog(BuildContext context) {
    final titleController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm Board mới'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(labelText: 'Tên Board'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isEmpty) return;
              final board = Board(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: titleController.text.trim(),
                createdAt: DateTime.now().toIso8601String(),
              );
              context.read<BoardBloc>().add(AddBoardEvent(board));
              Navigator.pop(context);
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  void _showDeleteBoardDialog(BuildContext context, Board board) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc muốn xóa bảng "${board.title}"?\nTất cả công việc trong bảng này sẽ bị xóa.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<BoardBloc>().add(DeleteBoardEvent(board.id));
              if (selectedBoardId == board.id) {
                setState(() {
                  selectedBoardId = null;
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm công việc mới'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Tiêu đề'),
              autofocus: true,
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Mô tả'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isEmpty ||
                  selectedBoardId == null)
                return;
              final task = Task(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                boardId: selectedBoardId!,
                title: titleController.text.trim(),
                description: descController.text.trim(),
                status: 'todo',
              );
              context.read<TaskBloc>().add(AddTaskEvent(task));
              Navigator.pop(context);
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }
}
