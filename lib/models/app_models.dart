import 'package:hive/hive.dart';

part 'app_models.g.dart';

// ─── Jour Férié ───────────────────────────────────────────────────────────────
@HiveType(typeId: 0)
class JourFerie extends HiveObject {
  @HiveField(0)
  String description;
  @HiveField(1)
  DateTime dateDebut;
  @HiveField(2)
  DateTime dateFin;

  JourFerie({
    required this.description,
    required this.dateDebut,
    required this.dateFin,
  });

  bool containsDate(DateTime d) {
    final day = DateTime(d.year, d.month, d.day);
    final debut = DateTime(dateDebut.year, dateDebut.month, dateDebut.day);
    final fin = DateTime(dateFin.year, dateFin.month, dateFin.day);
    return !day.isBefore(debut) && !day.isAfter(fin);
  }
}

// ─── Taux Heures Supplémentaires ─────────────────────────────────────────────
@HiveType(typeId: 1)
class TauxHS extends HiveObject {
  @HiveField(0)
  double jourOuvrJour; // 1.55  (05h–21h)
  @HiveField(1)
  double jourOuvrNuit; // 2.10  (21h–05h)
  @HiveField(2)
  double jourFerieJour; // 1.825 (05h–21h)
  @HiveField(3)
  double jourFerieNuit; // 2.375 (21h–05h)

  TauxHS({
    this.jourOuvrJour = 1.55,
    this.jourOuvrNuit = 2.10,
    this.jourFerieJour = 1.825,
    this.jourFerieNuit = 2.375,
  });
}

// ─── Code Motif d'Absence ─────────────────────────────────────────────────────
@HiveType(typeId: 2)
class CodeMotif extends HiveObject {
  @HiveField(0)
  String code;
  @HiveField(1)
  String libelle;

  CodeMotif({required this.code, required this.libelle});
}

// ─── Paramètres globaux de l'app ──────────────────────────────────────────────
@HiveType(typeId: 3)
class AppSettings extends HiveObject {
  @HiveField(0)
  List<int>? headerImage; // bytes de l'image
  @HiveField(1)
  String unite;
  @HiveField(2)
  String service;
  @HiveField(3)
  String adresse;
  @HiveField(4)
  String telephone;
  @HiveField(5)
  List<String> localites;
  @HiveField(6)
  DateTime? ramadanDebut;
  @HiveField(7)
  DateTime? ramadanFin;
  @HiveField(8)
  int heuresRamadan; // défaut 7
  @HiveField(9)
  int heuresNormales; // défaut 8
  @HiveField(10)
  List<JourFerie> joursFeries;
  @HiveField(11)
  TauxHS taux;
  @HiveField(12)
  List<CodeMotif> codesMotifs;

  AppSettings({
    this.headerImage,
    this.unite = 'STEOS/RTE BLIDA',
    this.service = 'District CHLEF',
    this.adresse = 'RN N°1 Boufarik-Blida',
    this.telephone = '025.28.37.02',
    List<String>? localites,
    this.ramadanDebut,
    this.ramadanFin,
    this.heuresRamadan = 7,
    this.heuresNormales = 8,
    List<JourFerie>? joursFeries,
    TauxHS? taux,
    List<CodeMotif>? codesMotifs,
  }) : localites = localites ?? ['CHLEF', 'CM EMPC'],
       joursFeries = joursFeries ?? [],
       taux = taux ?? TauxHS(),
       codesMotifs = codesMotifs ?? _defaultMotifs();

  static List<CodeMotif> _defaultMotifs() => [
    CodeMotif(code: 'JF', libelle: 'Jour Férié'),
    CodeMotif(code: 'CM', libelle: 'Congé Maladie'),
    CodeMotif(code: 'CP', libelle: 'Congé Payé'),
    CodeMotif(code: 'FM', libelle: 'Formation'),
    CodeMotif(code: 'CA', libelle: 'Congé Annuel'),
    CodeMotif(code: 'RN', libelle: 'Weekend (Ven/Sam)'),
  ];
}

// ─── Employé ─────────────────────────────────────────────────────────────────
@HiveType(typeId: 4)
class Employe extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String nomPrenoms;
  @HiveField(2)
  String emploi;
  @HiveField(3)
  String matricule;
  @HiveField(4)
  String codeService;

  Employe({
    required this.id,
    required this.nomPrenoms,
    required this.emploi,
    required this.matricule,
    required this.codeService,
  });
}

// ─── Plage de dates (jours entiers) ──────────────────────────────────────────
@HiveType(typeId: 5)
class PlageDate {
  @HiveField(0)
  DateTime debut;
  @HiveField(1)
  DateTime fin;

  PlageDate({required this.debut, required this.fin});

