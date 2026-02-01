import 'package:flutter/material.dart';
import 'package:productivity/core/auth/auth_guard.dart';
import 'package:productivity/core/auth/auth_provider.dart';
import 'package:productivity/core/theme/app_colors.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        backgroundColor: AppColors.backgroundBlack,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundBlack,
          elevation: 0,
          title: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello ${authProvider.user?.name?.split(' ').first ?? 'there'} 👋',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const Text(
                    'Manage Your\nDaily Task',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                      height: 1.2,
                    ),
                  ),
                ],
              );
            },
          ),
          toolbarHeight: 100,
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: AppColors.cardDarkGray,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.text,
                ),
                onPressed: () {
                  // Navigate to notifications
                },
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Task Categories Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    _TaskCategoryCard(
                      title: 'Mobile',
                      taskCount: 6,
                      icon: '📱',
                      backgroundColor: AppColors.purplish,
                      textColor: AppColors.backgroundBlack,
                    ),
                    _TaskCategoryCard(
                      title: 'Wireframe',
                      taskCount: 12,
                      icon: '💡',
                      backgroundColor: AppColors.lightGreenish,
                      textColor: AppColors.backgroundBlack,
                    ),
                    _TaskCategoryCard(
                      title: 'Website',
                      taskCount: 5,
                      icon: '🎨',
                      backgroundColor: AppColors.websiteCardBg,
                      textColor: AppColors.backgroundBlack,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Ongoing Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Ongoing',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'See All',
                        style: TextStyle(
                          color: AppColors.calenderButtonsAndSelectedIcons,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Ongoing Tasks
                _OngoingTaskCard(
                  title: 'Salon App Wireframe',
                  priority: 'High',
                  priorityColor: AppColors.priorityHigh,
                  progress: 0.82,
                  startTime: '10:00 AM',
                  endTime: '06:00 PM',
                  dueDate: 'August 25',
                  avatars: ['👤', '👤'],
                ),
                const SizedBox(height: 16),
                _OngoingTaskCard(
                  title: 'Marketing Website',
                  priority: 'Medium',
                  priorityColor: AppColors.priorityMedium,
                  progress: 0.64,
                  startTime: '09:00 AM',
                  endTime: '05:00 PM',
                  dueDate: 'August 28',
                  avatars: ['👤', '👤', '👤'],
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundBlack,
            border: Border(
              top: BorderSide(
                color: AppColors.divider.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: const Icon(Icons.home_rounded),
                    color: AppColors.calenderButtonsAndSelectedIcons,
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today_rounded),
                    color: AppColors.bottomNavBarUnselectedIcons,
                    onPressed: () {},
                  ),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.calenderButtonsAndSelectedIcons,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add_rounded, size: 28),
                      color: AppColors.backgroundBlack,
                      onPressed: () {
                        // Create new task
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline_rounded),
                    color: AppColors.bottomNavBarUnselectedIcons,
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.person_outline_rounded),
                    color: AppColors.bottomNavBarUnselectedIcons,
                    onPressed: () async {
                      final shouldLogout = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: AppColors.cardDarkGray,
                          title: const Text(
                            'Logout',
                            style: TextStyle(color: AppColors.text),
                          ),
                          content: const Text(
                            'Are you sure you want to logout?',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(
                                'Logout',
                                style: TextStyle(
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (shouldLogout == true && context.mounted) {
                        await context.read<AuthProvider>().logout();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TaskCategoryCard extends StatelessWidget {
  final String title;
  final int taskCount;
  final String icon;
  final Color backgroundColor;
  final Color textColor;

  const _TaskCategoryCard({
    required this.title,
    required this.taskCount,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 32),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$taskCount Tasks',
                style: TextStyle(
                  fontSize: 12,
                  color: textColor.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OngoingTaskCard extends StatelessWidget {
  final String title;
  final String priority;
  final Color priorityColor;
  final double progress;
  final String startTime;
  final String endTime;
  final String dueDate;
  final List<String> avatars;

  const _OngoingTaskCard({
    required this.title,
    required this.priority,
    required this.priorityColor,
    required this.progress,
    required this.startTime,
    required this.endTime,
    required this.dueDate,
    required this.avatars,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDarkGray,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: priorityColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  priority,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                '$startTime - $endTime',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'Due Date: ',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    dueDate,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Row(
                children: avatars.map((avatar) {
                  return Container(
                    margin: const EdgeInsets.only(left: 4),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.calenderButtonsAndSelectedIcons,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.cardDarkGray,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        avatar,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}







/*
import 'package:flutter/material.dart';
import 'package:productivity/core/auth/auth_guard.dart';
import 'package:productivity/core/auth/auth_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          actions: [
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                // Navigate to profile
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );

                if (shouldLogout == true && context.mounted) {
                  await context.read<AuthProvider>().logout();
                }
              },
            ),
          ],
        ),
        body: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            final user = authProvider.user;

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blue,
                      child: Text(
                        user?.initials ?? '?',
                        style: const TextStyle(
                          fontSize: 32,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Welcome back,',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user?.displayName ?? 'User',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user?.email ?? '',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                    const SizedBox(height: 48),
                    const Text(
                      'Your coding journey starts here! 🚀',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
*/