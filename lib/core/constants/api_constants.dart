/// API endpoint constants
class ApiConstants {
  // Base URL - Change this to your actual API URL
  static const String baseUrl = 'http://192.168.24.27:3000';

  // Auth endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String logoutEndpoint = '/auth/logout';
  static const String refreshTokenEndpoint = '/auth/refresh';
  static const String currentUserEndpoint = '/auth/me';
  static const String updateProfileEndpoint = '/auth/profile';
  static const String changePasswordEndpoint = '/auth/password';
  static const String forgotPasswordEndpoint = '/auth/forgot-password';

  // Task endpoints
  static const String tasksEndpoint = '/tasks';
  static const String dailyTasksEndpoint = '/tasks/daily';
  static const String completeTaskEndpoint = '/tasks/{id}/complete';

  // User progress endpoints
  static const String progressEndpoint = '/progress';
  static const String streakEndpoint = '/progress/streak';

  // Learning resources endpoints
  static const String roadmapsEndpoint = '/roadmaps';
  static const String resourcesEndpoint = '/resources';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}