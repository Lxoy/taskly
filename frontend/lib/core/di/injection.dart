import 'package:frontend/core/notifications/notification_service.dart';
import 'package:frontend/data/repositories/stats_repository_impl.dart';
import 'package:frontend/domain/stats_repository.dart';
import 'package:frontend/features/statistics/bloc/stats_block.dart';
import 'package:get_it/get_it.dart';
import 'package:frontend/data/network/api_client.dart';
import 'package:frontend/data/repositories/auth_repository_impl.dart';
import 'package:frontend/data/repositories/home_repository_impl.dart';
import 'package:frontend/data/repositories/category_repository_impl.dart';
import 'package:frontend/data/repositories/entry_repository_impl.dart';
import 'package:frontend/data/repositories/user_repository_impl.dart';
import 'package:frontend/domain/repositories/auth_repository.dart';
import 'package:frontend/domain/repositories/home_repository.dart';
import 'package:frontend/domain/repositories/category_repository.dart';
import 'package:frontend/domain/repositories/entry_repository.dart';
import 'package:frontend/domain/repositories/user_repository.dart';
import 'package:frontend/features/auth/bloc/auth_bloc.dart';
import 'package:frontend/features/home/bloc/home_bloc.dart';
import 'package:frontend/features/categories/bloc/category_bloc.dart';
import 'package:frontend/features/entry/bloc/entry_bloc.dart';
import 'package:frontend/features/user/bloc/user_bloc.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5090',
  );

  sl.registerLazySingleton<ApiClient>(() => ApiClient(baseUrl: baseUrl));

  // ── Repositories ─────────────────────────────────────────────
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<ApiClient>()),
  );
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(sl<ApiClient>()),
  );
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(sl<ApiClient>()),
  );
  sl.registerLazySingleton<EntryRepository>(
    () => EntryRepositoryImpl(sl<ApiClient>()),
  );
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(sl<ApiClient>()),
  );

  // ── BLoCs ────────────────────────────────────────────────────
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(sl<AuthRepository>(), sl<ApiClient>()),
  );
  sl.registerFactory<HomeBloc>(() => HomeBloc(sl<HomeRepository>()));
  sl.registerFactory<CategoryBloc>(
    () => CategoryBloc(sl<CategoryRepository>()),
  );
  sl.registerFactory<EntryBloc>(() => EntryBloc(sl<EntryRepository>()));
  sl.registerFactory<UserBloc>(
    () => UserBloc(sl<UserRepository>(), sl<ApiClient>()),
  );

  sl.registerLazySingleton<StatsRepository>(() => StatsRepositoryImpl(sl()));

  sl.registerFactory(() => StatsBloc(sl()));

  sl.registerLazySingleton<NotificationService>(
    () => NotificationService(sl<ApiClient>()),
  );
}
