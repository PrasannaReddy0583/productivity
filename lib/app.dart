/*
import 'package:flutter/material.dart';
import 'package:productivity/features/home/presentation/screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'core/auth/auth_provider.dart';
import 'features/auth/login_screen.dart';

class ProductivityApp extends StatelessWidget {
  const ProductivityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (_, auth, __) {
        if (auth.isLoading) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        return MaterialApp(
          home: auth.isLoggedIn
              ? const HomeScreen()
              : const LoginScreen(),
        );
      },
    );
  }
}
*/

/*
import 'package:flutter/material.dart';
// import 'package:productivity/core/constants/routes.dart';
import 'package:provider/provider.dart';

class ProductivityApp extends StatelessWidget {
  const ProductivityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        // routes: AppRoutes.routes,
        // initialRoute: AppRoutes.login,
        home: ,
      ),
    );
  }
}


class AuthGateWay {
  
}
*/