import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/app_models.dart';
import '../services/hive_service.dart';
import '../theme/app_theme.dart';

class EmployesScreen extends StatefulWidget {
  const EmployesScreen({super.key});
  @override State<EmployesScreen> createState() => _EmployesScreenState();
}

class _EmployesScreenState extends State<EmployesScreen> {
  List<Employe> _employes = [];
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _employes = HiveService.getAllEmployes()
        ..sort((a, b) => a.nomPrenoms.compareTo(b.nomPrenoms));
    });
  }

  List<Employe> get _filtered {
    if (_search.isEmpty) return _employes;
    final q = _search.toLowerCase();
    return _employes.where((e) =>
      e.nomPrenoms.toLowerCase().contains(q) ||
      e.matricule.toLowerCase().contains(q) ||
      e.codeService.toLowerCase().contains(q) ||
      e.emploi.toLowerCase().contains(q),
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgSecondary,
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: _filtered.isEmpty
                ? _buildEmpty()
                : _buildList(),
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
          const Text('Employés', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(width: 24),
          // Search bar
          Expanded(
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'Rechercher par nom, matricule, service...',
                prefixIcon: const Icon(Icons.search, size: 16, color: AppTheme.textMuted),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                constraints: const BoxConstraints(maxWidth: 400),
              ),
              style: const TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: () => _openForm(null),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Nouvel employé'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_outline, size: 56, color: AppTheme.textMuted.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            _search.isEmpty ? 'Aucun employé enregistré' : 'Aucun résultat pour "$_search"',
            style: const TextStyle(fontSize: 15, color: AppTheme.textMuted),
          ),
          if (_search.isEmpty) ...[
            const SizedBox(height: 8),
            const Text('Cliquez sur "Nouvel employé" pour commencer.',
                style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
          ],
        ],
      ),
    );
  }

  Widget _buildList() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${_filtered.length} employé${_filtered.length > 1 ? 's' : ''}',
              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
          const SizedBox(height: 12),
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.bgSecondary,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.border, width: 0.5),
            ),
            child: const Row(
              children: [
                Expanded(flex: 3, child: _ColHeader('NOM ET PRÉNOMS')),
                Expanded(flex: 2, child: _ColHeader('EMPLOI')),
                SizedBox(width: 120, child: _ColHeader('MATRICULE')),
                SizedBox(width: 100, child: _ColHeader('CODE SERVICE')),
                SizedBox(width: 80),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // Rows
          Expanded(
            child: ListView.separated(
              itemCount: _filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (_, i) => _EmployeRow(
                employe: _filtered[i],
                onEdit:   () => _openForm(_filtered[i]),
                onDelete: () => _confirmDelete(_filtered[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openForm(Employe? existing) {
    showDialog(
      context: context,
      builder: (_) => _EmployeFormDialog(
        existing: existing,
        onSaved: (e) async {
          await HiveService.saveEmploye(e);
          _load();
        },
      ),
    );
  }

  void _confirmDelete(Employe e) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer l\'employé', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        content: Text(
          'Voulez-vous vraiment supprimer "${e.nomPrenoms}" ?\nSes relevés ne seront pas supprimés.',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              await HiveService.deleteEmploye(e.id);
              if (mounted) Navigator.pop(context);
              _load();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

// ─── Row widget ───────────────────────────────────────────────────────────────
class _EmployeRow extends StatefulWidget {
  final Employe employe;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _EmployeRow({required this.employe, required this.onEdit, required this.onDelete});
  @override State<_EmployeRow> createState() => _EmployeRowState();
}

class _EmployeRowState extends State<_EmployeRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final e = widget.employe;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _hovered ? AppTheme.primaryLight : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _hovered ? AppTheme.primary.withOpacity(0.2) : AppTheme.border,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 32, height: 32,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  _initials(e.nomPrenoms),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppTheme.primary),
                ),
              ),
            ),
            Expanded(flex: 3, child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.nomPrenoms, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            )),
            Expanded(flex: 2, child: Text(e.emploi,
                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted), overflow: TextOverflow.ellipsis)),
            SizedBox(width: 120, child: _Badge(e.matricule)),
            SizedBox(width: 100, child: _Badge(e.codeService, color: AppTheme.accent)),
            SizedBox(
              width: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _IconBtn(icon: Icons.edit_outlined,   color: AppTheme.primary, onTap: widget.onEdit,   tip: 'Modifier'),
                  _IconBtn(icon: Icons.delete_outline,  color: AppTheme.danger,  onTap: widget.onDelete, tip: 'Supprimer'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

// ─── Form dialog ──────────────────────────────────────────────────────────────
class _EmployeFormDialog extends StatefulWidget {
  final Employe? existing;
  final Future<void> Function(Employe) onSaved;
  const _EmployeFormDialog({this.existing, required this.onSaved});
  @override State<_EmployeFormDialog> createState() => _EmployeFormDialogState();
}

class _EmployeFormDialogState extends State<_EmployeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomCtrl;
  late final TextEditingController _emploiCtrl;
  late final TextEditingController _matriculeCtrl;
  late final TextEditingController _codeCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nomCtrl       = TextEditingController(text: e?.nomPrenoms  ?? '');
    _emploiCtrl    = TextEditingController(text: e?.emploi      ?? '');
    _matriculeCtrl = TextEditingController(text: e?.matricule   ?? '');
    _codeCtrl      = TextEditingController(text: e?.codeService ?? '');
  }

  @override
  void dispose() {
    _nomCtrl.dispose(); _emploiCtrl.dispose();
    _matriculeCtrl.dispose(); _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final employe = Employe(
      id:          widget.existing?.id ?? const Uuid().v4(),
      nomPrenoms:  _nomCtrl.text.trim().toUpperCase(),
      emploi:      _emploiCtrl.text.trim().toUpperCase(),
      matricule:   _matriculeCtrl.text.trim(),
      codeService: _codeCtrl.text.trim().toUpperCase(),
    );
    await widget.onSaved(employe);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return AlertDialog(
      title: Text(
        isEdit ? 'Modifier l\'employé' : 'Nouvel employé',
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _FormField(
                label: 'Nom et prénoms',
                ctrl: _nomCtrl,
                hint: 'Ex: MADAOUI MHAMED',
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Champ obligatoire' : null,
              ),
              const SizedBox(height: 12),
              _FormField(
                label: 'Emploi',
                ctrl: _emploiCtrl,
                hint: 'Ex: TECHNICIEN PAL MAINT',
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Champ obligatoire' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _FormField(
                    label: 'Matricule',
                    ctrl: _matriculeCtrl,
                    hint: 'Ex: 014734',
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Obligatoire' : null,
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _FormField(
                    label: 'Code de service',
                    ctrl: _codeCtrl,
                    hint: 'Ex: 86H4',
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Obligatoire' : null,
                  )),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _submit,
          child: _saving
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(isEdit ? 'Enregistrer' : 'Ajouter'),
        ),
      ],
    );
  }
}

// ─── Small helpers ────────────────────────────────────────────────────────────
class _ColHeader extends StatelessWidget {
  final String text;
  const _ColHeader(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppTheme.textMuted, letterSpacing: 0.4));
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge(this.text, {this.color = AppTheme.primary});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: color.withOpacity(0.2), width: 0.5),
    ),
    child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: color),
        overflow: TextOverflow.ellipsis),
  );
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String tip;
  const _IconBtn({required this.icon, required this.color, required this.onTap, required this.tip});
  @override
  Widget build(BuildContext context) => Tooltip(
    message: tip,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 16, color: color),
      ),
    ),
  );
}

class _FormField extends StatelessWidget {
  final String label, hint;
  final TextEditingController ctrl;
  final String? Function(String?)? validator;
  const _FormField({required this.label, required this.ctrl, required this.hint, this.validator});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
      const SizedBox(height: 4),
      TextFormField(
        controller: ctrl,
        validator: validator,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(hintText: hint, isDense: true),
      ),
    ],
  );
}
