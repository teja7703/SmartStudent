import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/study_material_model.dart';

/// Builds a nicely formatted PDF from a [StudyMaterialModel] and opens the
/// system share / save / print sheet so the user can download it.
class StudyMaterialPdf {
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

  static const PdfColor _primary = PdfColor.fromInt(0xFF1E56A0);
  static const PdfColor _primaryDark = PdfColor.fromInt(0xFF0D3B7A);
  static const PdfColor _green = PdfColor.fromInt(0xFF1E8449);
  static const PdfColor _textPrimary = PdfColor.fromInt(0xFF1A1D26);

  /// Generates the PDF and saves it to the device's Downloads folder
  /// (with safe fallbacks). Returns the saved file path.
  static Future<String> downloadForMaterial(
    StudyMaterialModel material,
  ) async {
    final bytes = await _build(material);
    final safeName = material.title
        .replaceAll(RegExp(r'[^a-zA-Z0-9 ]'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), '_');
    final filename = '${safeName.isEmpty ? 'study_material' : safeName}.pdf';
    final file = await _writeBytes(bytes, filename);
    return file.path;
  }

  /// Opens the system share sheet for the generated PDF.
  static Future<void> shareForMaterial(StudyMaterialModel material) async {
    final bytes = await _build(material);
    final safeName = material.title
        .replaceAll(RegExp(r'[^a-zA-Z0-9 ]'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), '_');
    await Printing.sharePdf(
      bytes: bytes,
      filename: '${safeName.isEmpty ? 'study_material' : safeName}.pdf',
    );
  }

  static Future<File> _writeBytes(Uint8List bytes, String filename) async {
    final candidates = <Directory>[];

    if (Platform.isAndroid) {
      candidates.add(Directory('/storage/emulated/0/Download'));
      final ext = await getExternalStorageDirectory();
      if (ext != null) candidates.add(ext);
    } else {
      final downloads = await getDownloadsDirectory();
      if (downloads != null) candidates.add(downloads);
    }
    candidates.add(await getApplicationDocumentsDirectory());

    Object? lastError;
    for (final dir in candidates) {
      try {
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
        final file = File('${dir.path}/$filename');
        await file.writeAsBytes(bytes, flush: true);
        return file;
      } catch (e) {
        lastError = e;
      }
    }
    throw Exception('Could not save PDF: $lastError');
  }

