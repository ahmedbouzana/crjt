import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../models/app_models.dart';

class HiveService {
  static const String _settingsBox = 'settings';
  static const String _employesBox = 'employes';
  static const String _relevesBox = 'releves';
  static const String _settingsKey = 'app_settings';

  static Future<void> init() async {
    // 1. Supprimer les anciens fichiers AVANT d'initialiser Hive
    if (!kIsWeb) {
      try {
        final dir = await getApplicationDocumentsDirectory();
        for (final boxName in [_settingsBox, _employesBox, _relevesBox]) {
          final file = File('${dir.path}/$boxName.hive');
          final lockFile = File('${dir.path}/$boxName.lock');
          if (await file.exists()) await file.delete();
          if (await lockFile.exists()) await lockFile.delete();
        }
        debugPrint('Hive: Anciens fichiers supprimés.');
      } catch (e) {
        debugPrint('Hive: Erreur suppression fichiers : $e');
      }
    }

    // 2. Initialiser Hive
    await Hive.initFlutter();

    // 3. Enregistrer les adapters
    Hive.registerAdapter(JourFerieAdapter());
    Hive.registerAdapter(TauxHSAdapter());
    Hive.registerAdapter(CodeMotifAdapter());
    Hive.registerAdapter(AppSettingsAdapter());
    Hive.registerAdapter(EmployeAdapter());
    Hive.registerAdapter(PlageDateAdapter());
    Hive.registerAdapter(PlageDatetimeAdapter());
    Hive.registerAdapter(ImputationAdapter());
    Hive.registerAdapter(HeureSuppAdapter());
    Hive.registerAdapter(ReleveAdapter());

    // 4. Ouvrir les boxes
    await Hive.openBox<AppSettings>(_settingsBox);
    await Hive.openBox<Employe>(_employesBox);
    await Hive.openBox<Releve>(_relevesBox);

    // 5. Settings par défaut
    final settingsBox = Hive.box<AppSettings>(_settingsBox);
    if (settingsBox.get(_settingsKey) == null) {
      await settingsBox.put(_settingsKey, AppSettings());
      debugPrint('Hive: Settings par défaut créés.');
    }
  }

  // ─── Settings ────────────────────────────────────────────────────────────
  static Box<AppSettings> get _sBox => Hive.box<AppSettings>(_settingsBox);

  static AppSettings getSettings() {
    return _sBox.get(_settingsKey) ?? AppSettings();
  }

  static Future<void> saveSettings(AppSettings s) async {
    await _sBox.put(_settingsKey, s);
  }

  // ─── Employés ─────────────────────────────────────────────────────────────
  static Box<Employe> get _eBox => Hive.box<Employe>(_employesBox);

  static List<Employe> getAllEmployes() => _eBox.values.toList();

  static Future<void> saveEmploye(Employe e) async {
    await _eBox.put(e.id, e);
  }

  static Future<void> deleteEmploye(String id) async {
    await _eBox.delete(id);
  }

  // ─── Relevés ──────────────────────────────────────────────────────────────
  static Box<Releve> get _rBox => Hive.box<Releve>(_relevesBox);

  static Releve? getReleve(String employeId, int annee, int mois) {
    final key = '${employeId}_${annee}_${mois.toString().padLeft(2, '0')}';
    return _rBox.get(key);
  }

  static Future<void> saveReleve(Releve r) async {
    await _rBox.put(r.cleHive, r);
  }
}
