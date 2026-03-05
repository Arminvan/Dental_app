import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pago_model.dart';

class PagoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> registrarPago({
    required String pacienteId,
    required Pago pago,
  }) async {
    await _db
        .collection("pacientes")
        .doc(pacienteId)
        .collection("pagos")
        .add(pago.toMap());
  }

  Stream<List<Pago>> obtenerPagos(String pacienteId) {
    return _db
        .collection("pacientes")
        .doc(pacienteId)
        .collection("pagos")
        .orderBy("fecha", descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Pago.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<double> calcularTotalAbonado(String pacienteId) async {
    final snapshot = await _db
        .collection("pacientes")
        .doc(pacienteId)
        .collection("pagos")
        .get();

    double total = 0;

    for (var doc in snapshot.docs) {
      total += (doc["monto"] as num).toDouble();
    }

    return total;
  }
}
