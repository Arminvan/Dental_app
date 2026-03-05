import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inicio")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            context.go('/ver_pacientes');
          },
          child: const Text("Abrir y ver pacientes"),
        ),
      ),
    );
  }
}
