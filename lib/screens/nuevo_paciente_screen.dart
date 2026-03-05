import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/paciente_service.dart';

class NuevoPacienteScreen extends StatefulWidget {
  const NuevoPacienteScreen({super.key});

  @override
  State<NuevoPacienteScreen> createState() => _NuevoPacienteScreenState();
}

class _NuevoPacienteScreenState extends State<NuevoPacienteScreen> {
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _service = PacienteService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nuevo Paciente")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: "Nombre"),
            ),
            TextField(
              controller: _telefonoController,
              decoration: const InputDecoration(labelText: "Teléfono"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final id = await _service.crearPaciente(
                  _nombreController.text,
                  _telefonoController.text,
                );

                // 🔥 Abrir odontograma automáticamente
                context.go('/odontograma/$id');
              },
              child: const Text("Guardar"),
            ),
          ],
        ),
      ),
    );
  }
}
