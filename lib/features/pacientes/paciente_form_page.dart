import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import '../../models/paciente_model.dart';

class PacienteFormPage extends StatefulWidget {
  const PacienteFormPage({super.key});

  @override
  State<PacienteFormPage> createState() => _PacienteFormPageState();
}

class _PacienteFormPageState extends State<PacienteFormPage> {
  final _nombre = TextEditingController();
  final _telefono = TextEditingController();
  final _email = TextEditingController();
  final service = FirebaseService();

  void guardar() async {
    final paciente = Paciente(
      id: '',
      nombre: _nombre.text,
      telefono: _telefono.text,
      email: _email.text,
    );

    await service.agregarPaciente(paciente);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nuevo Paciente")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nombre,
              decoration: const InputDecoration(labelText: "Nombre"),
            ),
            TextField(
              controller: _telefono,
              decoration: const InputDecoration(labelText: "Teléfono"),
            ),
            TextField(
              controller: _email,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: guardar, child: const Text("Guardar")),
          ],
        ),
      ),
    );
  }
}
