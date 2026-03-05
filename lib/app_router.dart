import 'package:go_router/go_router.dart';
// Imports de las páginas (Asegúrate de que las rutas sean correctas en tu proyecto)
import './features/pacientes/paciente_detail_page.dart';
import './features/pacientes/paciente_form_page.dart';
import './features/pacientes/pacientes_page.dart';
import './features/dashboard/dashboard_page.dart';
import './features/odontograma/odontograma_page.dart';
import './models/paciente_model.dart';
import '../models/cita_model.dart';
import './features/finanzas/finanzas_page.dart';
import './features/auth/login_page.dart';
import './features/historia/historia_page.dart';
import './pages/citas/agenda_page.dart';
import './pages/citas/nueva_cita_page.dart'; // Ajusta la ruta según tus carpetas

class AppRouter {
  static final GoRouter router = GoRouter(
    // 1. Ajuste: Ahora la app inicia en el Dashboard
    initialLocation: '/login',

    routes: [
      // DASHBOARD (Pantalla Principal)
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardPage(),
      ),

      GoRoute(
        path: '/historia',
        builder: (context, state) {
          // Extraemos el paciente que enviamos desde la pantalla de detalle
          final paciente = state.extra as Paciente;
          return HistoriaPage(paciente: paciente);
        },
      ),

      // 2. NUEVA RUTA DE FINANZAS
      GoRoute(
        path: '/finanzas',
        builder: (context, state) {
          // Usamos 'as Paciente?' con signo de interrogación para aceptar nulos
          final paciente = state.extra as Paciente?;

          // Pasamos el ID solo si el paciente existe, si no, pasa como null
          return FinanzasPage(pacienteId: paciente?.id);
        },
      ),

      // LISTA DE PACIENTES
      GoRoute(
        path: '/pacientes',
        builder: (context, state) => const PacientesPage(),
      ),

      // FORMULARIO NUEVO PACIENTE
      GoRoute(
        path: '/nuevo_paciente',
        builder: (context, state) => const PacienteFormPage(),
      ),

      // DETALLE DEL PACIENTE
      GoRoute(
        path: '/paciente_detalle',
        builder: (context, state) {
          // Recibe el objeto Paciente completo para evitar el error de 'pacienteId'
          final pacienteSeleccionado = state.extra as Paciente;
          return PacienteDetailPage(paciente: pacienteSeleccionado);
        },
      ),

      // ODONTOGRAMA
      GoRoute(
        path: '/odontograma',
        builder: (context, state) {
          // Ajuste: Extraemos el paciente pero pasamos solo el ID que pide tu widget
          final paciente = state.extra as Paciente;
          return OdontogramaPage(pacienteId: paciente.id);
        },
      ),
      GoRoute(
        path: '/editar_paciente',
        builder: (context, state) {
          final paciente = state.extra as Paciente;
          return PacienteFormPage(
            paciente: paciente,
          ); // El formulario detectará que es edición
        },
      ),
      GoRoute(path: '/agenda', builder: (context, state) => const AgendaPage()),
      GoRoute(
        path: '/nueva_cita',
        builder: (context, state) {
          // Intentamos extraer el paciente si viene como 'extra'
          // Si no viene nada (desde la agenda), 'paciente' será null
          final paciente = state.extra is Paciente
              ? state.extra as Paciente
              : null;

          // Pasamos el objeto (sea null o no) a la página
          return NuevaCitaPage(paciente: paciente);
        },
      ),
    ],
  );
}
