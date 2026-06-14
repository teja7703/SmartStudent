import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../models/previous_paper_model.dart';

class PreviousPaperDetailScreen extends StatelessWidget {
  final PreviousPaperModel paper;

  const PreviousPaperDetailScreen({super.key, required this.paper});

  Future<void> _openPdf() async {
    final uri = Uri.parse(paper.pdfUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${paper.year} Paper')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Year ${paper.year}', style: AppTextStyles.headlineMedium),
                  const SizedBox(height: 8),
                  _infoRow('Subject', paper.subject),
                  _infoRow('Level', paper.academicLevel),
                  _infoRow('Type', paper.paperType),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openPdf,
                icon: const Icon(Icons.picture_as_pdf_rounded),
                label: const Text('Open PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentOrange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Text('$label: ', style: AppTextStyles.labelMedium),
          Text(value, style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          )),
        ],
      ),
    );
  }
}
