import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/quick_action_grid.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/stat_card.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardCubit>().loadDashboard();
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final user = authState is AuthAuthenticated ? authState.user : null;

        return BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () => context.read<DashboardCubit>().loadDashboard(),
              color: AppColors.primaryBlue,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildHeader(context, user),
                  ),
                  if (state is DashboardLoading)
                    const SliverFillRemaining(
                      child: ShimmerGridLoading(itemCount: 4),
                    )
                  else if (state is DashboardError)
                    SliverFillRemaining(
                      child: ErrorStateWidget(
                        message: state.message,
                        onRetry: () =>
                            context.read<DashboardCubit>().loadDashboard(),
                      ),
                    )
                  else if (state is DashboardLoaded) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: SectionHeader(title: 'Quick Actions'),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: QuickActionGrid(
                          items: [
                            QuickActionItem(
                              label: 'Study\nMaterials',
                              icon: Icons.menu_book_rounded,
                              color: AppColors.primaryBlue,
                              onTap: () => context.push('/study-materials'),
                            ),
                            QuickActionItem(
                              label: 'Previous\nPapers',
                              icon: Icons.description_rounded,
                              color: AppColors.accentOrange,
                              onTap: () => context.push('/previous-papers'),
                            ),
                            QuickActionItem(
                              label: 'Daily\nQuiz',
                              icon: Icons.quiz_rounded,
                              color: AppColors.secondaryGreen,
                              onTap: () => context.push('/quizzes'),
                            ),
                            QuickActionItem(
                              label: 'Careers',
                              icon: Icons.work_outline_rounded,
                              color: AppColors.accentPurple,
                              onTap: () => context.push('/careers'),
                            ),
                            QuickActionItem(
                              label: 'Stories',
                              icon: Icons.auto_stories_rounded,
                              color: AppColors.accentRed,
                              onTap: () => context.push('/stories'),
                            ),
                            QuickActionItem(
                              label: 'Spoken\nEnglish',
                              icon: Icons.record_voice_over_rounded,
                              color: AppColors.primaryBlueLight,
                              onTap: () => context.push('/coming-soon/spoken-english'),
                            ),
                            QuickActionItem(
                              label: 'Digital\nSkills',
                              icon: Icons.computer_rounded,
                              color: AppColors.secondaryGreenDark,
                              onTap: () => context.push('/coming-soon/digital-skills'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: SectionHeader(title: 'Your Progress'),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.1,
                        ),
                        delegate: SliverChildListDelegate([
                          StatCard(
                            title: 'Study Materials',
                            count: state.data.totalStudyMaterials,
                            icon: Icons.menu_book_rounded,
                            color: AppColors.primaryBlue,
                            onTap: () => context.push('/study-materials'),
                          ),
                          StatCard(
                            title: 'Previous Papers',
                            count: state.data.totalPreviousPapers,
                            icon: Icons.description_rounded,
                            color: AppColors.accentOrange,
                            onTap: () => context.push('/previous-papers'),
                          ),
                          StatCard(
                            title: 'Quizzes',
                            count: state.data.totalQuizzes,
                            icon: Icons.quiz_rounded,
                            color: AppColors.secondaryGreen,
                            onTap: () => context.push('/quizzes'),
                          ),
                          StatCard(
                            title: 'Careers',
                            count: state.data.totalCareers,
                            icon: Icons.work_outline_rounded,
                            color: AppColors.accentPurple,
                            onTap: () => context.push('/careers'),
                          ),
                          StatCard(
                            title: 'Stories',
                            count: state.data.totalStories,
                            icon: Icons.auto_stories_rounded,
                            color: AppColors.accentRed,
                            onTap: () => context.push('/stories'),
                          ),
                        ]),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, dynamic user) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryBlue,
            AppColors.primaryBlueLight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting(),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.firstName ?? 'Student',
                      style: AppTextStyles.headlineLarge.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white24,
                backgroundImage: user?.photoUrl.isNotEmpty == true
                    ? NetworkImage(user!.photoUrl)
                    : null,
                child: user?.photoUrl.isEmpty != false
                    ? const Icon(Icons.person, color: Colors.white, size: 28)
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStatChip(
                icon: Icons.local_fire_department_rounded,
                label: '${user?.streak ?? 0} Day Streak',
                color: AppColors.accentOrange,
              ),
              const SizedBox(width: 12),
              _buildStatChip(
                icon: Icons.star_rounded,
                label: '${user?.points ?? 0} Points',
                color: AppColors.secondaryGreen,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
