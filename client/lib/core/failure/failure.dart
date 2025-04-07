
class AppFailure {
  final String message;
  AppFailure([this.message = 'Sorry, An unexpected error occurred!']);

  @override
  String toString() => 'AppFailure(message: $message)';
}
