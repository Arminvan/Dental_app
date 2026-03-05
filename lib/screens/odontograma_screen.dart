import 'package:flutter/material.dart';
import '../services/paciente_service.dart';

class OdontogramaScreen extends StatelessWidget {
  final String pacienteId;

  const OdontogramaScreen({super.key, required this.pacienteId});

  @override
  Widget build(BuildContext context) {
    final service = PacienteService();

    return FutureBuilder(
      future: service.obtenerPacientePorId(pacienteId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final paciente = snapshot.data!;

        return Scaffold(
          appBar: AppBar(title: Text("Odontograma - ${paciente.nombre}")),
          body: const Center(child: Text("Aquí va el odontograma interactivo")),
        );
      },
    );
  }
}
