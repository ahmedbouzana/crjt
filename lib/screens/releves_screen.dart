import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/app_models.dart';
import '../services/hive_service.dart';
import '../theme/app_theme.dart';
import 'saisie_releve_screen.dart';

class RelevesScreen extends StatefulWidget {
  const RelevesScreen({super.key});
  @override
  State<RelevesScreen> createState() => _RelevesScreenState();
}

class _RelevesScreenState extends State<RelevesScreen> {
  List<Employe> _employes = [];
  Employe? _selected;
  int _mois = DateTime.now().month;
  int _annee = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _employes = HiveService.getAllEmployes()
      ..sort((a, b) => a.nomPrenoms.compareTo(b.nomPrenoms));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgSecondary,
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 56,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          const Text(
            'Relevés',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_employes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 56,
              color: AppTheme.textMuted.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucun employé disponible',
              style: TextStyle(fontSize: 15, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ajoutez d\'abord des employés dans la section "Employés".',
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sélecteur employé + mois
          _buildSelector(),
          const SizedBox(height: 24),
          // Liste des relevés existants pour ce mois
          Expanded(child: _buildRelevesList()),
        ],
      ),
    );
  }

  Widget _buildSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SÉLECTION',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppTheme.textMuted,
              letterSpacing: 0.5,
            ),
          ),
          const Divider(height: 16, color: AppTheme.border),
          Row(
            children: [
              // Employé
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Employé',
                      style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<Employe>(
                      value: _selected,
                      hint: const Text(
                        'Choisir un employé',
                        style: TextStyle(fontSize: 13),
                      ),
                      decoration: const InputDecoration(isDense: true),
                      items: _employes
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(
                                '${e.nomPrenoms}  —  N°${e.matricule}',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (e) => setState(() => _selected = e),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // Mois
              SizedBox(
                width: 160,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mois',
                      style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<int>(
                      value: _mois,
                      decoration: const InputDecoration(isDense: true),
                      items: List.generate(
                        12,
                        (i) => DropdownMenuItem(
                          value: i + 1,
                          child: Text(
                            _nomMois(i + 1),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                      onChanged: (v) => setState(() => _mois = v!),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // Année
              SizedBox(
                width: 110,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Année',
                      style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<int>(
                      value: _annee,
                      decoration: const InputDecoration(isDense: true),
                      items:
                          List.generate(6, (i) => DateTime.now().year - 2 + i)
                              .map(
                                (y) => DropdownMenuItem(
                                  value: y,
                                  child: Text(
                                    '$y',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (v) => setState(() => _annee = v!),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // Bouton ouvrir
              Column(
                children: [
                  const SizedBox(height: 22),
                  ElevatedButton.icon(
                    onPressed: _selected == null ? null : _ouvrirSaisie,
                    icon: const Icon(Icons.edit_note, size: 18),
                    label: const Text('Ouvrir le relevé'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRelevesList() {
    final releves = _employes.map((e) {
      final r = HiveService.getReleve(e.id, _annee, _mois);
      return (employe: e, releve: r);
    }).toList();

    final avecReleve = releves.where((r) => r.releve != null).toList();

    if (avecReleve.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 40,
              color: AppTheme.textMuted.withOpacity(0.3),
            ),
            const SizedBox(height: 12),
            Text(
              'Aucun relevé saisi pour ${_nomMois(_mois)} $_annee',
              style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${avecReleve.length} relevé${avecReleve.length > 1 ? 's' : ''} — ${_nomMois(_mois)} $_annee',
          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.separated(
            itemCount: avecReleve.length,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemBuilder: (_, i) {
              final item = avecReleve[i];
              return _ReleveCard(
                employe: item.employe,
                releve: item.releve!,
                mois: _mois,
                annee: _annee,
                onOpen: () {
                  setState(() => _selected = item.employe);
                  _ouvrirSaisie();
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _ouvrirSaisie() {
    if (_selected == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            SaisieReleveScreen(employe: _selected!, mois: _mois, annee: _annee),
      ),
    ).then((_) => setState(() {}));
  }

  String _nomMois(int m) =>
      DateFormat('MMMM', 'fr_FR').format(DateTime(2024, m)).toUpperCase();
}

// ─── Carte résumé d'un relevé ─────────────────────────────────────────────────
class _ReleveCard extends StatelessWidget {
  final Employe employe;
  final Releve releve;
  final int mois, annee;
  final VoidCallback onOpen;

  const _ReleveCard({
    required this.employe,
    required this.releve,
    required this.mois,
    required this.annee,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final nbImputations = releve.imputations.fold(
      0,
      (s, i) => s + i.plages.length,
    );
    final nbAbsences =
        releve.absencesCM.length +
        releve.absencesCP.length +
        releve.absencesCA.length +
        releve.absencesFM.length;
    final nbHS = releve.heuresSupp.length;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Text(
                employe.nomPrenoms.isNotEmpty ? employe.nomPrenoms[0] : '?',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employe.nomPrenoms,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'N°${employe.matricule}  ·  ${employe.emploi}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          // Stats
          _Stat(
            label: 'Imputations',
            value: '$nbImputations plage${nbImputations > 1 ? "s" : ""}',
          ),
          const SizedBox(width: 20),
          _Stat(
            label: 'Absences',
            value: '$nbAbsences entrée${nbAbsences > 1 ? "s" : ""}',
          ),
          const SizedBox(width: 20),
          _Stat(
            label: 'Heures supp',
            value: '$nbHS plage${nbHS > 1 ? "s" : ""}',
          ),
          const SizedBox(width: 20),
          TextButton.icon(
            onPressed: onOpen,
            icon: const Icon(Icons.open_in_new, size: 14),
            label: const Text('Ouvrir'),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value;
  const _Stat({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
      ),
      Text(
        value,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    ],
  );
}
