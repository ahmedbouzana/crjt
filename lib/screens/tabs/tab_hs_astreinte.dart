import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../models/app_models.dart';
import '../../../../theme/app_theme.dart';

class TabHsAstreinte extends StatelessWidget {
  final Releve releve;
  final AppSettings settings;
  final int mois, annee;
  final void Function(Releve) onChange;

  const TabHsAstreinte({
    super.key,
    required this.releve,
    required this.settings,
    required this.mois,
    required this.annee,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildHSSection(context),
          const SizedBox(height: 16),
          _buildAstreinteSection(context),
        ],
      ),
    );
  }

  // ── Heures supplémentaires ──────────────────────────────────────────────────
  Widget _buildHSSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppTheme.primary.withOpacity(0.2),
                      width: 0.5,
                    ),
                  ),
                  child: const Text(
                    'H.SUPP',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Heures supplémentaires',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _showHsDialog(context, null, null),
                  icon: const Icon(
                    Icons.add,
                    size: 14,
                    color: AppTheme.primary,
                  ),
                  label: const Text(
                    'Ajouter une plage',
                    style: TextStyle(fontSize: 12, color: AppTheme.primary),
                  ),
                ),
              ],
            ),
          ),

          // Info taux
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 14,
                  color: AppTheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Jour ouvrable : ${(settings.taux.jourOuvrJour * 100).toStringAsFixed(1)}% (jour)  ·  '
                    '${(settings.taux.jourOuvrNuit * 100).toStringAsFixed(1)}% (nuit)     '
                    'Jour férié : ${(settings.taux.jourFerieJour * 100).toStringAsFixed(1)}% (jour)  ·  '
                    '${(settings.taux.jourFerieNuit * 100).toStringAsFixed(1)}% (nuit)',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (releve.heuresSupp.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: const Text(
                'Aucune plage d\'heures supplémentaires.',
                style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
            )
          else
            ...releve.heuresSupp.asMap().entries.map(
              (e) => _HsRow(
                hs: e.value,
                onEdit: () => _showHsDialog(context, e.key, e.value),
                onDelete: () {
                  final list = List<HeureSupp>.from(releve.heuresSupp)
                    ..removeAt(e.key);
                  onChange(_copy(heuresSupp: list));
                },
              ),
            ),
        ],
      ),
    );
  }

  void _showHsDialog(BuildContext context, int? idx, HeureSupp? existing) {
    DateTime debut = existing?.debut ?? DateTime(annee, mois, 1, 18, 0);
    DateTime fin = existing?.fin ?? DateTime(annee, mois, 1, 21, 0);
    String localite =
        existing?.localite ??
        (settings.localites.isNotEmpty ? settings.localites.first : '');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text(
            idx == null ? 'Ajouter des heures supplémentaires' : 'Modifier',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          content: SizedBox(
            width: 460,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Plage datetime
                Row(
                  children: [
                    Expanded(
                      child: _DateTimeField(
                        label: 'Du',
                        value: debut,
                        onPick: (d) => setS(() => debut = d),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'au',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _DateTimeField(
                        label: 'Au',
                        value: fin,
                        onPick: (d) => setS(() => fin = d),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Localité
                const Text(
                  'Localité de travail',
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 4),
                settings.localites.isEmpty
                    ? const Text(
                        'Aucune localité configurée.',
                        style: TextStyle(fontSize: 12, color: AppTheme.danger),
                      )
                    : DropdownButtonFormField<String>(
                        value: settings.localites.contains(localite)
                            ? localite
                            : settings.localites.first,
                        decoration: const InputDecoration(isDense: true),
                        items: settings.localites
                            .map(
                              (l) => DropdownMenuItem(
                                value: l,
                                child: Text(
                                  l,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setS(() => localite = v!),
                      ),
                const SizedBox(height: 12),
                // Durée
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        size: 14,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Durée : ${_fmtDur(fin.difference(debut))}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                final hs = HeureSupp(
                  debut: debut,
                  fin: fin.isAfter(debut) ? fin : debut,
                  localite: localite,
                );
                final list = List<HeureSupp>.from(releve.heuresSupp);
                if (idx == null)
                  list.add(hs);
                else
                  list[idx] = hs;
                list.sort((a, b) => a.debut.compareTo(b.debut));
                onChange(_copy(heuresSupp: list));
                Navigator.pop(ctx);
              },
              child: const Text('Valider'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Astreinte ──────────────────────────────────────────────────────────────
  Widget _buildAstreinteSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppTheme.accent.withOpacity(0.3),
                      width: 0.5,
                    ),
                  ),
                  child: const Text(
                    'ASTRTE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.accent,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Indemnités d\'astreinte',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _showAstreinteDialog(context, null, null),
                  icon: const Icon(Icons.add, size: 14, color: AppTheme.accent),
                  label: const Text(
                    'Ajouter une plage',
                    style: TextStyle(fontSize: 12, color: AppTheme.accent),
                  ),
                ),
              ],
            ),
          ),

          if (releve.astreintes.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: const Text(
                'Aucune plage d\'astreinte.',
                style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
            )
          else
            ...releve.astreintes.asMap().entries.map(
              (e) => _AstreinteRow(
                plage: e.value,
                onEdit: () => _showAstreinteDialog(context, e.key, e.value),
                onDelete: () {
                  final list = List<PlageDate>.from(releve.astreintes)
                    ..removeAt(e.key);
                  onChange(_copy(astreintes: list));
                },
              ),
            ),
        ],
      ),
    );
  }

  void _showAstreinteDialog(
    BuildContext context,
    int? idx,
    PlageDate? existing,
  ) {
    DateTime debut = existing?.debut ?? DateTime(annee, mois, 1);
    DateTime fin = existing?.fin ?? DateTime(annee, mois, 1);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text(
            idx == null
                ? 'Ajouter une plage d\'astreinte'
                : 'Modifier la plage',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          content: SizedBox(
            width: 340,
            child: Row(
              children: [
                Expanded(
                  child: _DateOnlyField(
                    label: 'Du',
                    value: debut,
                    onPick: (d) => setS(() => debut = d),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'au',
                    style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                ),
                Expanded(
                  child: _DateOnlyField(
                    label: 'Au',
                    value: fin,
                    onPick: (d) => setS(() => fin = d),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                final p = PlageDate(
                  debut: debut,
                  fin: fin.isBefore(debut) ? debut : fin,
                );
                final list = List<PlageDate>.from(releve.astreintes);
                if (idx == null)
                  list.add(p);
                else
                  list[idx] = p;
                onChange(_copy(astreintes: list));
                Navigator.pop(ctx);
              },
              child: const Text('Valider'),
            ),
          ],
        ),
      ),
    );
  }

  Releve _copy({List<HeureSupp>? heuresSupp, List<PlageDate>? astreintes}) =>
      Releve(
        employeId: releve.employeId,
        mois: releve.mois,
        annee: releve.annee,
        absencesCM: List.from(releve.absencesCM),
        absencesCP: List.from(releve.absencesCP),
        absencesCA: List.from(releve.absencesCA),
        absencesFM: List.from(releve.absencesFM),
        imputations: List.from(releve.imputations),
        heuresSupp: heuresSupp ?? List.from(releve.heuresSupp),
        astreintes: astreintes ?? List.from(releve.astreintes),
      );

  String _fmtDur(Duration d) {
    if (d.isNegative) return '—';
    return '${d.inHours}h${d.inMinutes.remainder(60).toString().padLeft(2, '0')}';
  }
}

// ─── Row widgets ──────────────────────────────────────────────────────────────
class _HsRow extends StatelessWidget {
  final HeureSupp hs;
  final VoidCallback onEdit, onDelete;
  const _HsRow({
    required this.hs,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy HH:mm');
    final dur = hs.fin.difference(hs.debut);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.border, width: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${fmt.format(hs.debut)}  →  ${fmt.format(hs.fin)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.place_outlined,
                      size: 11,
                      color: AppTheme.textMuted,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      hs.localite,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.timer_outlined,
                      size: 11,
                      color: AppTheme.textMuted,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${dur.inHours}h${dur.inMinutes.remainder(60).toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              size: 15,
              color: AppTheme.primary,
            ),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              size: 15,
              color: AppTheme.danger,
            ),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _AstreinteRow extends StatelessWidget {
  final PlageDate plage;
  final VoidCallback onEdit, onDelete;
  const _AstreinteRow({
    required this.plage,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy');
    final days = plage.fin.difference(plage.debut).inDays + 1;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.border, width: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.accent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${fmt.format(plage.debut)}  →  ${fmt.format(plage.fin)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '$days jour${days > 1 ? "s" : ""} d\'astreinte',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              size: 15,
              color: AppTheme.accent,
            ),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              size: 15,
              color: AppTheme.danger,
            ),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

// ─── DateTimeField & DateOnlyField ────────────────────────────────────────────
class _DateTimeField extends StatelessWidget {
  final String label;
  final DateTime value;
  final void Function(DateTime) onPick;
  const _DateTimeField({
    required this.label,
    required this.value,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () async {
            final d = await showDatePicker(
              context: context,
              initialDate: value,
              firstDate: DateTime(2020),
              lastDate: DateTime(2040),
              locale: const Locale('fr'),
            );
            if (d != null)
              onPick(
                DateTime(d.year, d.month, d.day, value.hour, value.minute),
              );
          },
          child: _FBox(
            text: DateFormat('dd/MM/yyyy').format(value),
            icon: Icons.calendar_today_outlined,
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () async {
            final t = await showTimePicker(
              context: context,
              initialTime: TimeOfDay(hour: value.hour, minute: value.minute),
              builder: (ctx, child) => MediaQuery(
                data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
                child: child!,
              ),
            );
            if (t != null)
              onPick(
                DateTime(value.year, value.month, value.day, t.hour, t.minute),
              );
          },
          child: _FBox(
            text: DateFormat('HH:mm').format(value),
            icon: Icons.access_time,
          ),
        ),
      ],
    );
  }
}

class _DateOnlyField extends StatelessWidget {
  final String label;
  final DateTime value;
  final void Function(DateTime) onPick;
  const _DateOnlyField({
    required this.label,
    required this.value,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
      ),
      const SizedBox(height: 4),
      GestureDetector(
        onTap: () async {
          final d = await showDatePicker(
            context: context,
            initialDate: value,
            firstDate: DateTime(2020),
            lastDate: DateTime(2040),
            locale: const Locale('fr'),
          );
          if (d != null) onPick(d);
        },
        child: _FBox(
          text: DateFormat('dd/MM/yyyy').format(value),
          icon: Icons.calendar_today_outlined,
        ),
      ),
    ],
  );
}

class _FBox extends StatelessWidget {
  final String text;
  final IconData icon;
  const _FBox({required this.text, required this.icon});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      color: AppTheme.bgSecondary,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppTheme.border, width: 0.5),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ),
        Icon(icon, size: 13, color: AppTheme.textMuted),
      ],
    ),
  );
}
