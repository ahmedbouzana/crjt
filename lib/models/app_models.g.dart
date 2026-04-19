// GENERATED CODE - DO NOT MODIFY BY HAND
// Manual adapters for Hive types

part of 'app_models.dart';

// ─── JourFerie Adapter ────────────────────────────────────────────────────────
class JourFerieAdapter extends TypeAdapter<JourFerie> {
  @override
  final int typeId = 0;

  @override
  JourFerie read(BinaryReader reader) {
    return JourFerie(
      description: reader.read() as String,
      dateDebut: reader.read() as DateTime,
      dateFin: reader.read() as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, JourFerie obj) {
    writer.write(obj.description);
    writer.write(obj.dateDebut);
    writer.write(obj.dateFin);
  }
}

// ─── TauxHS Adapter ──────────────────────────────────────────────────────────
class TauxHSAdapter extends TypeAdapter<TauxHS> {
  @override
  final int typeId = 1;

  @override
  TauxHS read(BinaryReader reader) {
    return TauxHS(
      jourOuvrJour: reader.read() as double,
      jourOuvrNuit: reader.read() as double,
      jourFerieJour: reader.read() as double,
      jourFerieNuit: reader.read() as double,
    );
  }

  @override
  void write(BinaryWriter writer, TauxHS obj) {
    writer.write(obj.jourOuvrJour);
    writer.write(obj.jourOuvrNuit);
    writer.write(obj.jourFerieJour);
    writer.write(obj.jourFerieNuit);
  }
}

// ─── CodeMotif Adapter ───────────────────────────────────────────────────────
class CodeMotifAdapter extends TypeAdapter<CodeMotif> {
  @override
  final int typeId = 2;

  @override
  CodeMotif read(BinaryReader reader) {
    return CodeMotif(
      code: reader.read() as String,
      libelle: reader.read() as String,
    );
  }

  @override
  void write(BinaryWriter writer, CodeMotif obj) {
    writer.write(obj.code);
    writer.write(obj.libelle);
  }
}

// ─── AppSettings Adapter ─────────────────────────────────────────────────────
class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 3;

  @override
  AppSettings read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      headerImage: (fields[0] as List?)?.cast<int>(),
      unite: fields[1] as String? ?? 'STEOS/RTE BLIDA',
      service: fields[2] as String? ?? 'District CHLEF',
      adresse: fields[3] as String? ?? '',
      telephone: fields[4] as String? ?? '',
      localites: (fields[5] as List?)?.cast<String>(),
      ramadanDebut: fields[6] as DateTime?,
      ramadanFin: fields[7] as DateTime?,
      heuresRamadan: fields[8] as int? ?? 7,
      heuresNormales: fields[9] as int? ?? 8,
      joursFeries: (fields[10] as List?)?.cast<JourFerie>(),
      taux: fields[11] as TauxHS? ?? TauxHS(),
      codesMotifs: (fields[12] as List?)?.cast<CodeMotif>(),
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.headerImage)
      ..writeByte(1)
      ..write(obj.unite)
      ..writeByte(2)
      ..write(obj.service)
      ..writeByte(3)
      ..write(obj.adresse)
      ..writeByte(4)
      ..write(obj.telephone)
      ..writeByte(5)
      ..write(obj.localites)
      ..writeByte(6)
      ..write(obj.ramadanDebut)
      ..writeByte(7)
      ..write(obj.ramadanFin)
      ..writeByte(8)
      ..write(obj.heuresRamadan)
      ..writeByte(9)
      ..write(obj.heuresNormales)
      ..writeByte(10)
      ..write(obj.joursFeries)
      ..writeByte(11)
      ..write(obj.taux)
      ..writeByte(12)
      ..write(obj.codesMotifs);
  }
}

// ─── Employe Adapter ─────────────────────────────────────────────────────────
class EmployeAdapter extends TypeAdapter<Employe> {
  @override
  final int typeId = 4;

