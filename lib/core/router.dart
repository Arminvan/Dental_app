import 'package:go_router/go_router.dart';
import '../features/pacientes/pacientes_page.dart';
import '../features/pacientes/paciente_form_page.dart';
import '../features/pacientes/paciente_detail_page.dart';
import '../features/odontograma/odontograma_page.dart';

final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const PacientesPage()),
    GoRoute(
      path: '/nuevo',
      builder: (context, state) => const PacienteFormPage(),
    ),
    GoRoute(
      path: '/detalle/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return PacienteDetailPage(pacienteId: id);
      },
    ),
    GoRoute(
      path: '/odontograma/:id',
      builder: (context, state) {
        final pacienteId = state.pathParameters['id']!;
        return OdontogramaPage(pacienteId: pacienteId);
      },
    ),
  ],
);
