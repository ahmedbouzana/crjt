import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/app_models.dart';
import 'releve_calculator.dart';

class PdfExportService {
  final AppSettings settings;
  final Employe employe;
  final Releve releve;
  final int mois, annee;

  PdfExportService({
    required this.settings,
    required this.employe,
    required this.releve,
    required this.mois,
    required this.annee,
  });

  static const double _headerHeight = 52;
  static const _cBorder = PdfColors.black;
  static const _cHdr = PdfColor.fromInt(0xFFD9D9D9);
  static const _cTot = PdfColor.fromInt(0xFFBFBFBF);
  static const _cWeekend = PdfColor.fromInt(0xFFFFF2CC);
  static const _cFerie = PdfColor.fromInt(0xFFFFE0E0);
  static const _cRamadan = PdfColor.fromInt(0xFFE8F5E9);

  pw.Font get _f => pw.Font.helvetica();
  pw.Font get _fb => pw.Font.helveticaBold();

  pw.TextStyle _s({double sz = 10, bool b = false}) =>
      pw.TextStyle(font: b ? _fb : _f, fontSize: sz);

  // ── Dimensions colonnes (en points, A4 landscape ~820pt utilisable) ────────
  // DATE | HPRES | HABS | NBRE | MOTIF | loc*n | HS155 | HS1825 | HS210 | HS2375 | PAN | ASTRTE
  /*  List<double> _colW(int nbLoc) => [
    18, 
    22, 
    //16, 
    16, 
    20, 
    ...List.filled(nbLoc, 26.0),
    20, // HS×1.55
    20, // HS×1.825
    20, // HS×2.10
    20, // HS×2.375
    16, // PAN
    18, // ASTRTE
  ]; */
  List<double> _colW(int nbLoc) => [
    1.2, // DATE
    1.5, // H.PRES
    1.2, // NBRE
    1.5, // MOTIF
    ...List.filled(nbLoc, 1.8),
    1.4, 1.4, 1.4, 1.4, // HS×1.55
    1.2, // PAN
    1.3, // ASTRTE
  ];