  @override
  Employe read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numFields; i++) reader.readByte(): reader.read(),
    };
    return Employe(
      id: fields[0] as String,
      nomPrenoms: fields[1] as String,
      emploi: fields[2] as String,
      matricule: fields[3] as String,
      codeService: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Employe obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nomPrenoms)
      ..writeByte(2)
      ..write(obj.emploi)
      ..writeByte(3)
      ..write(obj.matricule)
      ..writeByte(4)
      ..write(obj.codeService);
  }
}

// ─── PlageDate Adapter ───────────────────────────────────────────────────────
class PlageDateAdapter extends TypeAdapter<PlageDate> {
  @override
  final int typeId = 5;

  @override
  PlageDate read(BinaryReader reader) {
    return PlageDate(
      debut: reader.read() as DateTime,
      fin: reader.read() as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PlageDate obj) {
    writer.write(obj.debut);
    writer.write(obj.fin);
  }
}

// ─── PlageDatetime Adapter ───────────────────────────────────────────────────
class PlageDatetimeAdapter extends TypeAdapter<PlageDatetime> {
  @override
  final int typeId = 6;

  @override
  PlageDatetime read(BinaryReader reader) {
    return PlageDatetime(
      debut: reader.read() as DateTime,
      fin: reader.read() as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PlageDatetime obj) {
    writer.write(obj.debut);
    writer.write(obj.fin);
  }
}

// ─── Imputation Adapter ──────────────────────────────────────────────────────
class ImputationAdapter extends TypeAdapter<Imputation> {
  @override
  final int typeId = 7;

  @override
  Imputation read(BinaryReader reader) {
    return Imputation(
      localite: reader.read() as String,
      plages: (reader.read() as List).cast<PlageDatetime>(),
    );
  }

  @override
  void write(BinaryWriter writer, Imputation obj) {
    writer.write(obj.localite);
    writer.write(obj.plages);
  }
}

// ─── HeureSupp Adapter ───────────────────────────────────────────────────────
class HeureSuppAdapter extends TypeAdapter<HeureSupp> {
  @override
  final int typeId = 8;

  @override
  HeureSupp read(BinaryReader reader) {
    return HeureSupp(
      debut: reader.read() as DateTime,
      fin: reader.read() as DateTime,
      localite: reader.read() as String,
    );
  }

  @override
  void write(BinaryWriter writer, HeureSupp obj) {
    writer.write(obj.debut);
    writer.write(obj.fin);
    writer.write(obj.localite);
  }
}

// ─── Releve Adapter ──────────────────────────────────────────────────────────
class ReleveAdapter extends TypeAdapter<Releve> {
  @override
  final int typeId = 9;

  @override
  Releve read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numFields; i++) reader.readByte(): reader.read(),
    };
    return Releve(
      employeId: fields[0] as String,
      mois: fields[1] as int,
      annee: fields[2] as int,
      absencesCM: (fields[3] as List?)?.cast<PlageDate>(),
      absencesCP: (fields[4] as List?)?.cast<PlageDate>(),
      absencesCA: (fields[5] as List?)?.cast<PlageDate>(),
      absencesFM: (fields[6] as List?)?.cast<PlageDate>(),
      imputations: (fields[7] as List?)?.cast<Imputation>(),
      heuresSupp: (fields[8] as List?)?.cast<HeureSupp>(),
      astreintes: (fields[9] as List?)?.cast<PlageDate>(),
    );
  }

  @override
  void write(BinaryWriter writer, Releve obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.employeId)
      ..writeByte(1)
      ..write(obj.mois)
      ..writeByte(2)
      ..write(obj.annee)
      ..writeByte(3)
      ..write(obj.absencesCM)
      ..writeByte(4)
      ..write(obj.absencesCP)
      ..writeByte(5)
      ..write(obj.absencesCA)
      ..writeByte(6)
      ..write(obj.absencesFM)
      ..writeByte(7)
      ..write(obj.imputations)
      ..writeByte(8)
      ..write(obj.heuresSupp)
      ..writeByte(9)
      ..write(obj.astreintes);
  }
}
