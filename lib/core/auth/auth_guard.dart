import 'package:flutter/material.dart';
import 'package:productivity/core/constants/routes.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';

/// Widget that protects routes requiring authentication
class AuthGuard extends StatelessWidget {
  final Widget child;
  final String? redirectTo;

  const AuthGuard({
    super.key,
    required this.child,
    this.redirectTo,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Show loading while checking auth state
        if (authProvider.isInitial || authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Redirect to login if not authenticated
        if (!authProvider.isAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed(
              redirectTo ?? Routes.login,
            );
          });
          return const SizedBox.shrink();
        }

        // Show protected content
        return child;
      },
    );
  }
}

/// Redirect authenticated users away from auth pages
class GuestGuard extends StatelessWidget {
  final Widget child;
  final String? redirectTo;

  const GuestGuard({
    super.key,
    required this.child,
    this.redirectTo,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Show loading while checking auth state
        if (authProvider.isInitial || authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Redirect to home if already authenticated
        if (authProvider.isAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed(
              redirectTo ?? Routes.home,
            );
          });
          return const SizedBox.shrink();
        }

        // Show guest content (login/register)
        return child;
      },
    );
  }
}