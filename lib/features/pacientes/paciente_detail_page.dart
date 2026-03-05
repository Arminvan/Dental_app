import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/paciente_model.dart';
import '../../models/pago_model.dart';
import '../../services/pago_service.dart';

class PacienteDetailPage extends StatelessWidget {
  final Paciente paciente;

  const PacienteDetailPage({super.key, required this.paciente});

  @override
  Widget build(BuildContext context) {
    final pagoService = PagoService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Expediente del Paciente"),
        actions: [
          // Opción para editar los nuevos campos (edad, alergias, etc)
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/editar_paciente', extra: paciente),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. AVISO DE ALERGIAS (Solo se muestra si tiene algo escrito)
            if (paciente.alergias.isNotEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "ALERGIAS: ${paciente.alergias}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // 2. TARJETA DE INFORMACIÓN PERSONAL
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _infoRow(Icons.person, "Nombre", paciente.nombre),
                    const Divider(),
                    _infoRow(Icons.cake, "Edad", "${paciente.edad} años"),
                    const Divider(),
                    _infoRow(
                      Icons.phone,
                      "Teléfono",
                      "+52 ${paciente.telefono}",
                    ),
                    const Divider(),
                    _infoRow(
                      Icons.calendar_month,
                      "Fecha de Alta",
                      "${paciente.fechaAlta.day}/${paciente.fechaAlta.month}/${paciente.fechaAlta.year}",
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 3. SECCIÓN DE ACCIONES (HISTORIA, ODONTO, FINANZAS)
            const Text(
              "Acciones Rápidas",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMenuButton(
                  context,
                  Icons.history_edu,
                  "Historia",
                  Colors.blue,
                  '/historia',
                ),
                _buildMenuButton(
                  context,
                  Icons.medical_services,
                  "Odonto",
                  Colors.purple,
                  '/odontograma',
                ),
                _buildMenuButton(
                  context,
                  Icons.monetization_on,
                  "Finanzas",
                  Colors.green,
                  '/finanzas',
                ),
                _buildMenuButton(
                  context,
                  Icons.calendar_month,
                  "Cita",
                  Colors.pinkAccent,
                  '/nueva_cita',
                ),
              ],
            ),

            const SizedBox(height: 25),

            // 4. OBSERVACIONES CLÍNICAS
            const Text(
              "Observaciones Clínicas",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                paciente.observaciones.isEmpty
                    ? "Sin observaciones registradas."
                    : paciente.observaciones,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para filas de información
  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.teal),
        const SizedBox(width: 15),
        Text(label, style: const TextStyle(color: Colors.grey)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  // Widget auxiliar para los botones circulares/cuadrados de menú
  Widget _buildMenuButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    String route,
  ) {
    return InkWell(
      onTap: () => context.push(route, extra: paciente),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
