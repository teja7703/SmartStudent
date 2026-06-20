import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/academic_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../cubit/study_material_cubit.dart';
import '../cubit/study_material_state.dart';

class StudyMaterialListScreen extends StatefulWidget {
  final String academicLevel;
  final String subject;
  final String language;

  const StudyMaterialListScreen({
    super.key,
    required this.academicLevel,
    required this.subject,
    this.language = 'English',
  });

  @override
  State<StudyMaterialListScreen> createState() =>
      _StudyMaterialListScreenState();
}

class _StudyMaterialListScreenState extends State<StudyMaterialListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<StudyMaterialCubit>().loadMaterials();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AcademicConstants.formatSubject(widget.subject, widget.language),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: AppSearchBar(
              controller: _searchController,
              hint: AcademicConstants.searchHint(widget.language),
              onChanged: (value) {
                context.read<StudyMaterialCubit>().loadMaterials(search: value);
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<StudyMaterialCubit, StudyMaterialState>(
              builder: (context, state) {
                if (state is StudyMaterialLoading) {
                  return const ShimmerLoading();
                }
                if (state is StudyMaterialError) {
                  return ErrorStateWidget(
                    message: state.message,
                    onRetry: () =>
                        context.read<StudyMaterialCubit>().loadMaterials(),
                  );
                }
                if (state is StudyMaterialEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.menu_book_outlined,
                    title: AcademicConstants.noMaterialsTitle(widget.language),
                    message:
                        AcademicConstants.noMaterialsMessage(widget.language),
                    onRetry: () =>
                        context.read<StudyMaterialCubit>().loadMaterials(),
                  );
                }
                if (state is StudyMaterialLoaded) {
                  return RefreshIndicator(
                    onRefresh: () => context
                        .read<StudyMaterialCubit>()
                        .loadMaterials(search: state.searchQuery),
                    color: AppColors.primaryBlue,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.materials.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final material = state.materials[index];
                        return AppCard(
                          onTap: () {
                            context.push(
                              '/study-materials/detail/${material.id}',
                              extra: material,
                            );
                          },
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.article_rounded,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      material.title,
                                      style: AppTextStyles.titleMedium,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Chapter: ${material.chapter}',
                                      style: AppTextStyles.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: AppColors.textHint,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
