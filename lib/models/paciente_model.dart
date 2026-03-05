import 'package:cloud_firestore/cloud_firestore.dart';

class Paciente {
  final String id;
  final String nombre;
  final DateTime fechaAlta;
  final int edad;
  final String telefono;
  final String alergias;
  final String observaciones;
  final double costoTotalTratamiento;

  Paciente({
    required this.id,
    required this.nombre,
    required this.fechaAlta,
    required this.edad,
    required this.telefono,
    required this.alergias,
    required this.observaciones,
    required this.costoTotalTratamiento,
  });

  factory Paciente.fromFirestore(Map<String, dynamic> data, String id) {
    return Paciente(
      id: id,
      nombre: data['nombre'] ?? '',
      // Convertimos el Timestamp de Firebase a DateTime de Dart
      fechaAlta: (data['fechaAlta'] as Timestamp?)?.toDate() ?? DateTime.now(),
      edad: data['edad'] ?? 0,
      telefono: data['telefono'] ?? '',
      alergias: data['alergias'] ?? '',
      observaciones: data['observaciones'] ?? '',
      costoTotalTratamiento: (data['costoTotalTratamiento'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'fechaAlta': Timestamp.fromDate(
        fechaAlta,
      ), // Guardamos como Timestamp para Firebase
      'edad': edad,
      'telefono': telefono,
      'alergias': alergias,
      'observaciones': observaciones,
      'costoTotalTratamiento': costoTotalTratamiento,
      'ultima_modificacion':
          FieldValue.serverTimestamp(), // Útil para auditoría médica
    };
  }
}
