import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../models/paciente_model.dart';

class PacientesPage extends StatefulWidget {
  // Cambiado a StatefulWidget
  const PacientesPage({super.key});

  @override
  State<PacientesPage> createState() => _PacientesPageState();
}

class _PacientesPageState extends State<PacientesPage> {
  String _filtro = ""; // Variable para el buscador

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
        // Agregamos el buscador debajo del título
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
              onChanged: (value) {
                setState(() {
                  _filtro = value
                      .toLowerCase(); // Actualiza la lista al escribir
                });
              },
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: pacientesRef.orderBy('nombre').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return const Center(child: Text("Error al cargar"));
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          // Filtramos la lista basándonos en el texto del buscador
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
              final data = docs[index].data() as Map<String, dynamic>;
              final paciente = Paciente.fromFirestore(data, docs[index].id);

              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(paciente.nombre),
                subtitle: Text(paciente.telefono),
                onTap: () {
                  // Mantenemos la lógica de enviar el objeto completo para evitar errores
                  context.push('/paciente_detalle', extra: paciente);
                },
              );
            },
          );
        },
      ),
    );
  }
}
