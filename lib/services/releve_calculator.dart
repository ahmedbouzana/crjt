import '../../models/app_models.dart';

/// Résultat calculé pour un jour donné du mois
class JourCalcule {
  final int jour;
  final DateTime date;
  final TypeJour typeJour;
  final double heuresPresence; // 7, 8 ou 0
  final double heuresAbsence; // nombre d'heures d'absence
  final String? motifAbsence; // RN, JF, CM, CP, CA, FM
  final Map<String, double> heuresParLocalite; // localite -> heures
  final double hsSup155; // HS jour ouvrable journée  (×1.55)
  final double hsSup1825; // HS jour férié journée     (×1.825)
  final double hsSup210; // HS jour ouvrable nuit     (×2.10)
  final double hsSup2375; // HS jour férié nuit        (×2.375)
  final bool pan; // 1 si jour ouvrable normal travaillé hors Ramadan
  final bool astreinte; // 1 si dans une plage d'astreinte

  const JourCalcule({
    required this.jour,
    required this.date,
    required this.typeJour,
    required this.heuresPresence,
    required this.heuresAbsence,
    this.motifAbsence,
    required this.heuresParLocalite,
    required this.hsSup155,
    required this.hsSup1825,
    required this.hsSup210,
    required this.hsSup2375,
    required this.pan,
    required this.astreinte,
  });
}

enum TypeJour { normal, ramadan, weekend, ferie }

class ReleveCalculator {
  final AppSettings settings;
  final Releve releve;

  ReleveCalculator({required this.settings, required this.releve});

  List<JourCalcule> compute() {
    final nbJours = _daysInMonth(releve.annee, releve.mois);
    return List.generate(nbJours, (i) => _calcJour(i + 1));
  }

