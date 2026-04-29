// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class JourFerieAdapter extends TypeAdapter<JourFerie> {
  @override
  final int typeId = 0;

  @override
  JourFerie read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return JourFerie(
      description: fields[0] as String,
      dateDebut: fields[1] as DateTime,
      dateFin: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, JourFerie obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.description)
      ..writeByte(1)
      ..write(obj.dateDebut)
      ..writeByte(2)
      ..write(obj.dateFin);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JourFerieAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TauxHSAdapter extends TypeAdapter<TauxHS> {
  @override
  final int typeId = 31;

  @override
  TauxHS read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TauxHS(
      jourOuvrJour: fields[0] as double,
      jourOuvrNuit: fields[1] as double,
      jourFerieJour: fields[2] as double,
      jourFerieNuit: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, TauxHS obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.jourOuvrJour)
      ..writeByte(1)
      ..write(obj.jourOuvrNuit)
      ..writeByte(2)
      ..write(obj.jourFerieJour)
      ..writeByte(3)
      ..write(obj.jourFerieNuit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TauxHSAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CodeMotifAdapter extends TypeAdapter<CodeMotif> {
  @override
  final int typeId = 2;

  @override
  CodeMotif read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CodeMotif(
      code: fields[0] as String,
      libelle: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CodeMotif obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.code)
      ..writeByte(1)
      ..write(obj.libelle);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CodeMotifAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 30;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      headerImage: (fields[0] as List?)?.cast<int>(),
      unite: fields[1] as String,
      service: fields[2] as String,
      adresse: fields[3] as String,
      telephone: fields[4] as String,
      localites: (fields[5] as List?)?.cast<String>(),
      ramadanDebut: fields[6] as DateTime?,
      ramadanFin: fields[7] as DateTime?,
      heuresRamadan: fields[8] as int,
      heuresNormales: fields[9] as int,
      joursFeries: (fields[10] as List?)?.cast<JourFerie>(),
      taux: fields[11] as TauxHS?,
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

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EmployeAdapter extends TypeAdapter<Employe> {
  @override
  final int typeId = 4;

  @override
  Employe read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
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

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmployeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PlageDateAdapter extends TypeAdapter<PlageDate> {
  @override
  final int typeId = 5;

  @override
  PlageDate read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlageDate(
      debut: fields[0] as DateTime,
      fin: fields[1] as DateTime,
      motif: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PlageDate obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.debut)
      ..writeByte(1)
      ..write(obj.fin)
      ..writeByte(2)
      ..write(obj.motif);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlageDateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PlageDatetimeAdapter extends TypeAdapter<PlageDatetime> {
  @override
  final int typeId = 6;

  @override
  PlageDatetime read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlageDatetime(
      debut: fields[0] as DateTime,
      fin: fields[1] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PlageDatetime obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.debut)
      ..writeByte(1)
      ..write(obj.fin);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlageDatetimeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ImputationAdapter extends TypeAdapter<Imputation> {
  @override
  final int typeId = 7;

  @override
  Imputation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Imputation(
      localite: fields[0] as String,
      plages: (fields[1] as List).cast<PlageDatetime>(),
    );
  }

  @override
  void write(BinaryWriter writer, Imputation obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.localite)
      ..writeByte(1)
      ..write(obj.plages);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImputationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HeureSuppAdapter extends TypeAdapter<HeureSupp> {
  @override
  final int typeId = 8;

  @override
  HeureSupp read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HeureSupp(
      debut: fields[0] as DateTime,
      fin: fields[1] as DateTime,
      localite: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HeureSupp obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.debut)
      ..writeByte(1)
      ..write(obj.fin)
      ..writeByte(2)
      ..write(obj.localite);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HeureSuppAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ReleveAdapter extends TypeAdapter<Releve> {
  @override
  final int typeId = 9;

  @override
  Releve read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Releve(
      employeId: fields[0] as String,
      mois: fields[1] as int,
      annee: fields[2] as int,
      absences: (fields[3] as List?)?.cast<PlageDate>(),
      imputations: (fields[7] as List?)?.cast<Imputation>(),
      heuresSupp: (fields[8] as List?)?.cast<HeureSupp>(),
      astreintes: (fields[9] as List?)?.cast<PlageDate>(),
    );
  }

  @override
  void write(BinaryWriter writer, Releve obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.employeId)
      ..writeByte(1)
      ..write(obj.mois)
      ..writeByte(2)
      ..write(obj.annee)
      ..writeByte(3)
      ..write(obj.absences)
      ..writeByte(7)
      ..write(obj.imputations)
      ..writeByte(8)
      ..write(obj.heuresSupp)
      ..writeByte(9)
      ..write(obj.astreintes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReleveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
