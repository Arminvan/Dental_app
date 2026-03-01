import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class PacienteDetailPage extends StatelessWidget {
  final String pacienteId;

  const PacienteDetailPage({super.key, required this.pacienteId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detalle Paciente")),
      body: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Centra el contenido verticalmente
          children: [
            Text(
              "ID del paciente: $pacienteId",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(
              height: 20,
            ), // Un pequeño espacio entre el texto y el botón
            ElevatedButton(
              onPressed: () {
                // Navega a la ruta del odontograma pasando el ID
                context.push('/odontograma/$pacienteId');
              },
              child: const Text("Abrir Odontograma"),
            ),
          ],
        ),
      ),
    );
  }
}
