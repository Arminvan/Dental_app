import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/paciente_model.dart';
import '../../models/tratamiento_model.dart';

class HistoriaPage extends StatelessWidget {
  final Paciente paciente;

  const HistoriaPage({super.key, required this.paciente});

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(title: Text("Tratamientos: ${paciente.nombre}")),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _agregarTratamiento(context, db),
        label: const Text("Añadir Procedimiento"),
        icon: const Icon(Icons.add_circle_outline),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: db
            .collection("pacientes")
            .doc(paciente.id)
            .collection("tratamientos")
            .orderBy("fecha", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text("Sin tratamientos registrados."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final t = Tratamiento.fromFirestore(
                docs[index].data() as Map<String, dynamic>,
                docs[index].id,
              );

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.tealAccent,
                    child: Icon(Icons.medical_services, color: Colors.teal),
                  ),
                  title: Text(
                    t.descripcion,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "${t.fecha.day}/${t.fecha.month}/${t.fecha.year}",
                  ),
                  trailing: Text(
                    "\$${t.costo.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _agregarTratamiento(BuildContext context, FirebaseFirestore db) {
    final descController = TextEditingController();
    final costoController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Registrar en Bitácora"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: "Tratamiento (ej. Profilaxis)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: costoController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: "Costo del procedimiento",
                prefixText: "\$ ",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              final costo = double.tryParse(costoController.text) ?? 0.0;
              final descripcion = descController.text.trim();

              if (descripcion.isEmpty || costo <= 0) return;

              // USAMOS UN BATCH PARA ASEGURAR QUE AMBOS CAMBIOS OCURRAN JUNTOS
              WriteBatch batch = db.batch();

              // 1. Referencia al nuevo tratamiento
              DocumentReference tRef = db
                  .collection("pacientes")
                  .doc(paciente.id)
                  .collection("tratamientos")
                  .doc();

              batch.set(tRef, {
                "descripcion": descripcion,
                "costo": costo,
                "fecha": Timestamp.now(),
              });

              // 2. Referencia al paciente para actualizar su costo total
              DocumentReference pRef = db
                  .collection("pacientes")
                  .doc(paciente.id);

              batch.update(pRef, {
                "costoTotalTratamiento": FieldValue.increment(costo),
              });

              await batch.commit();

              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Guardar y Sumar"),
          ),
        ],
      ),
    );
  }
}
