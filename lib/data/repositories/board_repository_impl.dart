import '../../domain/entities/board.dart';
import '../../domain/repositories/board_repository.dart';
import '../datasources/local_database.dart';
import '../models/board_model.dart';

class BoardRepositoryImpl implements BoardRepository {
  final LocalDatabase localDatabase;

  BoardRepositoryImpl({required this.localDatabase});

  @override
  Future<List<Board>> getBoards() async {
    return await localDatabase.getBoards();
  }

  @override
  Future<void> addBoard(Board board) async {
    final boardModel = BoardModel(
      id: board.id,
      title: board.title,
      createdAt: board.createdAt,
    );
    await localDatabase.insertBoard(boardModel);
  }

  @override
  Future<void> updateBoard(Board board) async {
    final boardModel = BoardModel(
      id: board.id,
      title: board.title,
      createdAt: board.createdAt,
    );
    await localDatabase.updateBoard(boardModel);
  }

  @override
  Future<void> deleteBoard(String id) async {
    await localDatabase.deleteBoard(id);
  }
}
