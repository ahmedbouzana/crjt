import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../models/app_models.dart';
import '../../../../theme/app_theme.dart';

class TabImputations extends StatelessWidget {
  final Releve releve;
  final AppSettings settings;
  final int mois, annee;
  final void Function(Releve) onChange;

  const TabImputations({
    super.key,
    required this.releve,
    required this.settings,
    required this.mois,
    required this.annee,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final imputations = releve.imputations;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header + bouton ajouter
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Imputations par localité',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Définissez les plages horaires travaillées dans chaque localité.',
                      style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _addImputation(context),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Ajouter une localité'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (imputations.isEmpty)
            _buildEmpty()
          else
            ...imputations.asMap().entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ImputationCard(
                  imputation: e.value,
                  index: e.key,
                  localites: settings.localites,
                  mois: mois,
                  annee: annee,
                  onChanged: (imp) {
                    final list = List<Imputation>.from(imputations)
                      ..[e.key] = imp;
                    onChange(_copyWith(imputations: list));
                  },
                  onDelete: () {
                    final list = List<Imputation>.from(imputations)
                      ..removeAt(e.key);
                    onChange(_copyWith(imputations: list));
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmpty() => Container(
    padding: const EdgeInsets.all(32),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppTheme.border, width: 0.5),
    ),
    child: const Center(
      child: Column(
        children: [
          Icon(Icons.place_outlined, size: 40, color: AppTheme.textMuted),
          SizedBox(height: 8),
          Text(
            'Aucune imputation saisie',
            style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
          ),
          SizedBox(height: 4),
          Text(
            'Cliquez sur "Ajouter une localité" pour commencer.',
            style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
          ),
        ],
      ),
    ),
  );

  void _addImputation(BuildContext context) {
    if (settings.localites.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Configurez d\'abord les localités dans les Paramètres.',
          ),
        ),
      );
      return;
    }
    final imp = Imputation(localite: settings.localites.first, plages: []);
    final list = List<Imputation>.from(releve.imputations)..add(imp);
    onChange(_copyWith(imputations: list));
  }

  Releve _copyWith({List<Imputation>? imputations}) => Releve(
    employeId: releve.employeId,
    mois: releve.mois,
    annee: releve.annee,
    absencesCM: List.from(releve.absencesCM),
    absencesCP: List.from(releve.absencesCP),
    absencesCA: List.from(releve.absencesCA),
    absencesFM: List.from(releve.absencesFM),
    imputations: imputations ?? List.from(releve.imputations),
    heuresSupp: List.from(releve.heuresSupp),
    astreintes: List.from(releve.astreintes),
  );
}

// ─── Carte d'une imputation (une localité) ────────────────────────────────────
class _ImputationCard extends StatelessWidget {
  final Imputation imputation;
  final int index;
  final List<String> localites;
  final int mois, annee;
  final void Function(Imputation) onChanged;
  final VoidCallback onDelete;

