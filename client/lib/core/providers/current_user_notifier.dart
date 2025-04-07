
import 'package:flutter_spotify_clone/features/auth/model/user_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_user_notifier.g.dart';

@Riverpod(keepAlive: true)
class CurrentUserNotifier extends _$CurrentUserNotifier {
  @override
  User? build() {
    return null;
  }

  void addUser(User user) {
    state = user;
  }
}