  static Future<Uint8List> _build(StudyMaterialModel material) async {
    final isTelugu = material.language == 'Telugu';

    final base = isTelugu
        ? await PdfGoogleFonts.notoSansTeluguRegular()
        : await PdfGoogleFonts.notoSansRegular();
    final bold = isTelugu
        ? await PdfGoogleFonts.notoSansTeluguBold()
        : await PdfGoogleFonts.notoSansBold();
    final mono = await PdfGoogleFonts.robotoMonoRegular();
    final fallback = <pw.Font>[
      if (isTelugu) await PdfGoogleFonts.notoSansRegular(),
      await PdfGoogleFonts.notoSansTeluguRegular(),
      await PdfGoogleFonts.notoSansMathRegular(),
      await PdfGoogleFonts.notoSansSymbolsRegular(),
      await PdfGoogleFonts.notoSansSymbols2Regular(),
    ];

    final doc = pw.Document(
      theme: pw.ThemeData.withFont(
        base: base,
        bold: bold,
        fontFallback: fallback,
      ),
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(36, 40, 36, 40),
        build: (context) => [
          _titleBlock(material),
          pw.SizedBox(height: 18),
          ..._contentWidgets(material.content, mono, fallback),
        ],
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 10),
          child: pw.Text(
            'SmartStudent  •  Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
          ),
        ),
      ),
    );

    return doc.save();
  }

  static pw.Widget _titleBlock(StudyMaterialModel material) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(18),
      decoration: const pw.BoxDecoration(
        color: _primary,
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(10)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Chapter: ${material.chapter}',
            style: const pw.TextStyle(fontSize: 11, color: PdfColors.white),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            material.title,
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
        ],
      ),
    );
  }

  static List<pw.Widget> _contentWidgets(
    String content,
    pw.Font mono,
    List<pw.Font> fallback,
  ) {
    final lines = content.split('\n');
    final widgets = <pw.Widget>[];

    for (final raw in lines) {
      final line = raw.trim();

      if (line.isEmpty) {
        widgets.add(pw.SizedBox(height: 6));
        continue;
      }

      if (_isHeading(line)) {
        widgets.add(pw.Padding(
          padding: const pw.EdgeInsets.only(top: 16, bottom: 6),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                line,
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: _primaryDark,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Container(width: 40, height: 2, color: _primary),
            ],
          ),
        ));
      } else if (_isBullet(line)) {
        final isCheck = line.startsWith('✓');
        final text = line.substring(1).trim();
        widgets.add(pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 2),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                isCheck ? '✓ ' : '•  ',
                style: pw.TextStyle(
                  fontSize: 11,
                  color: isCheck ? _green : _primary,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Expanded(
                child: pw.Text(
                  text,
                  style: const pw.TextStyle(fontSize: 11, color: _textPrimary),
                ),
              ),
            ],
          ),
        ));
      } else if (_isSubLabel(line)) {
        widgets.add(pw.Padding(
          padding: const pw.EdgeInsets.only(top: 8, bottom: 2),
          child: pw.Text(
            line,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: _textPrimary,
            ),
          ),
        ));
      } else if (_isMono(raw)) {
        widgets.add(pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
          child: pw.Text(
            raw.replaceAll('\t', '    '),
            style: pw.TextStyle(
              font: mono,
              fontFallback: fallback,
              fontSize: 10.5,
              color: _primaryDark,
            ),
          ),
        ));
      } else {
        widgets.add(pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 2),
          child: pw.Text(
            line,
            style: const pw.TextStyle(
              fontSize: 11,
              color: _textPrimary,
              lineSpacing: 2,
            ),
          ),
        ));
      }
    }

    return widgets;
  }

  // ---- Classification (mirrors StudyContentView) ------------------------

  static bool _isHeading(String line) {
    final lower = line.toLowerCase();
    if (_knownHeadings.contains(lower)) return true;
    if (RegExp(r'^\d+\s+\S.*questions$', caseSensitive: false)
        .hasMatch(line)) {
      return true;
    }
    if (line.endsWith('ప్రశ్నలు')) return true;

    if (RegExp(r'[\u0C00-\u0C7F]').hasMatch(line)) {
      return _isTeluguHeading(line);
    }

    final letterCount = RegExp(r'[A-Za-z]').allMatches(line).length;
    if (letterCount < 3) return false;
    if (RegExp(r'[a-z]').hasMatch(line)) return false;
    if (RegExp(r'[={}/\\√×÷²³π≠≤≥±°~]').hasMatch(line)) return false;
    if (line.length > 50) return false;
    if (line.split(RegExp(r'\s+')).length > 7) return false;
    return true;
  }

  static bool _isTeluguHeading(String line) {
    if (RegExp(r'[.?!:,।]$').hasMatch(line)) return false;
    if (_isBullet(line)) return false;
    if (RegExp(r'^\d').hasMatch(line)) return false;
    if (RegExp(r'[0-9]').hasMatch(line)) return false;
    if (RegExp(r'[={}/\\√×÷²³π≠≤≥±∅⊥∠△∪∩⊂]').hasMatch(line)) return false;
    if (line.split(RegExp(r'\s+')).length > 7) return false;
    if (line.length > 45) return false;
    return true;
  }

  static bool _isBullet(String line) =>
      line.startsWith('✓') ||
      line.startsWith('•') ||
      line.startsWith('* ') ||
      line.startsWith('- ');

  static bool _isSubLabel(String line) {
    if (!line.endsWith(':')) return false;
    return line.split(RegExp(r'\s+')).length <= 5;
  }

  static bool _isMono(String line) {
    if (RegExp(r'\S\s{2,}\S').hasMatch(line)) return true;
    return RegExp(r'[=√×÷²³π≠≤≥±∅⊥∠△]').hasMatch(line);
  }
}
