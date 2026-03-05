import 'package:cloud_firestore/cloud_firestore.dart';

class Tratamiento {
  final String id;
  final String descripcion;
  final DateTime fecha;
  final double costo;

  Tratamiento({
    required this.id,
    required this.descripcion,
    required this.fecha,
    required this.costo,
  });

  factory Tratamiento.fromFirestore(Map<String, dynamic> data, String id) {
    return Tratamiento(
      id: id,
      descripcion: data['descripcion'] ?? '',
      fecha: (data['fecha'] as Timestamp).toDate(),
      costo: (data['costo'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'descripcion': descripcion,
      'fecha': Timestamp.fromDate(fecha),
      'costo': costo,
    };
  }
}
