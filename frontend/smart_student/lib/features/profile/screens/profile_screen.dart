import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';
import '../../../injection.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = state is AuthAuthenticated ? state.user : null;

        return Scaffold(
          appBar: AppBar(title: const Text('Profile')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                AppCard(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                        backgroundImage: user?.photoUrl.isNotEmpty == true
                            ? NetworkImage(user!.photoUrl)
                            : null,
                        child: user?.photoUrl.isEmpty != false
                            ? const Icon(Icons.person, size: 48, color: AppColors.primaryBlue)
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user?.name ?? 'Student',
                        style: AppTextStyles.headlineMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _profileStat(
                        icon: Icons.local_fire_department_rounded,
                        label: 'Streak',
                        value: '${user?.streak ?? 0} days',
                        color: AppColors.accentOrange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _profileStat(
                        icon: Icons.star_rounded,
                        label: 'Points',
                        value: '${user?.points ?? 0}',
                        color: AppColors.secondaryGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _menuTile(
                  icon: Icons.quiz_rounded,
                  title: 'Completed Quizzes',
                  subtitle: 'View your quiz history',
                  onTap: () => context.go('/quizzes'),
                ),
                _menuTile(
                  icon: Icons.bookmark_rounded,
                  title: 'Saved Stories',
                  subtitle: 'Your bookmarked stories',
                  onTap: () => _showSavedStories(context),
                ),
                _menuTile(
                  icon: Icons.settings_rounded,
                  title: 'Settings',
                  subtitle: 'App preferences',
                  onTap: () {},
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await context.read<AuthCubit>().signOut();
                      if (context.mounted) context.go('/login');
                    },
                    icon: const Icon(Icons.logout_rounded, color: AppColors.accentRed),
                    label: Text(
                      'Logout',
                      style: AppTextStyles.labelLarge.copyWith(color: AppColors.accentRed),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.accentRed),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _profileStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return AppCard(
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.titleLarge),
          Text(label, style: AppTextStyles.labelMedium),
        ],
      ),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primaryBlue, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.titleMedium),
                  Text(subtitle, style: AppTextStyles.bodyMedium),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }

  Future<void> _showSavedStories(BuildContext context) async {
    final storage = getIt<StorageService>();
    final bookmarks = await storage.getBookmarkedStories();

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Saved Stories', style: AppTextStyles.headlineMedium),
              const SizedBox(height: 16),
              if (bookmarks.isEmpty)
                Text('No saved stories yet.', style: AppTextStyles.bodyMedium)
              else
                ...bookmarks.map(
                  (id) => ListTile(
                    leading: const Icon(Icons.bookmark_rounded, color: AppColors.accentOrange),
                    title: Text('Story $id'),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/stories/$id');
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
