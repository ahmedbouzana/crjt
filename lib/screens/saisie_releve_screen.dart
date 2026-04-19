import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../models/app_models.dart';
import '../services/hive_service.dart';
import '../services/releve_calculator.dart';
import '../services/pdf_export_service.dart';
import '../theme/app_theme.dart';
import 'tabs/tab_absences.dart';
import 'tabs/tab_imputations.dart';
import 'tabs/tab_hs_astreinte.dart';
import 'tabs/tab_apercu.dart';

class SaisieReleveScreen extends StatefulWidget {
  final Employe employe;
  final int mois, annee;

  const SaisieReleveScreen({
    super.key,
    required this.employe,
    required this.mois,
    required this.annee,
  });

  @override
  State<SaisieReleveScreen> createState() => _SaisieReleveScreenState();
}

class _SaisieReleveScreenState extends State<SaisieReleveScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  late Releve _releve;
  late AppSettings _settings;
  bool _dirty = false;
  bool _saving = false;
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    _settings = HiveService.getSettings();
    _releve =
        HiveService.getReleve(widget.employe.id, widget.annee, widget.mois) ??
        Releve(
          employeId: widget.employe.id,
          mois: widget.mois,
          annee: widget.annee,
        );
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  void _onReleveChanged(Releve r) => setState(() {
    _releve = r;
    _dirty = true;
  });

  Future<void> _save() async {
    setState(() => _saving = true);
    await HiveService.saveReleve(_releve);
    if (mounted) {
      setState(() {
        _dirty = false;
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Relevé enregistré'),
          backgroundColor: AppTheme.accent,
        ),
      );
    }
  }

  Future<void> _export() async {
    setState(() => _exporting = true);
    try {
      if (_dirty) await _save();

      final service = PdfExportService(
        settings: _settings,
        employe: widget.employe,
        releve: _releve,
        mois: widget.mois,
        annee: widget.annee,
      );

      final file = await service.generate();

      if (mounted) {
        // Ouvrir le dialogue impression/aperçu/sauvegarde natif
        await Printing.layoutPdf(
          onLayout: (_) async => file.readAsBytesSync(),
          name: file.path.split('/').last,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur export : $e'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  List<JourCalcule> get _jours =>
      ReleveCalculator(settings: _settings, releve: _releve).compute();

  @override
  Widget build(BuildContext context) {
    final moisStr = DateFormat(
      'MMMM yyyy',
      'fr_FR',
    ).format(DateTime(widget.annee, widget.mois)).toUpperCase();

    return Scaffold(
      backgroundColor: AppTheme.bgSecondary,
      body: Column(
        children: [
          // ── Top bar ─────────────────────────────────────────────────────
          Container(
            color: Colors.white,
            child: Column(
              children: [
                // Header row
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: SizedBox(
                    height: 56,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios_new, size: 16),
                          tooltip: 'Retour',
                        ),
                        const SizedBox(width: 8),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.employe.nomPrenoms,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'N°${widget.employe.matricule}  ·  $moisStr',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        if (_dirty)
                          ElevatedButton.icon(
                            onPressed: _saving ? null : _save,
                            icon: _saving
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.save_outlined, size: 16),
                            label: const Text('Enregistrer'),
                          ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: _exporting ? null : _export,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.accent,
                            side: const BorderSide(color: AppTheme.accent),
                          ),
                          icon: _exporting
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppTheme.accent,
                                  ),
                                )
                              : const Icon(
                                  Icons.picture_as_pdf_outlined,
                                  size: 16,
                                ),
                          label: const Text('Exporter PDF'),
                        ),
                      ],
                    ),
                  ),
                ),
                // Tabs
                TabBar(
                  controller: _tabCtrl,
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  unselectedLabelStyle: const TextStyle(fontSize: 13),
                  labelColor: AppTheme.primary,
                  unselectedLabelColor: AppTheme.textMuted,
                  indicatorColor: AppTheme.primary,
                  indicatorWeight: 2,
                  tabs: const [
                    Tab(text: 'Absences'),
                    Tab(text: 'Imputations'),
                    Tab(text: 'H.Supp & Astreinte'),
                    Tab(text: 'Aperçu tableau'),
                  ],
                ),
              ],
            ),
          ),
          // ── Tab content ─────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                TabAbsences(
                  releve: _releve,
                  settings: _settings,
                  mois: widget.mois,
                  annee: widget.annee,
                  onChange: _onReleveChanged,
                ),
                TabImputations(
                  releve: _releve,
                  settings: _settings,
                  mois: widget.mois,
                  annee: widget.annee,
                  onChange: _onReleveChanged,
                ),
                TabHsAstreinte(
                  releve: _releve,
                  settings: _settings,
                  mois: widget.mois,
                  annee: widget.annee,
                  onChange: _onReleveChanged,
                ),
                TabApercu(
                  jours: _jours,
                  settings: _settings,
                  employe: widget.employe,
                  mois: widget.mois,
                  annee: widget.annee,
                  releve: _releve,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