  bool containsDate(DateTime d) {
    final day = DateTime(d.year, d.month, d.day);
    final start = DateTime(debut.year, debut.month, debut.day);
    final end = DateTime(fin.year, fin.month, fin.day);
    return !day.isBefore(start) && !day.isAfter(end);
  }

  List<DateTime> get tousLesJours {
    final List<DateTime> days = [];
    DateTime cur = DateTime(debut.year, debut.month, debut.day);
    final end = DateTime(fin.year, fin.month, fin.day);
    while (!cur.isAfter(end)) {
      days.add(cur);
      cur = cur.add(const Duration(days: 1));
    }
    return days;
  }
}

// ─── Plage datetime (heures précises) ────────────────────────────────────────
@HiveType(typeId: 6)
class PlageDatetime {
  @HiveField(0)
  DateTime debut;
  @HiveField(1)
  DateTime fin;

  PlageDatetime({required this.debut, required this.fin});

  Duration get duree => fin.difference(debut);

  double get heures => duree.inMinutes / 60.0;
}

// ─── Imputation (localité + plages horaires) ─────────────────────────────────
@HiveType(typeId: 7)
class Imputation {
  @HiveField(0)
  String localite;
  @HiveField(1)
  List<PlageDatetime> plages;

  Imputation({required this.localite, required this.plages});

  /// Heures travaillées dans cette localité pour un jour donné
  double heuresPourJour(DateTime jour) {
    double total = 0;
    final jourDate = DateTime(jour.year, jour.month, jour.day);
    final lendemain = jourDate.add(const Duration(days: 1));
    for (final p in plages) {
      // intersection de la plage avec la journée
      final start = p.debut.isBefore(jourDate) ? jourDate : p.debut;
      final end = p.fin.isAfter(lendemain) ? lendemain : p.fin;
      if (end.isAfter(start)) {
        total += end.difference(start).inMinutes / 60.0;
      }
    }
    return total;
  }
}

// ─── Heure Supplémentaire ─────────────────────────────────────────────────────
@HiveType(typeId: 8)
class HeureSupp {
  @HiveField(0)
  DateTime debut;
  @HiveField(1)
  DateTime fin;
  @HiveField(2)
  String localite;

  HeureSupp({required this.debut, required this.fin, required this.localite});

  double get heures => fin.difference(debut).inMinutes / 60.0;
}

// ─── Relevé mensuel d'un employé ─────────────────────────────────────────────
@HiveType(typeId: 9)
class Releve extends HiveObject {
  @HiveField(0)
  String employeId;
  @HiveField(1)
  int mois;
  @HiveField(2)
  int annee;
  // Absences par type
  @HiveField(3)
  List<PlageDate> absencesCM; // Congé Maladie
  @HiveField(4)
  List<PlageDate> absencesCP; // Congé Payé
  @HiveField(5)
  List<PlageDate> absencesCA; // Congé Annuel
  @HiveField(6)
  List<PlageDate> absencesFM; // Formation
  // Imputations par localité
  @HiveField(7)
  List<Imputation> imputations;
  // Heures supplémentaires
  @HiveField(8)
  List<HeureSupp> heuresSupp;
  // Indemnités astreinte
  @HiveField(9)
  List<PlageDate> astreintes;

  Releve({
    required this.employeId,
    required this.mois,
    required this.annee,
    List<PlageDate>? absencesCM,
    List<PlageDate>? absencesCP,
    List<PlageDate>? absencesCA,
    List<PlageDate>? absencesFM,
    List<Imputation>? imputations,
    List<HeureSupp>? heuresSupp,
    List<PlageDate>? astreintes,
  }) : absencesCM = absencesCM ?? [],
       absencesCP = absencesCP ?? [],
       absencesCA = absencesCA ?? [],
       absencesFM = absencesFM ?? [],
       imputations = imputations ?? [],
       heuresSupp = heuresSupp ?? [],
       astreintes = astreintes ?? [];

  String get cleHive =>
      '${employeId}_${annee}_${mois.toString().padLeft(2, '0')}';

  bool absencePourJour(DateTime jour) {
    for (final p in [
      ...absencesCM,
      ...absencesCP,
      ...absencesCA,
      ...absencesFM,
    ]) {
      if (p.containsDate(jour)) return true;
    }
    return false;
  }

  String? motifAbsencePourJour(DateTime jour) {
    for (final p in absencesCM) {
      if (p.containsDate(jour)) return 'CM';
    }
    for (final p in absencesCP) {
      if (p.containsDate(jour)) return 'CP';
    }
    for (final p in absencesCA) {
      if (p.containsDate(jour)) return 'CA';
    }
    for (final p in absencesFM) {
      if (p.containsDate(jour)) return 'FM';
    }
    return null;
  }
}
