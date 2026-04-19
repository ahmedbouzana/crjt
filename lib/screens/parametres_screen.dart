import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../models/app_models.dart';
import '../services/hive_service.dart';
import '../theme/app_theme.dart';

class ParametresScreen extends StatefulWidget {
  const ParametresScreen({super.key});
  @override
  State<ParametresScreen> createState() => _ParametresScreenState();
}

class _ParametresScreenState extends State<ParametresScreen> {
  late AppSettings _settings;
  bool _dirty = false;

  final _uniteCtrl = TextEditingController();
  final _serviceCtrl = TextEditingController();
  final _adresseCtrl = TextEditingController();
  final _telCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _settings = HiveService.getSettings();
    _uniteCtrl.text = _settings.unite;
    _serviceCtrl.text = _settings.service;
    _adresseCtrl.text = _settings.adresse;
    _telCtrl.text = _settings.telephone;
  }

  @override
  void dispose() {
    _uniteCtrl.dispose();
    _serviceCtrl.dispose();
    _adresseCtrl.dispose();
    _telCtrl.dispose();
    super.dispose();
  }

  void _mark() => setState(() => _dirty = true);

  Future<void> _save() async {
    _settings.unite = _uniteCtrl.text.trim();
    _settings.service = _serviceCtrl.text.trim();
    _settings.adresse = _adresseCtrl.text.trim();
    _settings.telephone = _telCtrl.text.trim();
    await HiveService.saveSettings(_settings);
    if (mounted) {
      setState(() => _dirty = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Paramètres enregistrés'),
          backgroundColor: AppTheme.accent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgSecondary,
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionEntete(),
                  const SizedBox(height: 16),
                  _sectionLocalites(),
                  const SizedBox(height: 16),
                  _sectionRamadan(),
                  const SizedBox(height: 16),
                  _sectionTaux(),
                  const SizedBox(height: 16),
                  _sectionJoursFeries(),
                  const SizedBox(height: 16),
                  _sectionMotifs(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
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
            'Paramètres',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          if (_dirty)
            ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_outlined, size: 16),
              label: const Text('Enregistrer'),
            ),
        ],
      ),
    );
  }

  // ── Section En-tête ────────────────────────────────────────────────────────
  Widget _sectionEntete() {
    return _Card(
      title: 'En-tête du document',
      child: Column(
        children: [
          // Image header
          Row(
            children: [
              _Label('Logo / Image'),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 100,
                  height: 72,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.border),
                    borderRadius: BorderRadius.circular(8),
                    color: AppTheme.bgSecondary,
                  ),
                  child: _settings.headerImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: Image.memory(
                            Uint8List.fromList(_settings.headerImage!),
                            fit: BoxFit.contain,
                          ),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              color: AppTheme.textMuted,
                              size: 22,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Cliquer pour\najouter',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppTheme.textMuted,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                ),
              ),
              if (_settings.headerImage != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _settings.headerImage = null;
                      _dirty = true;
                    });
                  },
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: AppTheme.danger,
                  ),
                  tooltip: 'Supprimer l\'image',
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          _FieldRow(
            label: 'Unité',
            ctrl: _uniteCtrl,
            onChanged: (_) => _mark(),
          ),
          _FieldRow(
            label: 'Service',
            ctrl: _serviceCtrl,
            onChanged: (_) => _mark(),
          ),
          _FieldRow(
            label: 'Adresse',
            ctrl: _adresseCtrl,
            onChanged: (_) => _mark(),
          ),
          _FieldRow(
            label: 'Téléphone',
            ctrl: _telCtrl,
            onChanged: (_) => _mark(),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null) {
      final bytes = await File(result.files.single.path!).readAsBytes();
      setState(() {
        _settings.headerImage = bytes.toList();
        _dirty = true;
      });
    }
  }

  // ── Section Localités ─────────────────────────────────────────────────────
  Widget _sectionLocalites() {
    return _Card(
      title: 'Localités',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ..._settings.localites.asMap().entries.map(
                (e) => _LocaliteTag(
                  label: e.value,
                  onDelete: () => setState(() {
                    _settings.localites.removeAt(e.key);
                    _dirty = true;
                  }),
                ),
              ),
              _AddChip(label: '+ Ajouter', onTap: _addLocalite),
            ],
          ),
        ],
      ),
    );
  }

  void _addLocalite() {
    _showTextDialog(
      title: 'Nouvelle localité',
      hint: 'Ex: AIN DEFLA',
      onConfirm: (v) {
        if (v.isNotEmpty) {
          setState(() {
            _settings.localites.add(v.toUpperCase());
            _dirty = true;
          });
        }
      },
    );
  }

  // ── Section Ramadan ───────────────────────────────────────────────────────
  Widget _sectionRamadan() {
    final fmt = DateFormat('dd/MM/yyyy');
    return _Card(
      title: 'Mois du Ramadhan',
      child: Column(
        children: [
          Row(
            children: [
              _Label('Période'),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _DateField(
                        value: _settings.ramadanDebut,
                        hint: 'Début',
                        onPick: (d) => setState(() {
                          _settings.ramadanDebut = d;
                          _dirty = true;
                        }),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'au',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _DateField(
                        value: _settings.ramadanFin,
                        hint: 'Fin',
                        onPick: (d) => setState(() {
                          _settings.ramadanFin = d;
                          _dirty = true;
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _Label('Heures Ramadhan'),
              _NumberField(
                value: _settings.heuresRamadan,
                onChanged: (v) => setState(() {
                  _settings.heuresRamadan = v;
                  _dirty = true;
                }),
              ),
              const SizedBox(width: 6),
              const Text(
                'h / jour',
                style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _Label('Heures normales'),
              _NumberField(
                value: _settings.heuresNormales,
                onChanged: (v) => setState(() {
                  _settings.heuresNormales = v;
                  _dirty = true;
                }),
              ),
              const SizedBox(width: 6),
              const Text(
                'h / jour',
                style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Section Taux HS ───────────────────────────────────────────────────────
  Widget _sectionTaux() {
    return _Card(
      title: 'Taux des heures supplémentaires',
      trailing: IconButton(
        icon: const Icon(
          Icons.edit_outlined,
          size: 18,
          color: AppTheme.primary,
        ),
        tooltip: 'Modifier les taux',
        onPressed: _editTaux,
      ),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.8,
        children: [
          _TauxCard(
            label: 'Jour ouvrable — journée',
            pct: _settings.taux.jourOuvrJour,
            sub: '05h00 → 21h00',
          ),
          _TauxCard(
            label: 'Jour ouvrable — nuit',
            pct: _settings.taux.jourOuvrNuit,
            sub: '21h00 → 05h00',
          ),
          _TauxCard(
            label: 'Jour férié — journée',
            pct: _settings.taux.jourFerieJour,
            sub: '05h00 → 21h00',
          ),
          _TauxCard(
            label: 'Jour férié — nuit',
            pct: _settings.taux.jourFerieNuit,
            sub: '21h00 → 05h00',
          ),
        ],
      ),
    );
  }

  void _editTaux() {
    final t = _settings.taux;
    final c1 = TextEditingController(text: t.jourOuvrJour.toString());
    final c2 = TextEditingController(text: t.jourOuvrNuit.toString());
    final c3 = TextEditingController(text: t.jourFerieJour.toString());
    final c4 = TextEditingController(text: t.jourFerieNuit.toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          'Modifier les taux HS',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        content: SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DialogField(label: 'Jour ouvrable 05h–21h (×)', ctrl: c1),
              _DialogField(label: 'Jour ouvrable 21h–05h (×)', ctrl: c2),
              _DialogField(label: 'Jour férié 05h–21h (×)', ctrl: c3),
              _DialogField(label: 'Jour férié 21h–05h (×)', ctrl: c4),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _settings.taux = TauxHS(
                  jourOuvrJour: double.tryParse(c1.text) ?? t.jourOuvrJour,
                  jourOuvrNuit: double.tryParse(c2.text) ?? t.jourOuvrNuit,
                  jourFerieJour: double.tryParse(c3.text) ?? t.jourFerieJour,
                  jourFerieNuit: double.tryParse(c4.text) ?? t.jourFerieNuit,
                );
                _dirty = true;
              });
              Navigator.pop(context);
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  // ── Section Jours Fériés ──────────────────────────────────────────────────
  Widget _sectionJoursFeries() {
    final fmt = DateFormat('dd/MM/yyyy');
    return _Card(
      title: 'Jours fériés',
      trailing: IconButton(
        icon: const Icon(Icons.add, size: 18, color: AppTheme.primary),
        tooltip: 'Ajouter',
        onPressed: () => _editJourFerie(null),
      ),
      child: _settings.joursFeries.isEmpty
          ? const Text(
              'Aucun jour férié configuré.',
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
            )
          : Column(
              children: _settings.joursFeries.asMap().entries.map((e) {
                final jf = e.value;
                final isSingleDay =
                    jf.dateDebut.year == jf.dateFin.year &&
                    jf.dateDebut.month == jf.dateFin.month &&
                    jf.dateDebut.day == jf.dateFin.day;
                final dateStr = isSingleDay
                    ? fmt.format(jf.dateDebut)
                    : '${fmt.format(jf.dateDebut)} → ${fmt.format(jf.dateFin)}';
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppTheme.border.withOpacity(0.5),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              jf.description,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              dateStr,
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
                        onPressed: () => _editJourFerie(e.key),
                        tooltip: 'Modifier',
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          size: 16,
                          color: AppTheme.danger,
                        ),
                        onPressed: () => setState(() {
                          _settings.joursFeries.removeAt(e.key);
                          _dirty = true;
                        }),
                        tooltip: 'Supprimer',
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  void _editJourFerie(int? index) {
    final existing = index != null ? _settings.joursFeries[index] : null;
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    DateTime? debut = existing?.dateDebut;
    DateTime? fin = existing?.dateFin;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text(
            index == null ? 'Ajouter un jour férié' : 'Modifier le jour férié',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          content: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Description (ex: Aïd El Fitre)',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _DateFieldInline(
                        label: 'Du',
                        value: debut,
                        onPick: (d) => setS(() => debut = d),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DateFieldInline(
                        label: 'Au',
                        value: fin,
                        onPick: (d) => setS(() => fin = d),
                      ),
                    ),
                  ],
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
                if (descCtrl.text.trim().isEmpty ||
                    debut == null ||
                    fin == null)
                  return;
                final jf = JourFerie(
                  description: descCtrl.text.trim(),
                  dateDebut: debut!,
                  dateFin: fin!.isBefore(debut!) ? debut! : fin!,
                );
                setState(() {
                  if (index == null) {
                    _settings.joursFeries.add(jf);
                  } else {
                    _settings.joursFeries[index] = jf;
                  }
                  _settings.joursFeries.sort(
                    (a, b) => a.dateDebut.compareTo(b.dateDebut),
                  );
                  _dirty = true;
                });
                Navigator.pop(ctx);
              },
              child: const Text('Valider'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section Codes Motifs ──────────────────────────────────────────────────
  Widget _sectionMotifs() {
    return _Card(
      title: 'Codes motifs d\'absence',
      trailing: IconButton(
        icon: const Icon(
          Icons.edit_outlined,
          size: 18,
          color: AppTheme.primary,
        ),
        tooltip: 'Modifier',
        onPressed: _editMotifs,
      ),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 2.5,
        children: _settings.codesMotifs
            .map(
              (m) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.bgSecondary,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.border, width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      m.code,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      m.libelle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textMuted,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  void _editMotifs() {
    final motifs = List<CodeMotif>.from(_settings.codesMotifs);
    final controllers = motifs
        .map(
          (m) => (
            code: TextEditingController(text: m.code),
            libelle: TextEditingController(text: m.libelle),
          ),
        )
        .toList();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          'Modifier les codes motifs',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: controllers
                  .map(
                    (c) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 70,
                            child: TextField(
                              controller: c.code,
                              decoration: const InputDecoration(
                                labelText: 'Code',
                              ),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: c.libelle,
                              decoration: const InputDecoration(
                                labelText: 'Libellé',
                              ),
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _settings.codesMotifs = controllers
                    .map(
                      (c) => CodeMotif(
                        code: c.code.text.trim().toUpperCase(),
                        libelle: c.libelle.text.trim(),
                      ),
                    )
                    .where((m) => m.code.isNotEmpty)
                    .toList();
                _dirty = true;
              });
              Navigator.pop(context);
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  // ── Helper dialog ─────────────────────────────────────────────────────────
  void _showTextDialog({
    required String title,
    required String hint,
    required void Function(String) onConfirm,
  }) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(hintText: hint),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              onConfirm(ctrl.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }
}

// ─── Widgets helpers ──────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;
  const _Card({required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppTheme.border, width: 0.5),
    ),
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
        const Divider(height: 16, color: AppTheme.border),
        child,
      ],
    ),
  );
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 140,
    child: Text(
      text,
      style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
    ),
  );
}

class _FieldRow extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final void Function(String) onChanged;
  const _FieldRow({
    required this.label,
    required this.ctrl,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        _Label(label),
        Expanded(
          child: TextField(
            controller: ctrl,
            onChanged: onChanged,
            style: const TextStyle(fontSize: 13),
            decoration: const InputDecoration(isDense: true),
          ),
        ),
      ],
    ),
  );
}

class _DateField extends StatelessWidget {
  final DateTime? value;
  final String hint;
  final void Function(DateTime) onPick;
  const _DateField({this.value, required this.hint, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy');
    return GestureDetector(
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
                value != null ? fmt.format(value!) : hint,
                style: TextStyle(
                  fontSize: 12,
                  color: value != null ? Colors.black87 : AppTheme.textMuted,
                ),
              ),
            ),
            const Icon(
              Icons.calendar_today_outlined,
              size: 14,
              color: AppTheme.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _DateFieldInline extends StatelessWidget {
  final String label;
  final DateTime? value;
  final void Function(DateTime) onPick;
  const _DateFieldInline({
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

class _NumberField extends StatelessWidget {
  final int value;
  final void Function(int) onChanged;
  const _NumberField({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final ctrl = TextEditingController(text: value.toString());
    return SizedBox(
      width: 60,
      child: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 13),
        decoration: const InputDecoration(isDense: true),
        onChanged: (v) {
          final n = int.tryParse(v);
          if (n != null) onChanged(n);
        },
      ),
    );
  }
}

class _TauxCard extends StatelessWidget {
  final String label, sub;
  final double pct;
  const _TauxCard({required this.label, required this.pct, required this.sub});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: AppTheme.bgSecondary,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppTheme.border, width: 0.5),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
          maxLines: 2,
        ),
        const SizedBox(height: 3),
        Text(
          '${(pct * 100).toStringAsFixed(1)} %',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppTheme.primary,
          ),
        ),
        Text(
          sub,
          style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
        ),
      ],
    ),
  );
}

class _LocaliteTag extends StatelessWidget {
  final String label;
  final VoidCallback onDelete;
  const _LocaliteTag({required this.label, required this.onDelete});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: AppTheme.primaryLight,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: AppTheme.primary.withOpacity(0.3), width: 0.5),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: onDelete,
          child: const Icon(Icons.close, size: 13, color: AppTheme.primary),
        ),
      ],
    ),
  );
}

class _AddChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _AddChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppTheme.primary.withOpacity(0.4),
          width: 0.5,
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, color: AppTheme.primary),
      ),
    ),
  );
}

class _DialogField extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  const _DialogField({required this.label, required this.ctrl});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label),
      style: const TextStyle(fontSize: 13),
    ),
  );
}
