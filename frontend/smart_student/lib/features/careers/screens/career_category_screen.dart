import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../cubit/career_cubit.dart';
import '../cubit/career_state.dart';
import 'careers_screen.dart';

class CareerCategoryScreen extends StatefulWidget {
  final String category;

  const CareerCategoryScreen({super.key, required this.category});

  @override
  State<CareerCategoryScreen> createState() => _CareerCategoryScreenState();
}

class _CareerCategoryScreenState extends State<CareerCategoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CareerCubit>().loadCareers(category: widget.category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.category)),
      body: BlocBuilder<CareerCubit, CareerState>(
        builder: (context, state) {
          if (state is CareerLoading || state is CareerInitial) {
            return const ShimmerLoading(height: 100);
          }
          if (state is CareerError) {
            return ErrorStateWidget(
              message: state.message,
              onRetry: () => context
                  .read<CareerCubit>()
                  .loadCareers(category: widget.category),
            );
          }
          if (state is CareerEmpty) {
            return const EmptyStateWidget(
              icon: Icons.work_outline,
              title: 'Nothing here yet',
              message: 'Careers for this category will appear soon.',
            );
          }
          if (state is CareerLoaded) {
            return RefreshIndicator(
              color: AppColors.primaryBlue,
              onRefresh: () => context
                  .read<CareerCubit>()
                  .loadCareers(category: widget.category),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.careers.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) =>
                    CareerListTile(career: state.careers[index]),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
