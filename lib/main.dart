import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/auth/auth_provider.dart';
import 'core/auth/auth_service.dart';
import 'core/auth/network/api_client.dart';
import 'core/auth/storage/secure_storage.dart';
import 'core/constants/routes.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/login_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize dependencies
    final secureStorage = SecureStorage();
    final apiClient = ApiClient(storage: secureStorage);
    final authService = AuthService(
      apiClient: apiClient,
      storage: secureStorage,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService: authService),
        ),
        // Add other providers here as needed
      ],
      child: MaterialApp(
        title: 'Productivity App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: Routes.login,
        routes: {
          Routes.login: (context) => const LoginScreen(),
          Routes.home: (context) => const HomeScreen(),
          // Add other routes here
        },
      ),
    );
  }
}