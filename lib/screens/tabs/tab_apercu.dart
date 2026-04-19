import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../models/app_models.dart';
import '../../../../services/releve_calculator.dart';
import '../../../../theme/app_theme.dart';

class TabApercu extends StatelessWidget {
  final List<JourCalcule> jours;
  final AppSettings settings;
  final Employe employe;
  final Releve releve;
  final int mois, annee;

  const TabApercu({
    super.key,
    required this.jours,
    required this.settings,
    required this.employe,
    required this.releve,
    required this.mois,
    required this.annee,
  });

  @override
  Widget build(BuildContext context) {
    final localites = settings.localites;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats rapides
          _buildStats(),
          const SizedBox(height: 16),
          // Tableau
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _buildTable(localites),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final totalPresence = jours.fold(0.0, (s, j) => s + j.heuresPresence);
    final totalAbsence = jours.fold(0.0, (s, j) => s + j.heuresAbsence);
    final totalHS155 = jours.fold(0.0, (s, j) => s + j.hsSup155);
    final totalHS210 = jours.fold(0.0, (s, j) => s + j.hsSup210);
    final totalHS1825 = jours.fold(0.0, (s, j) => s + j.hsSup1825);
    final totalHS2375 = jours.fold(0.0, (s, j) => s + j.hsSup2375);
    final totalPAN = jours.where((j) => j.pan).length;
    final totalAstr = jours.where((j) => j.astreinte).length;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _StatCard(
          label: 'Heures présence',
          value: '${totalPresence.toStringAsFixed(0)}h',
          color: AppTheme.accent,
        ),
        _StatCard(
          label: 'Heures absence',
          value: '${totalAbsence.toStringAsFixed(0)}h',
          color: AppTheme.danger,
        ),
        _StatCard(
          label: 'H.Supp ×1.55',
          value: '${totalHS155.toStringAsFixed(2)}h',
          color: AppTheme.primary,
        ),
        _StatCard(
          label: 'H.Supp ×2.10',
          value: '${totalHS210.toStringAsFixed(2)}h',
          color: AppTheme.primary,
        ),
        _StatCard(
          label: 'H.Supp ×1.825',
          value: '${totalHS1825.toStringAsFixed(2)}h',
          color: const Color(0xFFBA7517),
        ),
        _StatCard(
          label: 'H.Supp ×2.375',
          value: '${totalHS2375.toStringAsFixed(2)}h',
          color: const Color(0xFFBA7517),
        ),
        _StatCard(label: 'PAN', value: '$totalPAN j', color: AppTheme.accent),
        _StatCard(
          label: 'Astreinte',
          value: '$totalAstr j',
          color: const Color(0xFF534AB7),
        ),
      ],
    );
  }

  Widget _buildTable(List<String> localites) {
    final nbLoc = localites.isEmpty ? 1 : localites.length;

    // Totaux
    final totPresence = jours.fold(0.0, (s, j) => s + j.heuresPresence);
    final totAbsence = jours.fold(0.0, (s, j) => s + j.heuresAbsence);
    final Map<String, double> totLoc = {};
    for (final loc in localites) {
      totLoc[loc] = jours.fold(
        0.0,
        (s, j) => s + (j.heuresParLocalite[loc] ?? 0),
      );
    }
    final tot155 = jours.fold(0.0, (s, j) => s + j.hsSup155);
    final tot1825 = jours.fold(0.0, (s, j) => s + j.hsSup1825);
    final tot210 = jours.fold(0.0, (s, j) => s + j.hsSup210);
    final tot2375 = jours.fold(0.0, (s, j) => s + j.hsSup2375);
    final totPAN = jours.where((j) => j.pan).length;
    final totAstr = jours.where((j) => j.astreinte).length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Table(
          defaultColumnWidth: const IntrinsicColumnWidth(),
          border: TableBorder.all(color: AppTheme.border, width: 0.5),
          children: [
            // Row 1 : numéros localités
            TableRow(
              decoration: const BoxDecoration(color: Color(0xFFF5F4F0)),
              children: [
                _TH('DATE'),
                _TH('H.PRÉSENCE'),
                _TH('H.ABSENCE\nNbre'),
                _TH('H.ABSENCE\nMotifs'),
                ...List.generate(nbLoc, (i) => _TH('${i + 1}')),
                _TH('H.SUPP\n×${settings.taux.jourOuvrJour}'),
                _TH('H.SUPP\n×${settings.taux.jourFerieJour}'),
                _TH('H.SUPP\n×${settings.taux.jourOuvrNuit}'),
                _TH('H.SUPP\n×${settings.taux.jourFerieNuit}'),
                _TH('PAN'),
                _TH('ASTRTE'),
              ],
            ),
            // Row 2 : noms localités
            TableRow(
              decoration: const BoxDecoration(color: Color(0xFFF5F4F0)),
              children: [
                _TH(''),
                _TH(''),
                _TH(''),
                _TH(''),
                ...localites.map((l) => _TH(l, fontSize: 9)),
                _TH(''),
                _TH(''),
                _TH(''),
                _TH(''),
                _TH(''),
                _TH(''),
              ],
            ),
            // Data rows
            ...jours.map((j) => _buildRow(j, localites)),
            // Totaux
            TableRow(
              decoration: const BoxDecoration(color: Color(0xFFEEEDFE)),
              children: [
                _TC('TOTAL', bold: true),
                _TC(_fmtH(totPresence), bold: true),
                _TC(_fmtH(totAbsence), bold: true),
                _TC(''),
                ...localites.map((l) => _TC(_fmtH(totLoc[l] ?? 0), bold: true)),
                _TC(_fmtH(tot155), bold: true),
                _TC(_fmtH(tot1825), bold: true),
                _TC(_fmtH(tot210), bold: true),
                _TC(_fmtH(tot2375), bold: true),
                _TC('$totPAN', bold: true),
                _TC('$totAstr', bold: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildRow(JourCalcule j, List<String> localites) {
    Color? rowColor;
    if (j.typeJour == TypeJour.weekend) rowColor = const Color(0xFFFFF3CD);
    if (j.typeJour == TypeJour.ferie) rowColor = const Color(0xFFFFE0E0);
    if (j.typeJour == TypeJour.ramadan) rowColor = const Color(0xFFE8F5E9);

    return TableRow(
      decoration: BoxDecoration(color: rowColor),
      children: [
        _TC('${j.jour}', bold: true),
        _TC(
          j.heuresPresence > 0 ? _fmtH(j.heuresPresence) : '/',
          color: j.typeJour == TypeJour.weekend || j.typeJour == TypeJour.ferie
              ? AppTheme.danger
              : null,
        ),
        _TC(j.heuresAbsence > 0 ? _fmtH(j.heuresAbsence) : ''),
        _TC(
          j.motifAbsence ?? '',
          color: j.motifAbsence != null ? AppTheme.danger : null,
        ),
        ...localites.map((l) {
          final h = j.heuresParLocalite[l] ?? 0;
          return _TC(h > 0 ? _fmtH(h) : '');
        }),
        _TC(j.hsSup155 > 0 ? _fmtH(j.hsSup155) : ''),
        _TC(j.hsSup1825 > 0 ? _fmtH(j.hsSup1825) : ''),
        _TC(j.hsSup210 > 0 ? _fmtH(j.hsSup210) : ''),
        _TC(j.hsSup2375 > 0 ? _fmtH(j.hsSup2375) : ''),
        _TC(j.pan ? '1' : '', color: j.pan ? AppTheme.accent : null),
        _TC(
          j.astreinte ? '1' : '',
          color: j.astreinte ? const Color(0xFF534AB7) : null,
        ),
      ],
    );
  }

  String _fmtH(double h) {
    if (h == 0) return '';
    if (h == h.roundToDouble()) return h.toInt().toString();
    return h.toStringAsFixed(2);
  }
}

// ─── Table cell helpers ───────────────────────────────────────────────────────
class _TH extends StatelessWidget {
  final String text;
  final double fontSize;
  const _TH(this.text, {this.fontSize = 9});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
        color: AppTheme.textMuted,
      ),
    ),
  );
}

class _TC extends StatelessWidget {
  final String text;
  final bool bold;
  final Color? color;
  const _TC(this.text, {this.bold = false, this.color});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 11,
        fontWeight: bold ? FontWeight.w500 : FontWeight.normal,
        color: color ?? Colors.black87,
      ),
    ),
  );
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppTheme.border, width: 0.5),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    ),
  );
}
