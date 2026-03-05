import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VerPacientesScreen extends StatelessWidget {
  const VerPacientesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ver Pacientes"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/');
          },
        ),
      ),
      body: const Center(
        child: Text(
          "Aquí se mostrarán los pacientes",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
