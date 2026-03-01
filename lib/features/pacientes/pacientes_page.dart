import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import '../../models/paciente_model.dart';
import 'package:go_router/go_router.dart';

class PacientesPage extends StatelessWidget {
  const PacientesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FirebaseService();

    return Scaffold(
      appBar: AppBar(title: const Text("Pacientes"), centerTitle: true),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/nuevo'),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Paciente>>(
        stream: service.getPacientes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error al cargar pacientes"));
          }

          final pacientes = snapshot.data ?? [];

          if (pacientes.isEmpty) {
            return const Center(child: Text("No hay pacientes registrados"));
          }

          return ListView.builder(
            itemCount: pacientes.length,
            padding: const EdgeInsets.symmetric(
              vertical: 10,
            ), // Espaciado extra arriba/abajo
            itemBuilder: (context, index) {
              final p = pacientes[index];

              // --- INTEGRACIÓN DEL CÓDIGO DE LA CARD ---
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      p.nombre.isNotEmpty ? p.nombre[0].toUpperCase() : "?",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    p.nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text("Tel: ${p.telefono}"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push('/detalle/${p.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
