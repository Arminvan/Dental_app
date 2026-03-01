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
      appBar: AppBar(title: const Text("Pacientes")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/nuevo'),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Paciente>>(
        stream: service.getPacientes(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final pacientes = snapshot.data!;

          return ListView.builder(
            itemCount: pacientes.length,
            itemBuilder: (context, index) {
              final p = pacientes[index];
              return ListTile(
                title: Text(p.nombre),
                subtitle: Text(p.telefono),
                onTap: () => context.push('/detalle/${p.id}'),
              );
            },
          );
        },
      ),
    );
  }
}
