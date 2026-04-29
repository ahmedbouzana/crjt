import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/app_models.dart';
import '../../theme/app_theme.dart';

class AbsenceType {
  final String code;
  final String libelle;
  final Color color;

  const AbsenceType({
    required this.code,
    required this.libelle,
    required this.color,
  });
}

class AbsenceCategory {
  final String title;
  final List<AbsenceType> types;

  const AbsenceCategory({required this.title, required this.types});
}

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

  static final List<AbsenceCategory> _categories = [
    AbsenceCategory(
      title: '🟢 Congés légaux',
      types: [
        AbsenceType(
          code: 'CA',
          libelle: 'Congé annuel',
          color: const Color(0xFF378ADD),
        ),
        AbsenceType(
          code: 'CR',
          libelle: 'Congé récupération',
          color: const Color(0xFF1D9E75),
        ),
        AbsenceType(
          code: 'CS',
          libelle: 'Congé sans solde',
          color: const Color(0xFF8E44AD),
        ),
        AbsenceType(
          code: 'CEX',
          libelle: 'Congé exceptionnel',
          color: const Color(0xFF9B59B6),
        ),
        AbsenceType(
          code: 'CQ',
          libelle: 'Congé de quarantaine',
          color: const Color(0xFF16A085),
        ),
      ],
    ),
    AbsenceCategory(
      title: '🔵 Maladie & santé',
      types: [
        AbsenceType(
          code: 'CM',
          libelle: 'Congé maladie',
          color: const Color(0xFFE24B4A),
        ),
        AbsenceType(
          code: 'CML',
          libelle: 'Congé maladie longue durée',
          color: const Color(0xFFC0392B),
        ),
        AbsenceType(
          code: 'AT',
          libelle: 'Accident de travail',
          color: const Color(0xFFE67E22),
        ),
        AbsenceType(
          code: 'MP',
          libelle: 'Maladie professionnelle',
          color: const Color(0xFFD35400),
        ),
        AbsenceType(
          code: 'REPOS',
          libelle: 'Repos médical',
          color: const Color(0xFF27AE60),
        ),
      ],
    ),
    AbsenceCategory(
      title: '🟣 Événements familiaux',
      types: [
        AbsenceType(
          code: 'CMAT',
          libelle: 'Congé maternité',
          color: const Color(0xFF2980B9),
        ),
        AbsenceType(
          code: 'CPAT',
          libelle: 'Congé paternité',
          color: const Color(0xFF3498DB),
        ),
        AbsenceType(
          code: 'CNA',
          libelle: 'Congé naissance',
          color: const Color(0xFF1ABC9C),
        ),
        AbsenceType(
          code: 'CMAR',
          libelle: 'Congé mariage',
          color: const Color(0xFF9B59B6),
        ),
        AbsenceType(
          code: 'CD',
          libelle: 'Congé décès',
          color: const Color(0xFF2C3E50),
        ),
      ],
    ),
    AbsenceCategory(
      title: '🟠 Autorisations & administratif',
      types: [
        AbsenceType(
          code: 'AUT',
          libelle: 'Autorisation d’absence',
          color: const Color(0xFF7F8C8D),
        ),
        AbsenceType(
          code: 'ABSJ',
          libelle: 'Absence justifiée',
          color: const Color(0xFF95A5A6),
        ),
        AbsenceType(
          code: 'ABNJ',
          libelle: 'Absence non justifiée',
          color: const Color(0xFFE74C3C),
        ),
        AbsenceType(
          code: 'CONV',
          libelle: 'Convocation officielle',
          color: const Color(0xFF34495E),
        ),
        AbsenceType(
          code: 'VIS',
          libelle: 'Visite médicale',
          color: const Color(0xFF16A085),
        ),
      ],
    ),
    AbsenceCategory(
      title: '🟡 Activité professionnelle',
      types: [
        AbsenceType(
          code: 'MIS',
          libelle: 'Mission',
          color: const Color(0xFF2980B9),
        ),
        AbsenceType(
          code: 'FOR',
          libelle: 'Formation',
          color: const Color(0xFFBA7517),
        ),
        AbsenceType(
          code: 'STG',
          libelle: 'Stage',
          color: const Color(0xFF8E44AD),
        ),
        AbsenceType(
          code: 'DET',
          libelle: 'Détachement',
          color: const Color(0xFF2C3E50),
        ),
      ],
    ),
    AbsenceCategory(
      title: '🔴 Situations particulières',
      types: [
        AbsenceType(
          code: 'DISP',
          libelle: 'Disponibilité',
          color: const Color(0xFF7F8C8D),
        ),
        AbsenceType(
          code: 'SUSP',
          libelle: 'Suspension',
          color: const Color(0xFFE74C3C),
        ),
        AbsenceType(
          code: 'GRE',
          libelle: 'Grève',
          color: const Color(0xFF2C3E50),
        ),
      ],
    ),
  ];

  List<PlageDate> _getPlages(String code) {
    return releve.absences.where((p) => p.motif == code).toList();
  }

  void _updatePlages(String code, List<PlageDate> newPlages) {
    final other = releve.absences.where((p) => p.motif != code).toList();
    final updated = [...other, ...newPlages];
    onChange(releve.copyWith(absences: updated));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _categories.expand((category) {
          return [
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 16, bottom: 8),
              child: Text(
                category.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ...category.types.map((type) {
              final plages = _getPlages(type.code);
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _AbsenceSection(
                  type: type,
                  plages: plages,
                  mois: mois,
                  annee: annee,
                  onChange: (newPlages) => _updatePlages(type.code, newPlages),
                ),
              );
            }),
          ];
        }).toList(),
      ),
    );
  }
}

