import 'package:go_router/go_router.dart';

import '/features/dashboard/dashboard_page.dart';
import '/features/pacientes/pacientes_page.dart';
import '/features/pacientes/paciente_form_page.dart';
import '/features/pacientes/paciente_detail_page.dart';

import '/models/paciente_model.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: "/dashboard",
  routes: [
    /// ===== DASHBOARD =====
    GoRoute(
      path: "/dashboard",
      name: "dashboard",
      builder: (context, state) => const DashboardPage(),
    ),

    /// ===== LISTA PACIENTES =====
    GoRoute(
      path: "/pacientes",
      name: "pacientes",
      builder: (context, state) => const PacientesPage(),
      routes: [
        /// ===== NUEVO PACIENTE =====
        GoRoute(
          path: "nuevo",
          name: "nuevo_paciente",
          builder: (context, state) => const PacienteFormPage(),
        ),

        /// ===== EDITAR PACIENTE =====
        GoRoute(
          path: "editar",
          name: "editar_paciente",
          builder: (context, state) {
            final paciente = state.extra as Paciente;

            return PacienteFormPage(paciente: paciente);
          },
        ),

        /// ===== DETALLE PACIENTE =====
        GoRoute(
          path: "detalle",
          name: "detalle_paciente",
          builder: (context, state) {
            final paciente = state.extra as Paciente;

            return PacienteDetailPage(paciente: paciente);
          },
        ),
      ],
    ),
  ],
);
