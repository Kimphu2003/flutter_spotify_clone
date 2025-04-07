import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spotify_clone/core/providers/current_user_notifier.dart';
import 'package:flutter_spotify_clone/core/theme/theme.dart';
import 'package:flutter_spotify_clone/features/auth/view/pages/login_page.dart';
import 'package:flutter_spotify_clone/features/auth/view/pages/signup_page.dart';
import 'package:flutter_spotify_clone/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:flutter_spotify_clone/features/home/view/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer();
  await container.read(authViewModelProvider.notifier).initSharedPreference();
  await container.read(authViewModelProvider.notifier).getData();
  runApp(UncontrolledProviderScope(container: container, child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserNotifierProvider);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: AppTheme.darkThemeMode,
      home: currentUser == null ? const LoginPage() : const HomePage(),
    );
  }
}
