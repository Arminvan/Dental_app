import 'package:flutter/material.dart';

class PacienteDetailPage extends StatelessWidget {
  final String pacienteId;

  const PacienteDetailPage({super.key, required this.pacienteId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detalle Paciente")),
      body: Center(
        child: Text(
          "ID del paciente: $pacienteId",
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
