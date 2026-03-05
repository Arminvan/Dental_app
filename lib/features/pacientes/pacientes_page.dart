import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../models/paciente_model.dart';

class PacientesPage extends StatefulWidget {
  const PacientesPage({super.key});

  @override
  State<PacientesPage> createState() => _PacientesPageState();
}

class _PacientesPageState extends State<PacientesPage> {
  String _filtro = "";

  // Función para eliminar paciente y sus citas (Eliminación en cascada)
  Future<void> _eliminarPaciente(String pacienteId) async {
    final batch = FirebaseFirestore.instance.batch();

    // 1. Referencia al paciente
    final pacienteRef = FirebaseFirestore.instance
        .collection('pacientes')
        .doc(pacienteId);
    batch.delete(pacienteRef);

    // 2. Buscar y borrar citas asociadas
    final citasQuery = await FirebaseFirestore.instance
        .collection('citas')
        .where('pacienteId', isEqualTo: pacienteId)
        .get();

    for (var doc in citasQuery.docs) {
      batch.delete(doc.reference);
    }

    // Ejecutar todos los cambios juntos
    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    final CollectionReference pacientesRef = FirebaseFirestore.instance
        .collection('pacientes');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Pacientes"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/nuevo_paciente'),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Buscar paciente...",
                prefixIcon: const Icon(Icons.search),
                fillColor: Colors.white,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) =>
                  setState(() => _filtro = value.toLowerCase()),
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: pacientesRef
            .orderBy('nombre')
            .snapshots(includeMetadataChanges: true),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return const Center(child: Text("Error al cargar"));
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final nombre = (data['nombre'] ?? "").toString().toLowerCase();
            return nombre.contains(_filtro);
          }).toList();

          if (docs.isEmpty) {
            return const Center(child: Text("No se encontraron pacientes"));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final paciente = Paciente.fromFirestore(data, doc.id);
              final bool isPending = doc.metadata.hasPendingWrites;

              return Dismissible(
                key: Key(doc.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("¿Eliminar expediente?"),
                      content: Text(
                        "Se borrará a ${paciente.nombre} y todas sus citas programadas.",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("CANCELAR"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text("ELIMINAR"),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (direction) => _eliminarPaciente(doc.id),
                child: ListTile(
                  leading: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      const CircleAvatar(child: Icon(Icons.person)),
                      if (isPending)
                        const CircleAvatar(
                          radius: 6,
                          backgroundColor: Colors.orange,
                        ),
                    ],
                  ),
                  title: Text(
                    paciente.nombre,
                    style: TextStyle(
                      fontWeight: isPending
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(paciente.telefono),
                  trailing: isPending
                      ? const Icon(
                          Icons.cloud_upload_outlined,
                          color: Colors.orange,
                          size: 20,
                        )
                      : const Icon(Icons.chevron_right),
                  onTap: () =>
                      context.push('/paciente_detalle', extra: paciente),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