// ==================== SECTION ABSENCE ====================

class _AbsenceSection extends StatelessWidget {
  final AbsenceType type;
  final List<PlageDate> plages;
  final int mois, annee;
  final void Function(List<PlageDate>) onChange;

  const _AbsenceSection({
    super.key,
    required this.type,
    required this.plages,
    required this.mois,
    required this.annee,
    required this.onChange,
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
                    color: type.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: type.color.withOpacity(0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    type.code,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: type.color,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    type.libelle,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showPlageDialog(context, null, null),
                  icon: Icon(Icons.add, size: 16, color: type.color),
                  label: const Text('Ajouter', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),

          if (plages.isNotEmpty)
            const Divider(height: 1, color: AppTheme.border),

          if (plages.isNotEmpty)
            ...plages.asMap().entries.map(
              (e) => _PlageRow(
                plage: e.value,
                color: type.color,
                onEdit: () => _showPlageDialog(context, e.key, e.value),
                onDelete: () => _deletePlage(e.key),
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Text(
                'Aucune plage saisie.',
                style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
            ),
        ],
      ),
    );
  }

  void _deletePlage(int index) {
    final updated = List<PlageDate>.from(plages)..removeAt(index);
    onChange(updated);
  }

  void _showPlageDialog(BuildContext context, int? index, PlageDate? existing) {
    DateTime? debut = existing?.debut ?? DateTime(annee, mois, 1);
    DateTime? fin = existing?.fin ?? DateTime(annee, mois, 1);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(
            index == null
                ? 'Ajouter une plage ${type.code}'
                : 'Modifier la plage ${type.code}',
          ),
          content: SizedBox(
            width: 360,
            child: Row(
              children: [
                Expanded(
                  child: _DatePickerField(
                    label: 'Du',
                    value: debut,
                    onPick: (d) => setState(() => debut = d),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('au'),
                ),
                Expanded(
                  child: _DatePickerField(
                    label: 'Au',
                    value: fin,
                    onPick: (d) => setState(() => fin = d),
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
                if (fin!.isBefore(debut!)) fin = debut;

                final newPlage = PlageDate(
                  debut: debut!,
                  fin: fin!,
                  motif: type.code, // ← Important
                );

                final newList = List<PlageDate>.from(plages);
                index == null
                    ? newList.add(newPlage)
                    : newList[index] = newPlage;

                onChange(newList);
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
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PlageRow({
    super.key,
    required this.plage,
    required this.color,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy');
    final isSameDay =
        plage.debut.year == plage.fin.year &&
        plage.debut.month == plage.fin.month &&
        plage.debut.day == plage.fin.day;
    final nbJours = plage.fin.difference(plage.debut).inDays + 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.border, width: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSameDay
                      ? fmt.format(plage.debut)
                      : '${fmt.format(plage.debut)} → ${fmt.format(plage.fin)}',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (!isSameDay)
                  Text(
                    '$nbJours jour${nbJours > 1 ? "s" : ""}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppTheme.textMuted,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18),
            color: AppTheme.primary,
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18),
            color: AppTheme.danger,
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
    super.key,
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
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: value ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2040),
              locale: const Locale('fr', 'FR'),
            );
            if (picked != null) onPick(picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                      fontSize: 13,
                      color: value != null
                          ? Colors.black87
                          : AppTheme.textMuted,
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
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
