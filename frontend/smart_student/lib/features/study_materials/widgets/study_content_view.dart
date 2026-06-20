import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Renders raw study-material content (plain text with `\n`) into a nicely
/// formatted view. It keeps the exact original order of the content and only
/// applies styling based on simple line heuristics:
///   * ALL CAPS lines and known section titles  -> bold headings
///   * lines ending with ':'                     -> semibold sub-labels
///   * lines starting with •, *, -, ✓            -> bullet points
///   * lines starting with "1. ", "2. " ...      -> numbered items
///   * formulas / tables (=, √, ×, multi-space)  -> monospace block
class StudyContentView extends StatelessWidget {
  final String content;

  const StudyContentView({super.key, required this.content});

  static const Set<String> _knownHeadings = {
    'chapter summary',
    'key concepts',
    'important formulae',
    'important formula',
    'important results',
    'important result',
    'important terms',
    'solved example',
    'solved examples',
    'exam tips',
    'quick revision',
    'introduction',
  };

  @override
  Widget build(BuildContext context) {
    final lines = content.split('\n');
    final widgets = <Widget>[];

    for (final raw in lines) {
      final line = raw.trim();

      if (line.isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      if (_isHeading(line)) {
        widgets.add(_heading(line));
      } else if (_isBullet(line)) {
        widgets.add(_bullet(line));
      } else if (_isSubLabel(line)) {
        widgets.add(_subLabel(line));
      } else if (_isNumbered(line)) {
        widgets.add(_numbered(line));
      } else if (_isMono(line)) {
        widgets.add(_mono(raw));
      } else {
        widgets.add(_paragraph(line));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  // ---- Classification helpers -------------------------------------------

  bool _isHeading(String line) {
    final lower = line.toLowerCase();
    if (_knownHeadings.contains(lower)) return true;

    // "10 One-Mark Questions", "5 Important Questions", "TWO MARK QUESTIONS"
    if (RegExp(r'^\d+\s+\S.*questions$', caseSensitive: false).hasMatch(line)) {
      return true;
    }
    // Telugu "... ప్రశ్నలు" question-section headings
    if (line.endsWith('ప్రశ్నలు')) return true;

    if (RegExp(r'[\u0C00-\u0C7F]').hasMatch(line)) {
      return _isTeluguHeading(line);
    }

    // ALL CAPS headings like INTRODUCTION, STANDARD FORM, CHAPTER 5: ...
    final letterCount = RegExp(r'[A-Za-z]').allMatches(line).length;
    if (letterCount < 3) return false;
    if (RegExp(r'[a-z]').hasMatch(line)) return false;
    if (RegExp(r'[={}/\\√×÷²³π≠≤≥±°~]').hasMatch(line)) return false;
    if (line.length > 50) return false;
    if (line.split(RegExp(r'\s+')).length > 7) return false;
    return true;
  }

  bool _isTeluguHeading(String line) {
    if (RegExp(r'[.?!:,।]$').hasMatch(line)) return false;
    if (_isBullet(line)) return false;
    if (RegExp(r'^\d').hasMatch(line)) return false;
    if (RegExp(r'[0-9]').hasMatch(line)) return false;
    if (RegExp(r'[={}/\\√×÷²³π≠≤≥±∅⊥∠△∪∩⊂]').hasMatch(line)) return false;
    if (line.split(RegExp(r'\s+')).length > 7) return false;
    if (line.length > 45) return false;
    return true;
  }

  bool _isBullet(String line) =>
      line.startsWith('✓') ||
      line.startsWith('•') ||
      line.startsWith('* ') ||
      line.startsWith('- ');

  bool _isSubLabel(String line) {
    if (!line.endsWith(':')) return false;
    return line.split(RegExp(r'\s+')).length <= 5;
  }

  bool _isNumbered(String line) => RegExp(r'^\d+\.\s').hasMatch(line);

  bool _isMono(String line) {
    if (RegExp(r'\S\s{2,}\S').hasMatch(line)) return true;
    return RegExp(r'[=√×÷²³π≠≤≥±∅⊥∠△]').hasMatch(line);
  }

  // ---- Renderers ---------------------------------------------------------

  Widget _heading(String line) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            line,
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.primaryBlueDark,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 44,
            height: 3,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _subLabel(String line) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 2),
      child: Text(
        line,
        style: AppTextStyles.titleMedium.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _bullet(String line) {
    final isCheck = line.startsWith('✓');
    final text = line.substring(1).trim();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: isCheck ? 2 : 8, right: 10),
            child: Icon(
              isCheck ? Icons.check_circle_rounded : Icons.circle,
              size: isCheck ? 17 : 7,
              color:
                  isCheck ? AppColors.secondaryGreen : AppColors.primaryBlue,
            ),
          ),
          Expanded(
            child: Text(text, style: AppTextStyles.bodyLarge),
          ),
        ],
      ),
    );
  }

  Widget _numbered(String line) {
    final idx = line.indexOf('. ');
    final number = line.substring(0, idx);
    final rest = line.substring(idx + 2).trim();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 10, top: 1),
            constraints: const BoxConstraints(minWidth: 26),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              number,
              textAlign: TextAlign.center,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Text(rest, style: AppTextStyles.bodyLarge),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mono(String raw) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        raw.replaceAll('\t', '    '),
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 14.5,
          height: 1.45,
          fontWeight: FontWeight.w500,
          color: AppColors.primaryBlueDark,
        ),
      ),
    );
  }

  Widget _paragraph(String line) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Text(line, style: AppTextStyles.bodyLarge),
    );
  }
}
