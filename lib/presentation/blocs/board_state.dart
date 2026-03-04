import '../../domain/entities/board.dart';

abstract class BoardState {}

class BoardInitial extends BoardState {}

class BoardLoading extends BoardState {}

class BoardLoaded extends BoardState {
  final List<Board> boards;
  BoardLoaded(this.boards);
}

class BoardError extends BoardState {
  final String message;
  BoardError(this.message);
}
