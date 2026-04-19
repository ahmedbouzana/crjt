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

  pw.TextStyle _s({double sz = 10, bool b = false}) =>
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
          children: [_entete(logo), pw.SizedBox(height: 3), _tableau()],
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
              style: _s(b: true),
              textAlign: pw.TextAlign.center,
            ),
          );
  }

  // ── Tableau1 ────────────────────────────────────────────────────────────────
  pw.Widget _tableau() {
    const double rowHeight = 0.2 * PdfPageFormat.inch;
    final border = pw.TableBorder.all(width: 0.5, color: PdfColors.black);

    pw.Widget _cell(
      pw.Widget child, {
      double? height,
      pw.Alignment align = pw.Alignment.centerLeft,
    }) {
      return pw.Container(
        height: height ?? rowHeight,
        alignment: align,
        padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: child,
      );
    }

    pw.Widget _txt(String label, String value, {double? fontSize}) {
      return pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(
              text: label,
              style: _s(sz: fontSize ?? 10, b: true),
            ),
            pw.TextSpan(
              text: value,
              style: _s(sz: fontSize ?? 10),
            ),
          ],
        ),
      );
    }

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        // ── Tableau gauche ──────────────────────────────────────────
        pw.Expanded(
          child: pw.Table(
            border: pw.TableBorder.all(width: 0.5, color: PdfColors.black),
            children: [
              pw.TableRow(
                children: [
                  pw.Container(
                    height: rowHeight * 5,
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _txt('UNITE :   ', settings.unite),
                        _txt('SERVICE : ', settings.service),
                        _txt('CODE DE SERVICE : ', employe.codeService),
                        _txt('MATRICULE N° ', employe.matricule),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── Tableau centre — sans border ────────────────────────────
        pw.Expanded(
          child: pw.Table(
            border: const pw.TableBorder(), // ← aucune border
            children: [
              pw.TableRow(
                children: [
                  pw.Container(
                    height: rowHeight * 5,
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text('COMPTE RENDU', style: _s(sz: 14, b: true)),
                        pw.Text(
                          'JOURNALIER DE TRAVAIL',
                          style: _s(sz: 14, b: true),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── Tableau droite ──────────────────────────────────────────
        pw.Expanded(
          child: pw.Table(
            border: pw.TableBorder.all(width: 0.5, color: PdfColors.black),
            children: [
              pw.TableRow(
                children: [
                  pw.Container(
                    height: rowHeight * 5,
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _txt('NOM ET PRÉNOMS : ', employe.nomPrenoms),
                        _txt('Emploi : ', employe.emploi),
                        _txt(
                          'MOIS : ',
                          '${_nomMois(mois).toUpperCase()} $annee',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
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
