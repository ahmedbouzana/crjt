import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/app_models.dart';
import 'releve_calculator.dart';

class TestPdfExportService {
  final AppSettings settings;
  final Employe employe;
  final Releve releve;
  final int mois, annee;

  TestPdfExportService({
    required this.settings,
    required this.employe,
    required this.releve,
    required this.mois,
    required this.annee,
  });

  static const double _headerHeight = 52;

  pw.Font get _f => pw.Font.helvetica();
  pw.Font get _fb => pw.Font.helveticaBold();

  pw.TextStyle _s(double sz, {bool b = false}) =>
      pw.TextStyle(font: b ? _fb : _f, fontSize: sz);

  Future<File> generate() async {
    final pdf = pw.Document();

    pw.MemoryImage? logo;
    if (settings.headerImage != null && settings.headerImage!.isNotEmpty) {
      try {
        logo = pw.MemoryImage(Uint8List.fromList(settings.headerImage!));
      } catch (_) {}
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.portrait,
        margin: const pw.EdgeInsets.all(10),
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [_entete(logo), pw.SizedBox(height: 3)],
        ),
      ),
    );

    final bytes = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final fileName = 'CRJT_${employe.matricule}_${_nomMois(mois)}_$annee.pdf';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file;
  }

  // ── En-tête ────────────────────────────────────────────────────────────────
  pw.Widget _entete(pw.MemoryImage? logo) {
    return logo != null
        ? pw.LayoutBuilder(
            builder: (ctx, constraints) {
              final w =
                  constraints?.maxWidth ?? PdfPageFormat.a4.availableWidth;
              final imgW = logo.width?.toDouble() ?? w;
              final imgH = logo.height?.toDouble() ?? _headerHeight;
              final ratio = imgW / imgH;
              final h = w / ratio;

              return pw.SizedBox(
                width: w,
                height: h,
                child: pw.Image(
                  logo,
                  fit: pw.BoxFit.contain,
                  width: w,
                  height: h,
                ),
              );
            },
          )
        : pw.Container(
            height: _headerHeight,
            color: PdfColors.grey200,
            alignment: pw.Alignment.center,
            child: pw.Text(
              'Région de Transport de l\'Électricité Blida',
              style: _s(8, b: true),
              textAlign: pw.TextAlign.center,
            ),
          );
  }

  String _nomMois(int m) {
    const n = [
      'JANVIER',
      'FEVRIER',
      'MARS',
      'AVRIL',
      'MAI',
      'JUIN',
      'JUILLET',
      'AOUT',
      'SEPTEMBRE',
      'OCTOBRE',
      'NOVEMBRE',
      'DECEMBRE',
    ];
    return n[m - 1];
  }
}
