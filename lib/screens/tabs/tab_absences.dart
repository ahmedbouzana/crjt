import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../models/app_models.dart';
import '../../../../theme/app_theme.dart';

class TabAbsences extends StatelessWidget {
  final Releve releve;
  final AppSettings settings;
  final int mois, annee;
  final void Function(Releve) onChange;

  const TabAbsences({
    super.key,
    required this.releve,
    required this.settings,
    required this.mois,
    required this.annee,
    required this.onChange,
  });

  Releve get _r => releve;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AbsenceSection(
            code: 'CM',
            libelle: 'Congé Maladie',
            color: const Color(0xFFE24B4A),
            plages: _r.absencesCM,
            mois: mois,
            annee: annee,
            onAdd: (p) {
              final l = List<PlageDate>.from(_r.absencesCM)..add(p);
              onChange(_copy(cm: l));
            },
            onDelete: (i) {
              final l = List<PlageDate>.from(_r.absencesCM)..removeAt(i);
              onChange(_copy(cm: l));
            },
            onEdit: (i, p) {
              final l = List<PlageDate>.from(_r.absencesCM)..[i] = p;
              onChange(_copy(cm: l));
            },
          ),
          const SizedBox(height: 16),
          _AbsenceSection(
            code: 'CP',
            libelle: 'Congé Payé',
            color: const Color(0xFF1D9E75),
            plages: _r.absencesCP,
            mois: mois,
            annee: annee,
            onAdd: (p) {
              final l = List<PlageDate>.from(_r.absencesCP)..add(p);
              onChange(_copy(cp: l));
            },
            onDelete: (i) {
              final l = List<PlageDate>.from(_r.absencesCP)..removeAt(i);
              onChange(_copy(cp: l));
            },
            onEdit: (i, p) {
              final l = List<PlageDate>.from(_r.absencesCP)..[i] = p;
              onChange(_copy(cp: l));
            },
          ),
          const SizedBox(height: 16),
          _AbsenceSection(
            code: 'CA',
            libelle: 'Congé Annuel',
            color: const Color(0xFF378ADD),
            plages: _r.absencesCA,
            mois: mois,
            annee: annee,
            onAdd: (p) {
              final l = List<PlageDate>.from(_r.absencesCA)..add(p);
              onChange(_copy(ca: l));
            },
            onDelete: (i) {
              final l = List<PlageDate>.from(_r.absencesCA)..removeAt(i);
              onChange(_copy(ca: l));
            },
            onEdit: (i, p) {
              final l = List<PlageDate>.from(_r.absencesCA)..[i] = p;
              onChange(_copy(ca: l));
            },
          ),
          const SizedBox(height: 16),
          _AbsenceSection(
            code: 'FM',
            libelle: 'Formation',
            color: const Color(0xFFBA7517),
            plages: _r.absencesFM,
            mois: mois,
            annee: annee,
            onAdd: (p) {
              final l = List<PlageDate>.from(_r.absencesFM)..add(p);
              onChange(_copy(fm: l));
            },
            onDelete: (i) {
              final l = List<PlageDate>.from(_r.absencesFM)..removeAt(i);
              onChange(_copy(fm: l));
            },
            onEdit: (i, p) {
              final l = List<PlageDate>.from(_r.absencesFM)..[i] = p;
              onChange(_copy(fm: l));
            },
          ),
        ],
      ),
    );
  }

  Releve _copy({
    List<PlageDate>? cm,
    List<PlageDate>? cp,
    List<PlageDate>? ca,
    List<PlageDate>? fm,
  }) => Releve(
    employeId: _r.employeId,
    mois: _r.mois,
    annee: _r.annee,
    absencesCM: cm ?? List.from(_r.absencesCM),
    absencesCP: cp ?? List.from(_r.absencesCP),
    absencesCA: ca ?? List.from(_r.absencesCA),
    absencesFM: fm ?? List.from(_r.absencesFM),
    imputations: List.from(_r.imputations),
    heuresSupp: List.from(_r.heuresSupp),
    astreintes: List.from(_r.astreintes),
  );
}

// ─── Section par type d'absence ───────────────────────────────────────────────
class _AbsenceSection extends StatelessWidget {
  final String code, libelle;
  final Color color;
  final List<PlageDate> plages;
  final int mois, annee;
  final void Function(PlageDate) onAdd;
  final void Function(int) onDelete;
  final void Function(int, PlageDate) onEdit;

  const _AbsenceSection({
    required this.code,
    required this.libelle,
    required this.color,
    required this.plages,
    required this.mois,
    required this.annee,
    required this.onAdd,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Column(
        children: [
          // Header
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
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: color.withOpacity(0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    code,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  libelle,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _showPlageDialog(context, null, null),
                  icon: Icon(Icons.add, size: 15, color: color),
                  label: Text(
                    'Ajouter une plage',
                    style: TextStyle(fontSize: 12, color: color),
                  ),
                ),
              ],
            ),
          ),
          if (plages.isNotEmpty) ...[
            const Divider(height: 1, color: AppTheme.border),
            ...plages.asMap().entries.map(
              (e) => _PlageRow(
                plage: e.value,
                color: color,
                onEdit: () => _showPlageDialog(context, e.key, e.value),
                onDelete: () => onDelete(e.key),
              ),
            ),
          ] else
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                'Aucune plage de $code saisie.',
                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
            ),
        ],
      ),
    );
  }

  void _showPlageDialog(BuildContext context, int? index, PlageDate? existing) {
    DateTime? debut = existing?.debut ?? DateTime(annee, mois, 1);
    DateTime? fin = existing?.fin ?? DateTime(annee, mois, 1);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text(
            index == null
                ? 'Ajouter une plage $code'
                : 'Modifier la plage $code',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          content: SizedBox(
            width: 340,
            child: Row(
              children: [
                Expanded(
                  child: _DatePickerField(
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
                  child: _DatePickerField(
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
                if (debut == null || fin == null) return;
                final p = PlageDate(
                  debut: debut!,
                  fin: fin!.isBefore(debut!) ? debut! : fin!,
                );
                if (index == null)
                  onAdd(p);
                else
                  onEdit(index, p);
                Navigator.pop(ctx);
              },
              child: const Text('Valider'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlageRow extends StatelessWidget {
  final PlageDate plage;
  final Color color;
  final VoidCallback onEdit, onDelete;
  const _PlageRow({
    required this.plage,
    required this.color,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy');
    final isSame =
        plage.debut.year == plage.fin.year &&
        plage.debut.month == plage.fin.month &&
        plage.debut.day == plage.fin.day;
    final nbJours = plage.fin.difference(plage.debut).inDays + 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.border, width: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSame
                      ? fmt.format(plage.debut)
                      : '${fmt.format(plage.debut)}  →  ${fmt.format(plage.fin)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (!isSame)
                  Text(
                    '$nbJours jour${nbJours > 1 ? "s" : ""}',
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
              size: 16,
              color: AppTheme.primary,
            ),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              size: 16,
              color: AppTheme.danger,
            ),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final void Function(DateTime) onPick;
  const _DatePickerField({
    required this.label,
    this.value,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy');
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
              initialDate: value ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2040),
              locale: const Locale('fr'),
            );
            if (d != null) onPick(d);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.bgSecondary,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.border, width: 0.5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value != null ? fmt.format(value!) : 'JJ/MM/AAAA',
                    style: TextStyle(
                      fontSize: 12,
                      color: value != null
                          ? Colors.black87
                          : AppTheme.textMuted,
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 13,
                  color: AppTheme.textMuted,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
