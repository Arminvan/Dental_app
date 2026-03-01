import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/paciente_model.dart';

class FirebaseService {
  final _db = FirebaseFirestore.instance;

  Stream<List<Paciente>> getPacientes() {
    return _db.collection("pacientes").snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Paciente.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  Future<void> agregarPaciente(Paciente paciente) async {
    await _db.collection("pacientes").add(paciente.toMap());
  }
}