  Future<File> generate() async {
    final pdf = pw.Document();
    final jours = ReleveCalculator(
      settings: settings,
      releve: releve,
    ).compute();
    final locs = settings.localites;
    //final nbLoc = locs.length.clamp(1, 6);
    final nbLoc = locs.length;
    //final colW = _colW(nbLoc);

    final weights = _colW(nbLoc);

    // largeur utile A4 (avec marges)
    final availableWidth = PdfPageFormat.a4.width - (10 * 2);

    final totalWeight = weights.fold(0.0, (a, b) => a + b);

    // 🔥 conversion poids → largeur réelle
    final colW = weights.map((w) => w * availableWidth / totalWeight).toList();

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
          children: [
            _entete(logo),
            pw.SizedBox(height: 3),
            _tableau1(),
            pw.SizedBox(height: 3),
            _titrePrincipalTableau2(),
            pw.SizedBox(height: 2),
            pw.Expanded(child: _tableau2(jours, locs, nbLoc, colW)),
            pw.SizedBox(height: 4),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text('Signature', style: _s()),
            ),
          ],
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
  pw.Widget _tableau1() {
    const double rowHeight = 0.2 * PdfPageFormat.inch;
    const double tableRowHeight = rowHeight * 5;

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
                    height: tableRowHeight,
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
                    height: tableRowHeight,
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
                    height: tableRowHeight,
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

  // ── Titre section tableau2 ──────────────────────────────────────────────────────────
  pw.Widget _titrePrincipalTableau2() => pw.Container(
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: _cBorder, width: 0.5),
      color: _cHdr,
    ),
    padding: const pw.EdgeInsets.symmetric(vertical: 3),
    child: pw.Text(
      'REPARTITION DES HEURES DE TRAVAIL PAR IMPUTATIONS',
      style: _s(b: true),
      textAlign: pw.TextAlign.center,
    ),
  );

  // ── Tableau2 ────────────────────────────────────────────────────────────────
  pw.Widget _tableau2(
    List<JourCalcule> jours,
    List<String> locs,
    int nbLoc,
    List<double> colW,
  ) {
    final tot = _totaux(jours, locs, nbLoc);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        // En-têtes construits manuellement (pour supporter le "colspan visuel")
        _headerRows(locs, nbLoc, colW),
        // Lignes de données
        pw.Expanded(
          child: pw.Table(
            columnWidths: {
              for (int i = 0; i < colW.length; i++)
                i: pw.FixedColumnWidth(colW[i]),
            },
            border: pw.TableBorder.all(color: _cBorder, width: 0.5),
            children: [
              ...jours.map((j) => _dataRow(j, locs, nbLoc)),
              _totRow(tot, locs, nbLoc),
            ],
          ),
        ),
      ],
    );
  }

  // ── En-têtes du tableau ──────────────────────────────
  pw.Widget _headerRows(List<String> locs, int nbLoc, List<double> colW) {
    final hsW =
        colW[4 + nbLoc] +
        colW[4 + nbLoc + 1] +
        colW[4 + nbLoc + 2] +
        colW[4 + nbLoc + 3];

    final indW = colW[4 + nbLoc + 4] + colW[4 + nbLoc + 5];
    final fixW = colW[0] + colW[1] + colW[2] + colW[3];

    pw.Widget hdr(String t, double w, {bool b = false}) => pw.Container(
      width: w,
      height: 16,
      alignment: pw.Alignment.center,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 0.5),
        color: _cHdr,
      ),
      child: pw.Text(
        t,
        style: _s(b: b),
        textAlign: pw.TextAlign.center,
      ),
    );

    /// 🔹 ROW 1
    final row1 = pw.Row(
      children: [
        hdr('DATE', colW[0], b: true),
        hdr('H. PRES', colW[1], b: true),
        hdr('H. ABS', (colW[2] + colW[3]), b: true),

        ...List.generate(nbLoc, (i) => hdr('${i + 1}', colW[4 + i], b: true)),

        hdr('HEURES SUPP', hsW, b: true),
        hdr('INDEMNITES', indW, b: true),
      ],
    );

    /// 🔹 ROW 2
    final row2 = pw.Row(
      children: [
        hdr('', colW[0]),
        hdr('', colW[1]),
        hdr('Nbre', colW[2], b: true),
        hdr('Motifs', colW[3], b: true),

        ...List.generate(nbLoc, (i) => hdr('', colW[4 + i])),

        hdr('155%', colW[4 + nbLoc], b: true),
        hdr('182.5%', colW[4 + nbLoc + 1], b: true),
        hdr('210%', colW[4 + nbLoc + 2], b: true),
        hdr('237.5%', colW[4 + nbLoc + 3], b: true),

        hdr('PAN', colW[4 + nbLoc + 4], b: true),
        hdr('ASTRTE', colW[4 + nbLoc + 5], b: true),
      ],
    );

    return pw.Column(children: [row1, row2]);
  }

  // ── Ligne de données ───────────────────────────────────────────────────────
  pw.TableRow _dataRow(JourCalcule j, List<String> locs, int nbLoc) {
    PdfColor? bg;
    switch (j.typeJour) {
      case TypeJour.weekend:
        bg = _cWeekend;
        break;
      case TypeJour.ferie:
        bg = _cFerie;
        break;
      case TypeJour.ramadan:
        bg = _cRamadan;
        break;
      default:
        break;
    }

    return pw.TableRow(
      decoration: bg != null ? pw.BoxDecoration(color: bg) : null,
      children: [
        _c('${j.jour}', b: true),
        _c(j.heuresPresence > 0 ? _fh(j.heuresPresence) : '/'),
        _c(j.heuresAbsence > 0 ? _fh(j.heuresAbsence) : ''),
        _c(j.motifAbsence ?? ''),
        ...List.generate(nbLoc, (li) {
          final loc = li < locs.length ? locs[li] : null;
          final h = loc != null ? (j.heuresParLocalite[loc] ?? 0.0) : 0.0;
          return _c(h > 0 ? _fh(h) : '');
        }),
        _c(j.hsSup155 > 0 ? _fh(j.hsSup155) : ''),
        _c(j.hsSup1825 > 0 ? _fh(j.hsSup1825) : ''),
        _c(j.hsSup210 > 0 ? _fh(j.hsSup210) : ''),
        _c(j.hsSup2375 > 0 ? _fh(j.hsSup2375) : ''),
        _c(j.pan ? '1' : ''),
        _c(j.astreinte ? '1' : ''),
      ],
    );
  }

  // ── Ligne totaux ───────────────────────────────────────────────────────────
  pw.TableRow _totRow(Map<String, dynamic> t, List<String> locs, int nbLoc) =>
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: _cTot),
        children: [
          _c('', b: true),
          _c(_fh(t['pres'] as double), b: true),
          _c(t['abs'] > 0 ? _fh(t['abs'] as double) : '', b: true),
          _c('', b: true),
          ...List.generate(nbLoc, (li) {
            final loc = li < locs.length ? locs[li] : null;
            final v = loc != null ? (t['loc'] as Map)[loc] ?? 0.0 : 0.0;
            return _c(v > 0 ? _fh(v as double) : '0', b: true);
          }),
          _c(_fh(t['h155'] as double), b: true),
          _c(_fh(t['h1825'] as double), b: true),
          _c(_fh(t['h210'] as double), b: true),
          _c(_fh(t['h2375'] as double), b: true),
          _c('${t['pan']}', b: true),
          _c('${t['astr']}', b: true),
        ],
      );

  // ── Cellule tableau données ────────────────────────────────────────────────
  pw.Widget _c(String text, {bool b = false}) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 1, vertical: 1),
    child: pw.Text(
      text,
      style: _s(b: b),
      textAlign: pw.TextAlign.center,
    ),
  );

  // ── Calcul totaux ──────────────────────────────────────────────────────────
  Map<String, dynamic> _totaux(
    List<JourCalcule> jours,
    List<String> locs,
    int nbLoc,
  ) {
    final locTot = <String, double>{};
    for (final l in locs) {
      locTot[l] = jours.fold(0.0, (a, j) => a + (j.heuresParLocalite[l] ?? 0));
    }
    return {
      'pres': jours.fold(0.0, (a, j) => a + j.heuresPresence),
      'abs': jours.fold(0.0, (a, j) => a + j.heuresAbsence),
      'h155': jours.fold(0.0, (a, j) => a + j.hsSup155),
      'h1825': jours.fold(0.0, (a, j) => a + j.hsSup1825),
      'h210': jours.fold(0.0, (a, j) => a + j.hsSup210),
      'h2375': jours.fold(0.0, (a, j) => a + j.hsSup2375),
      'pan': jours.where((j) => j.pan).length,
      'astr': jours.where((j) => j.astreinte).length,
      'loc': locTot,
    };
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  String _fh(double h) {
    if (h == 0) return '0';
    if (h == h.roundToDouble()) return h.toInt().toString();
    return h.toStringAsFixed(2);
  }

  String _fv(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toString();
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
