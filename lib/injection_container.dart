import 'package:get_it/get_it.dart';
import 'data/datasources/local_database.dart';
import 'data/repositories/task_repository_impl.dart';
import 'domain/repositories/task_repository.dart';
import 'domain/usecases/task_usecases.dart';
import 'presentation/blocs/task_bloc.dart';

import 'data/repositories/board_repository_impl.dart';
import 'domain/repositories/board_repository.dart';
import 'domain/usecases/board_usecases.dart';
import 'presentation/blocs/board_bloc.dart';
// (Nhớ check lại đường dẫn import file task_bloc của bạn cho chuẩn nhé)

final sl = GetIt.instance; // sl viết tắt của Service Locator

Future<void> init() async {
  // 1. Khởi tạo BLoC (Factory: mỗi lần gọi tạo 1 instance mới)
  sl.registerFactory(
    () => TaskBloc(
      getTasks: sl(),
      addTask: sl(),
      updateTask: sl(),
      deleteTask: sl(),
    ),
  );
  sl.registerFactory(
    () => BoardBloc(
      getBoards: sl(),
      addBoard: sl(),
      updateBoard: sl(),
      deleteBoard: sl(),
    ),
  );

  // 2. Khởi tạo Use cases (LazySingleton: chỉ tạo 1 lần duy nhất khi cần)
  sl.registerLazySingleton(() => GetTasks(sl()));
  sl.registerLazySingleton(() => AddTask(sl()));
  sl.registerLazySingleton(() => UpdateTask(sl()));
  sl.registerLazySingleton(() => DeleteTask(sl()));

  sl.registerLazySingleton(() => GetBoards(sl()));
  sl.registerLazySingleton(() => AddBoard(sl()));
  sl.registerLazySingleton(() => UpdateBoard(sl()));
  sl.registerLazySingleton(() => DeleteBoard(sl()));

  // 3. Khởi tạo Repository
  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(localDatabase: sl()),
  );
  sl.registerLazySingleton<BoardRepository>(
    () => BoardRepositoryImpl(localDatabase: sl()),
  );

  // 4. Khởi tạo Database Data sources
  sl.registerLazySingleton<LocalDatabase>(() => LocalDatabase());
}
