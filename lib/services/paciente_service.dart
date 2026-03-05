import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/paciente_model.dart';

class PacienteService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🔹 Crear paciente
  Future<String> crearPaciente(String nombre, String telefono) async {
    final doc = await _db.collection('pacientes').add({
      'nombre': nombre,
      'telefono': telefono,
      'fecha_creacion': Timestamp.now(),
    });

    return doc.id;
  }

  // 🔹 Obtener lista en tiempo real
  Stream<List<Paciente>> obtenerPacientes() {
    return _db
        .collection('pacientes')
        .orderBy('fecha_creacion', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Paciente.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  // 🔹 Obtener un paciente por ID
  Future<Paciente?> obtenerPacientePorId(String id) async {
    final doc = await _db.collection('pacientes').doc(id).get();

    if (!doc.exists) return null;

    return Paciente.fromFirestore(doc.data()!, doc.id);
  }
}
