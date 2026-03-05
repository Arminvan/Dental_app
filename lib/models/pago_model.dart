import 'package:cloud_firestore/cloud_firestore.dart';

class Pago {
  final String id;
  final double monto;
  final DateTime fecha;
  final String metodo; // efectivo, transferencia, tarjeta
  final String? referencia;

  Pago({
    required this.id,
    required this.monto,
    required this.fecha,
    required this.metodo,
    this.referencia,
  });

  Map<String, dynamic> toMap() {
    return {
      "monto": monto,
      "fecha": Timestamp.fromDate(fecha),
      "metodo": metodo,
      "referencia": referencia,
    };
  }

  factory Pago.fromMap(String id, Map<String, dynamic> map) {
    return Pago(
      id: id,
      monto: (map["monto"] as num).toDouble(),
      fecha: (map["fecha"] as Timestamp).toDate(),
      metodo: map["metodo"],
      referencia: map["referencia"],
    );
  }
}