  JourCalcule _calcJour(int jour) {
    final date = DateTime(releve.annee, releve.mois, jour);
    final typeJour = _typeJour(date);

    // ── Motif d'absence ────────────────────────────────────────────────────
    String? motif;
    if (typeJour == TypeJour.weekend) {
      motif = 'RN';
    } else if (typeJour == TypeJour.ferie) {
      motif = 'JF';
    } else {
      motif = releve.motifAbsencePourJour(date);
    }

    final estAbsent = motif != null;

    // ── Heures de présence ─────────────────────────────────────────────────
    double heuresRef = typeJour == TypeJour.ramadan
        ? settings.heuresRamadan.toDouble()
        : settings.heuresNormales.toDouble();

    double heuresPresence = 0;
    double heuresAbsence = 0;

    if (typeJour == TypeJour.weekend) {
      heuresPresence = 0;
    } else if (typeJour == TypeJour.ferie) {
      // Jour férié : présence = 0 sauf si heures d'absence renseignées
      final absH = _heuresAbsenceJour(date);
      heuresPresence = 0;
      heuresAbsence = absH > 0 ? absH : 0;
    } else if (motif != null && motif != 'RN' && motif != 'JF') {
      // Absence CM/CP/CA/FM
      heuresPresence = 0;
      heuresAbsence = heuresRef;
    } else {
      heuresPresence = heuresRef;
      heuresAbsence = 0;
    }

    // ── Heures par localité ────────────────────────────────────────────────
    final Map<String, double> heuresParLocalite = {};
    for (final imp in releve.imputations) {
      final h = imp.heuresPourJour(date);
      if (h > 0) {
        heuresParLocalite[imp.localite] =
            (heuresParLocalite[imp.localite] ?? 0) + h;
      }
    }

    // ── Heures supplémentaires ────────────────────────────────────────────
    double hs155 = 0, hs1825 = 0, hs210 = 0, hs2375 = 0;
    final jourDate = DateTime(date.year, date.month, date.day);
    final lendemain = jourDate.add(const Duration(days: 1));
    const hDebJour = 5; // 05h00
    const hFinJour = 21; // 21h00

    for (final hs in releve.heuresSupp) {
      // Intersection avec la journée
      final start = hs.debut.isBefore(jourDate) ? jourDate : hs.debut;
      final end = hs.fin.isAfter(lendemain) ? lendemain : hs.fin;
      if (!end.isAfter(start)) continue;

      final estFerie =
          typeJour == TypeJour.ferie || typeJour == TypeJour.weekend;

      // Découper en tranche jour (05h-21h) et nuit (21h-05h)
      final seuilJour = DateTime(date.year, date.month, date.day, hDebJour);
      final seuilNuit = DateTime(date.year, date.month, date.day, hFinJour);
      final seuilNuitN1 = DateTime(
        date.year,
        date.month,
        date.day + 1,
        hDebJour,
      );

      // Portion "journée" : intersection de [start,end] avec [05h, 21h]
      final djStart = _max(start, seuilJour);
      final djEnd = _min(end, seuilNuit);
      if (djEnd.isAfter(djStart)) {
        final h = djEnd.difference(djStart).inMinutes / 60.0;
        if (estFerie)
          hs1825 += h;
        else
          hs155 += h;
      }

      // Portion "nuit soir" : [21h → minuit]
      final ns1Start = _max(start, seuilNuit);
      final ns1End = _min(end, lendemain);
      if (ns1End.isAfter(ns1Start)) {
        final h = ns1End.difference(ns1Start).inMinutes / 60.0;
        if (estFerie)
          hs2375 += h;
        else
          hs210 += h;
      }

      // Portion "nuit matin" : [minuit → 05h]
      final nm2Start = _max(start, jourDate);
      final nm2End = _min(end, seuilJour);
      if (nm2End.isAfter(nm2Start)) {
        final h = nm2End.difference(nm2Start).inMinutes / 60.0;
        if (estFerie)
          hs2375 += h;
        else
          hs210 += h;
      }
    }

    // ── PAN ────────────────────────────────────────────────────────────────
    // 1 si jour ouvrable normal travaillé ET hors Ramadan
    final pan = typeJour == TypeJour.normal && !estAbsent;

    // ── Astreinte ─────────────────────────────────────────────────────────
    final astreinte = releve.astreintes.any((p) => p.containsDate(date));

    return JourCalcule(
      jour: jour,
      date: date,
      typeJour: typeJour,
      heuresPresence: heuresPresence,
      heuresAbsence: heuresAbsence,
      motifAbsence: motif,
      heuresParLocalite: heuresParLocalite,
      hsSup155: hs155,
      hsSup1825: hs1825,
      hsSup210: hs210,
      hsSup2375: hs2375,
      pan: pan,
      astreinte: astreinte,
    );
  }

  TypeJour _typeJour(DateTime d) {
    // Weekend (vendredi=5, samedi=6)
    if (d.weekday == 5 || d.weekday == 6) return TypeJour.weekend;
    // Jour férié
    for (final jf in settings.joursFeries) {
      if (jf.containsDate(d)) return TypeJour.ferie;
    }
    // Ramadan
    if (settings.ramadanDebut != null && settings.ramadanFin != null) {
      final rd = DateTime(
        settings.ramadanDebut!.year,
        settings.ramadanDebut!.month,
        settings.ramadanDebut!.day,
      );
      final rf = DateTime(
        settings.ramadanFin!.year,
        settings.ramadanFin!.month,
        settings.ramadanFin!.day,
      );
      final dd = DateTime(d.year, d.month, d.day);
      if (!dd.isBefore(rd) && !dd.isAfter(rf)) return TypeJour.ramadan;
    }
    return TypeJour.normal;
  }

  double _heuresAbsenceJour(DateTime date) {
    for (final p in [
      ...releve.absencesCM,
      ...releve.absencesCP,
      ...releve.absencesCA,
      ...releve.absencesFM,
    ]) {
      if (p.containsDate(date)) {
        return releve.motifAbsencePourJour(date) != null
            ? (settings.heuresNormales.toDouble())
            : 0;
      }
    }
    return 0;
  }

  int _daysInMonth(int y, int m) => DateTime(y, m + 1, 0).day;

  DateTime _max(DateTime a, DateTime b) => a.isAfter(b) ? a : b;
  DateTime _min(DateTime a, DateTime b) => a.isBefore(b) ? a : b;
}
