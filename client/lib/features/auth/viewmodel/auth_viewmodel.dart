import 'package:flutter_spotify_clone/core/providers/current_user_notifier.dart';
import 'package:flutter_spotify_clone/features/auth/repositories/auth_local_repository.dart';
import 'package:flutter_spotify_clone/features/auth/repositories/auth_remote_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/user_model.dart';

part 'auth_viewmodel.g.dart';

@riverpod
class AuthViewModel extends _$AuthViewModel {
  late AuthRemoteRepository _authRemoteRepository;
  late AuthLocalRepository _authLocalRepository;
  late CurrentUserNotifier _currentUserNotifier;

  @override
  AsyncValue<User>? build() {
    _authRemoteRepository = ref.watch(authRemoteRepositoryProvider);
    _authLocalRepository = ref.watch(authLocalRepositoryProvider);
    _currentUserNotifier = ref.watch(currentUserNotifierProvider.notifier);
    return null;
  }

  Future<void> initSharedPreference() async {
    await _authLocalRepository.init();
  }

  Future<void> signUpUser(
      String name,
      String email,
      String password
      ) async {
    state = AsyncLoading();
    final res = await _authRemoteRepository.signUp(
      name,
      email,
      password,
    );
    final val = switch(res) {
      Left(value: final failure) => state = AsyncError(failure.message, StackTrace.current),
      Right(value: final user) => state = AsyncData(user),
    };
    print(val);
  }

  Future<void> loginUser(
      String email,
      String password
      ) async {
    state = AsyncLoading();
    final res = await _authRemoteRepository.login(
      email,
      password
    );
    final val = switch(res) {
      Left(value: final failure) => state = AsyncError(failure.message, StackTrace.current),
      Right(value: final user) => _loginSuccess(user),
    };
    print(val);
  }

  AsyncValue<User>? _loginSuccess(User user) {
    _authLocalRepository.setToken(user.token);
    _currentUserNotifier.addUser(user);
    return state = AsyncData(user);
  }

  Future<User?> getData() async {
    state = AsyncLoading();
    final token = _authLocalRepository.getToken();
    if (token != null) {
      final res = await _authRemoteRepository.getCurrentUserData(token);
      final val = switch(res) {
        Left(value: final failure) => state = AsyncError(failure.message, StackTrace.current),
        Right(value: final user) => _getDataSuccess(user),
      };
      return val.value;
    }
    return null;
  }
  
  AsyncValue<User> _getDataSuccess(User user) {
    _currentUserNotifier.addUser(user);
    return state = AsyncData(user);
  }
}