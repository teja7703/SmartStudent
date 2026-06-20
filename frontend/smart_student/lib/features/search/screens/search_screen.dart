import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../injection.dart';
import '../../careers/models/career_model.dart';
import '../../careers/repositories/career_repository.dart';
import '../../stories/models/story_model.dart';
import '../../stories/repositories/story_repository.dart';
import '../../study_materials/models/study_material_model.dart';
import '../../study_materials/repositories/study_material_repository.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _studyRepo = getIt<StudyMaterialRepository>();
  final _careerRepo = getIt<CareerRepository>();
  final _storyRepo = getIt<StoryRepository>();

  Timer? _debounce;
  bool _loading = false;
  String _query = '';

  List<StudyMaterialModel> _materials = const [];
  List<CareerModel> _careers = const [];
  List<StoryModel> _stories = const [];

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(value));
  }

  Future<void> _search(String value) async {
    final query = value.trim();
    setState(() => _query = query);
    if (query.isEmpty) {
      setState(() {
        _materials = const [];
        _careers = const [];
        _stories = const [];
        _loading = false;
      });
      return;
    }

    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _studyRepo.searchMaterials(query),
        _careerRepo.getCareers(search: query),
        _storyRepo.getStories(search: query),
      ]);
      if (!mounted) return;
      setState(() {
        _materials = results[0] as List<StudyMaterialModel>;
        _careers = results[1] as List<CareerModel>;
        _stories = results[2] as List<StoryModel>;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  int get _total => _materials.length + _careers.length + _stories.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onChanged: _onChanged,
          decoration: const InputDecoration(
            hintText: 'Search materials, careers, stories...',
            border: InputBorder.none,
          ),
        ),
        actions: [
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_rounded),
              onPressed: () {
                _controller.clear();
                _search('');
              },
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_query.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.search_rounded,
        title: 'Search Smart Student',
        message: 'Find study materials, careers and success stories.',
      );
    }
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_total == 0) {
      return EmptyStateWidget(
        icon: Icons.search_off_rounded,
        title: 'No results for "$_query"',
        message: 'Try different keywords.',
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_materials.isNotEmpty) ...[
          _SectionTitle(label: 'Study Materials', count: _materials.length),
          ..._materials.map((m) => _ResultTile(
                icon: Icons.menu_book_rounded,
                color: AppColors.primaryBlue,
                title: m.chapter,
                subtitle: '${m.subject} • ${m.academicLevel}',
                onTap: () =>
                    context.push('/study-materials/detail/${m.id}', extra: m),
              )),
          const SizedBox(height: 12),
        ],
        if (_careers.isNotEmpty) ...[
          _SectionTitle(label: 'Careers', count: _careers.length),
          ..._careers.map((c) => _ResultTile(
                icon: Icons.work_rounded,
                color: AppColors.accentPurple,
                title: c.careerName,
                subtitle: c.category,
                onTap: () => context.push('/careers/${c.id}'),
              )),
          const SizedBox(height: 12),
        ],
        if (_stories.isNotEmpty) ...[
          _SectionTitle(label: 'Success Stories', count: _stories.length),
          ..._stories.map((s) => _ResultTile(
                icon: Icons.auto_stories_rounded,
                color: AppColors.accentRed,
                title: s.title,
                subtitle: s.category,
                onTap: () => context.push('/stories/${s.id}'),
              )),
        ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String label;
  final int count;

  const _SectionTitle({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(label, style: AppTextStyles.titleMedium),
          const SizedBox(width: 8),
          Text('($count)', style: AppTextStyles.labelMedium),
        ],
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ResultTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.labelMedium),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}
