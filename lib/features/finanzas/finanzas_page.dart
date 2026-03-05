import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../dashboard/monthly_chart.dart';
import '../../services/pdf_service.dart';

class FinanzasPage extends StatelessWidget {
  final String? pacienteId;

  const FinanzasPage({super.key, this.pacienteId});

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;

    if (pacienteId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Resumen de Ingresos")),
        body: const Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                "Estadísticas Mensuales",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              MonthlyChart(),
            ],
          ),
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: db.collection("pacientes").doc(pacienteId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>?;
        if (data == null) {
          return const Scaffold(
            body: Center(child: Text("Paciente no encontrado")),
          );
        }

        final nombrePaciente = data["nombre"] ?? "Paciente";
        // Ajustamos al nombre de campo de tu nuevo modelo
        final costoTotal = (data["costoTotalTratamiento"] ?? 0).toDouble();

        return StreamBuilder<QuerySnapshot>(
          stream: db
              .collection("pacientes")
              .doc(pacienteId)
              .collection("pagos")
              .orderBy("fecha", descending: true)
              .snapshots(),
          builder: (context, pagoSnapshot) {
            double totalPagado = 0;
            List<Map<String, dynamic>> listaPagos = [];

            if (pagoSnapshot.hasData) {
              for (var doc in pagoSnapshot.data!.docs) {
                final pagoData = doc.data() as Map<String, dynamic>;
                final monto = (pagoData["monto"] as num).toDouble();
                totalPagado += monto;

                final fecha = (pagoData["fecha"] as Timestamp).toDate();
                listaPagos.add({
                  'monto': monto.toStringAsFixed(2),
                  'fecha': "${fecha.day}/${fecha.month}/${fecha.year}",
                });
              }
            }

            double adeudo = costoTotal - totalPagado;

            return Scaffold(
              appBar: AppBar(
                title: const Text("Finanzas del Paciente"),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.picture_as_pdf),
                    onPressed: () => PdfService.generarRecibo(
                      nombrePaciente: nombrePaciente,
                      costoTotal: costoTotal,
                      totalPagado: totalPagado,
                      adeudo: adeudo,
                      pagos: listaPagos,
                    ),
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () => _agregarPago(context, db),
                child: const Icon(Icons.add),
              ),
              body: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Pasamos el costoTotal actual para que el diálogo lo conozca
                    _resumenCard(context, db, costoTotal, totalPagado, adeudo),
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Historial de Pagos",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: listaPagos.isEmpty
                          ? const Center(
                              child: Text("No hay pagos registrados"),
                            )
                          : ListView.builder(
                              itemCount: listaPagos.length,
                              itemBuilder: (context, index) {
                                return Card(
                                  child: ListTile(
                                    leading: const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    ),
                                    title: Text(
                                      "\$${listaPagos[index]['monto']}",
                                    ),
                                    subtitle: Text(listaPagos[index]['fecha']),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _resumenCard(
    BuildContext context,
    FirebaseFirestore db,
    double total,
    double pagado,
    double adeudo,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Presupuesto", style: TextStyle(color: Colors.grey)),
              Row(
                children: [
                  Text(
                    "\$${total.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                    onPressed: () => _editarPresupuesto(context, db, total),
                  ),
                ],
              ),
            ],
          ),
          const Divider(),
          _row("Total Pagado", pagado, Colors.green),
          _row(
            "Adeudo Pendiente",
            adeudo,
            adeudo > 0 ? Colors.red : Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _row(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            "\$${value.toStringAsFixed(2)}",
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  void _editarPresupuesto(
    BuildContext context,
    FirebaseFirestore db,
    double actual,
  ) {
    final controller = TextEditingController(text: actual.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Definir Presupuesto"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Costo total del tratamiento",
            prefixText: "\$ ",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              final nuevoCosto = double.tryParse(controller.text) ?? 0.0;
              await db.collection("pacientes").doc(pacienteId).update({
                "costoTotalTratamiento": nuevoCosto,
              });
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Actualizar"),
          ),
        ],
      ),
    );
  }

  void _agregarPago(BuildContext context, FirebaseFirestore db) {
    final montoController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Agregar Pago"),
        content: TextField(
          controller: montoController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Monto del abono"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              final monto = double.tryParse(montoController.text) ?? 0;
              await db
                  .collection("pacientes")
                  .doc(pacienteId)
                  .collection("pagos")
                  .add({"monto": monto, "fecha": Timestamp.now()});
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Guardar Pago"),
          ),
        ],
      ),
    );
  }
}
