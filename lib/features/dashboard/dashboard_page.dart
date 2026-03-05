import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'monthly_chart.dart'; // Importamos tu gráfico

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Panel de Control"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            onPressed: () async {
              // Cerramos sesión en Firebase
              await FirebaseAuth.instance.signOut();
              // Regresamos al login usando el nombre de la ruta
              if (context.mounted) {
                context.go('/login');
              }
            },
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Accesos Rápidos",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            /// ===== GRID DE BOTONES =====
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2, // Dos columnas
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildMenuButton(
                  context,
                  title: "Pacientes",
                  icon: Icons.people_alt_rounded,
                  color: Colors.blue,
                  route: '/pacientes',
                ),
                _buildMenuButton(
                  context,
                  title: "Finanzas",
                  icon: Icons.monetization_on_rounded,
                  color: Colors.green,
                  route:
                      '/finanzas', // Asegúrate de tener esta ruta en AppRouter
                ),
                _buildMenuButton(
                  context,
                  title: "Nuevo Registro",
                  icon: Icons.person_add_alt_1_rounded,
                  color: Colors.orange,
                  route: '/nuevo_paciente',
                ),
                _buildMenuButton(
                  context,
                  title: "Citas",
                  icon: Icons.calendar_month,
                  color: Colors.orangeAccent,
                  route: '/agenda',
                ),
              ],
            ),

            const SizedBox(height: 32),

            /// ===== SECCIÓN DE ESTADÍSTICAS =====
            const Text(
              "Resumen de Ingresos",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Integración del gráfico
            const MonthlyChart(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Función para construir botones consistentes
  Widget _buildMenuButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => context.push(route), // Navegación usando GoRouter
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