  const _ImputationCard({
    required this.imputation,
    required this.index,
    required this.localites,
    required this.mois,
    required this.annee,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      AppTheme.primary,
      AppTheme.accent,
      const Color(0xFFBA7517),
      const Color(0xFFE24B4A),
      const Color(0xFF534AB7),
    ];
    final color = colors[index % colors.length];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Column(
        children: [
          // Header localité
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Localité :',
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String>(
                    value: localites.contains(imputation.localite)
                        ? imputation.localite
                        : localites.first,
                    isDense: true,
                    underline: const SizedBox(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    items: localites
                        .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null)
                        onChanged(
                          Imputation(localite: v, plages: imputation.plages),
                        );
                    },
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _addPlage(context),
                  icon: Icon(Icons.add, size: 14, color: color),
                  label: Text(
                    '+ Plage horaire',
                    style: TextStyle(fontSize: 12, color: color),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 16,
                    color: AppTheme.danger,
                  ),
                  onPressed: onDelete,
                  tooltip: 'Supprimer cette localité',
                ),
              ],
            ),
          ),

          // Liste des plages
          if (imputation.plages.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                'Aucune plage horaire.  Cliquez sur "+ Plage horaire" pour ajouter.',
                style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
              ),
            )
          else
            ...imputation.plages.asMap().entries.map(
              (e) => _PlageDtRow(
                plage: e.value,
                color: color,
                onEdit: () => _editPlage(context, e.key, e.value),
                onDelete: () {
                  final pl = List<PlageDatetime>.from(imputation.plages)
                    ..removeAt(e.key);
                  onChanged(
                    Imputation(localite: imputation.localite, plages: pl),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _addPlage(BuildContext context) => _showPlageDialog(context, null, null);
  void _editPlage(BuildContext context, int idx, PlageDatetime existing) =>
      _showPlageDialog(context, idx, existing);

  void _showPlageDialog(
    BuildContext context,
    int? idx,
    PlageDatetime? existing,
  ) {
    final now = DateTime.now();
    DateTime debut = existing?.debut ?? DateTime(annee, mois, 1, 8, 0);
    DateTime fin = existing?.fin ?? DateTime(annee, mois, 1, 16, 0);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text(
            idx == null
                ? 'Ajouter une plage — ${imputation.localite}'
                : 'Modifier la plage — ${imputation.localite}',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                const SizedBox(height: 12),
                // Durée calculée
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
                        'Durée : ${_formatDuree(fin.difference(debut))}',
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
                final p = PlageDatetime(
                  debut: debut,
                  fin: fin.isAfter(debut) ? fin : debut,
                );
                final pl = List<PlageDatetime>.from(imputation.plages);
                if (idx == null)
                  pl.add(p);
                else
                  pl[idx] = p;
                pl.sort((a, b) => a.debut.compareTo(b.debut));
                onChanged(
                  Imputation(localite: imputation.localite, plages: pl),
                );
                Navigator.pop(ctx);
              },
              child: const Text('Valider'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuree(Duration d) {
    if (d.isNegative) return '—';
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    return '${h}h${m.toString().padLeft(2, '0')}';
  }
}

class _PlageDtRow extends StatelessWidget {
  final PlageDatetime plage;
  final Color color;
  final VoidCallback onEdit, onDelete;
  const _PlageDtRow({
    required this.plage,
    required this.color,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy HH:mm');
    final dur = plage.fin.difference(plage.debut);
    final hStr =
        '${dur.inHours}h${dur.inMinutes.remainder(60).toString().padLeft(2, '0')}';

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
                  '${fmt.format(plage.debut)}  →  ${fmt.format(plage.fin)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Durée : $hStr',
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

// ─── DateTimePicker field ─────────────────────────────────────────────────────
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
    final fmtDate = DateFormat('dd/MM/yyyy');
    final fmtTime = DateFormat('HH:mm');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
        ),
        const SizedBox(height: 4),
        // Date
        GestureDetector(
          onTap: () async {
            final d = await showDatePicker(
              context: context,
              initialDate: value,
              firstDate: DateTime(2020),
              lastDate: DateTime(2040),
              locale: const Locale('fr'),
            );
            if (d != null) {
              onPick(
                DateTime(d.year, d.month, d.day, value.hour, value.minute),
              );
            }
          },
          child: _FieldBox(
            text: fmtDate.format(value),
            icon: Icons.calendar_today_outlined,
          ),
        ),
        const SizedBox(height: 4),
        // Heure
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
            if (t != null) {
              onPick(
                DateTime(value.year, value.month, value.day, t.hour, t.minute),
              );
            }
          },
          child: _FieldBox(
            text: fmtTime.format(value),
            icon: Icons.access_time,
          ),
        ),
      ],
    );
  }
}

class _FieldBox extends StatelessWidget {
  final String text;
  final IconData icon;
  const _FieldBox({required this.text, required this.icon});

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
