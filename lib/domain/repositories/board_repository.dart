import '../entities/board.dart';

abstract class BoardRepository {
  Future<List<Board>> getBoards();
  Future<void> addBoard(Board board);
  Future<void> updateBoard(Board board);
  Future<void> deleteBoard(String id);
}
