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

  static const _cBorder = PdfColors.black;
  static const _cHdr = PdfColor.fromInt(0xFFD9D9D9);
  static const _cTot = PdfColor.fromInt(0xFFBFBFBF);
  static const _cWeekend = PdfColor.fromInt(0xFFFFF2CC);
  static const _cFerie = PdfColor.fromInt(0xFFFFE0E0);
  static const _cRamadan = PdfColor.fromInt(0xFFE8F5E9);

  pw.Font get _f => pw.Font.helvetica();
  pw.Font get _fb => pw.Font.helveticaBold();

  pw.TextStyle _s(double sz, {bool b = false}) =>
      pw.TextStyle(font: b ? _fb : _f, fontSize: sz);

  // ── Dimensions colonnes (en points, A4 landscape ~820pt utilisable) ────────
  // DATE | HPRES | HABS | MOTIF | loc*n | HS155 | HS1825 | HS210 | HS2375 | PAN | ASTRTE
  List<double> _colW(int nbLoc) => [
    18, // DATE
    22, // H.PRES
    16, // H.ABS
    20, // MOTIF
    ...List.filled(nbLoc, 26.0),
    20, // HS×1.55
    20, // HS×1.825
    20, // HS×2.10
    20, // HS×2.375
    16, // PAN
    18, // ASTRTE
  ];

  Future<File> generate() async {
    final pdf = pw.Document();
    final jours = ReleveCalculator(
      settings: settings,
      releve: releve,
    ).compute();
    final locs = settings.localites;
    final nbLoc = locs.length.clamp(1, 6);
    final colW = _colW(nbLoc);

    pw.MemoryImage? logo;
    if (settings.headerImage != null && settings.headerImage!.isNotEmpty) {
      try {
        logo = pw.MemoryImage(Uint8List.fromList(settings.headerImage!));
      } catch (_) {}
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(10),
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            _entete(logo),
            pw.SizedBox(height: 3),
            _titrePrincipal(),
            pw.SizedBox(height: 2),
            pw.Expanded(child: _tableau(jours, locs, nbLoc, colW)),
            pw.SizedBox(height: 4),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Signature : ________________________',
                style: _s(7),
              ),
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
    final bord = pw.Border.all(color: _cBorder, width: 0.5);
    final sep = pw.Container(width: 0.5, color: _cBorder);
    return pw.Container(
      height: 52,
      decoration: pw.BoxDecoration(border: bord),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          // Logo
          pw.Container(
            width: 65,
            padding: const pw.EdgeInsets.all(3),
            child: logo != null
                ? pw.Image(logo, fit: pw.BoxFit.contain)
                : pw.Center(
                    child: pw.Text(
                      'Région de Transport\nde l\'Électricité Blida',
                      style: _s(5, b: true),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
          ),
          sep,
          // Unité / Service
          pw.Expanded(
            flex: 3,
            child: pw.Padding(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 3,
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                children: [
                  pw.Text('UNITE :   ${settings.unite}', style: _s(6.5)),
                  pw.Text('SERVICE : ${settings.service}', style: _s(6.5)),
                  pw.Text(
                    'CODE DE SERVICE : ${employe.codeService}',
                    style: _s(6.5),
                  ),
                  if (settings.adresse.isNotEmpty)
                    pw.Text(
                      'Adresse : ${settings.adresse}  Tél : ${settings.telephone}',
                      style: _s(5.5),
                    ),
                ],
              ),
            ),
          ),
          sep,
          // Titre centre
          pw.Expanded(
            flex: 2,
            child: pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    'COMPTE – RENDU',
                    style: _s(9, b: true),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.Text(
                    'DE TRAVAIL',
                    style: _s(9, b: true),
                    textAlign: pw.TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          sep,
          // Nom / info droite
          pw.Expanded(
            flex: 3,
            child: pw.Padding(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 3,
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                children: [
                  pw.Text('NOM ET PRÉNOMS :', style: _s(6)),
                  pw.Text(employe.nomPrenoms, style: _s(7.5, b: true)),
                  pw.Text('N° ${employe.matricule}', style: _s(6)),
                  pw.Text('Emploi : ${employe.emploi}', style: _s(6)),
                  pw.Text(
                    'MOIS : ${_nomMois(mois).toUpperCase()} $annee',
                    style: _s(7, b: true),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Titre section ──────────────────────────────────────────────────────────
  pw.Widget _titrePrincipal() => pw.Container(
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: _cBorder, width: 0.5),
      color: _cHdr,
    ),
    padding: const pw.EdgeInsets.symmetric(vertical: 3),
    child: pw.Text(
      'REPARTITION DES HEURES DE TRAVAIL PAR IMPUTATIONS',
      style: _s(8, b: true),
      textAlign: pw.TextAlign.center,
    ),
  );

  // ── Tableau ────────────────────────────────────────────────────────────────
  pw.Widget _tableau(
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

  // ── En-têtes du tableau (3 lignes manuelles) ──────────────────────────────
  pw.Widget _headerRows(List<String> locs, int nbLoc, List<double> colW) {
    final totalW = colW.fold(0.0, (a, b) => a + b);
    final locW = colW.sublist(4, 4 + nbLoc).fold(0.0, (a, b) => a + b);
    final hsW =
        colW[4 + nbLoc] +
        colW[4 + nbLoc + 1] +
        colW[4 + nbLoc + 2] +
        colW[4 + nbLoc + 3];
    final indW = colW[4 + nbLoc + 4] + colW[4 + nbLoc + 5];
    final fixW = colW[0] + colW[1] + colW[2] + colW[3];

    pw.Widget hdr(String t, double w, {bool b = false, PdfColor? bg}) =>
        pw.Container(
          width: w,
          height: 14,
          color: bg ?? _cHdr,
          padding: const pw.EdgeInsets.symmetric(horizontal: 1, vertical: 1),
          child: pw.Center(
            child: pw.Text(
              t,
              style: _s(5.5, b: b),
              textAlign: pw.TextAlign.center,
              maxLines: 2,
            ),
          ),
        );

    final bord = pw.Border.all(color: _cBorder, width: 0.5);

    // Ligne 1 : numéros localités
    final row1 = pw.Container(
      decoration: pw.BoxDecoration(border: bord),
      child: pw.Row(
        children: [
          hdr('', fixW),
          ...List.generate(nbLoc, (i) => hdr('${i + 1}', colW[4 + i], b: true)),
          hdr('', hsW),
          hdr('', indW),
        ],
      ),
    );

    // Ligne 2 : noms localités + taux HS
    final row2 = pw.Container(
      decoration: pw.BoxDecoration(border: bord),
      child: pw.Row(
        children: [
          hdr('DATE', colW[0], b: true),
          hdr('H.\nPRES.', colW[1], b: true),
          hdr('H.\nABS.', colW[2], b: true),
          hdr('MOTIF', colW[3], b: true),
          ...List.generate(
            nbLoc,
            (i) => hdr(i < locs.length ? locs[i] : '', colW[4 + i], b: true),
          ),
          hdr('HEURES SUPPLEMENTAIRES', hsW, b: true),
          hdr('INDEMNITES', indW, b: true),
        ],
      ),
    );

    // Ligne 3 : sous-colonnes HS + PAN/ASTRTE
    final row3 = pw.Container(
      decoration: pw.BoxDecoration(border: bord),
      child: pw.Row(
        children: [
          hdr('', fixW),
          ...List.generate(nbLoc, (i) => hdr('', colW[4 + i])),
          hdr('x${_fv(settings.taux.jourOuvrJour)}', colW[4 + nbLoc], b: true),
          hdr(
            'x${_fv(settings.taux.jourFerieJour)}',
            colW[4 + nbLoc + 1],
            b: true,
          ),
          hdr(
            'x${_fv(settings.taux.jourOuvrNuit)}',
            colW[4 + nbLoc + 2],
            b: true,
          ),
          hdr(
            'x${_fv(settings.taux.jourFerieNuit)}',
            colW[4 + nbLoc + 3],
            b: true,
          ),
          hdr('PAN', colW[4 + nbLoc + 4], b: true),
          hdr('ASTRTE', colW[4 + nbLoc + 5], b: true),
        ],
      ),
    );

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [row1, row2, row3],
    );
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
      style: _s(7, b: b),
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
