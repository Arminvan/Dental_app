import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'diente_widget.dart';
import 'estado_diente.dart';

class OdontogramaPage extends StatefulWidget {
  final String pacienteId;

  const OdontogramaPage({super.key, required this.pacienteId});

  @override
  State<OdontogramaPage> createState() => _OdontogramaPageState();
}

class _OdontogramaPageState extends State<OdontogramaPage> {
  final db = FirebaseFirestore.instance;

  Map<String, EstadoDiente> odontograma = {};

  final List<String> dientes = [
    "18",
    "17",
    "16",
    "15",
    "14",
    "13",
    "12",
    "11",
    "21",
    "22",
    "23",
    "24",
    "25",
    "26",
    "27",
    "28",
    "48",
    "47",
    "46",
    "45",
    "44",
    "43",
    "42",
    "41",
    "31",
    "32",
    "33",
    "34",
    "35",
    "36",
    "37",
    "38",
  ];

  @override
  void initState() {
    super.initState();
    cargarOdontograma();
  }

  Future<void> cargarOdontograma() async {
    final doc = await db
        .collection("pacientes")
        .doc(widget.pacienteId)
        .collection("odontograma")
        .doc("actual")
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      final dientesMap = Map<String, dynamic>.from(data["dientes"]);

      setState(() {
        dientesMap.forEach((key, value) {
          odontograma[key] = EstadoDiente.values.firstWhere(
            (e) => e.name == value,
          );
        });
      });
    }
  }

  Future<void> guardarOdontograma() async {
    Map<String, String> dientesString = {};

    odontograma.forEach((key, value) {
      dientesString[key] = value.name;
    });

    await db
        .collection("pacientes")
        .doc(widget.pacienteId)
        .collection("odontograma")
        .doc("actual")
        .set({"dientes": dientesString, "fechaActualizacion": Timestamp.now()});
  }

  void actualizarEstado(String numero, EstadoDiente estado) {
    setState(() {
      odontograma[numero] = estado;
    });

    guardarOdontograma();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Odontograma Digital")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Título
            const Text(
              "Dentición Permanente",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 20),

            /// Odontograma
            Expanded(
              child: Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 12,
                  children: dientes.map((numero) {
                    return DienteWidget(
                      numero: numero,
                      estadoInicial: odontograma[numero] ?? EstadoDiente.sano,
                      onChanged: actualizarEstado,
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// Leyenda Clínica
            const Text(
              "Leyenda Clínica",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 20,
              runSpacing: 10,
              children: [
                legendItem("Sano", Colors.white),
                legendItem("Caries", Colors.red),
                legendItem("Endodoncia", Colors.orange),
                legendItem("Ausente", Colors.grey),
                legendItem("Prótesis", Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Widget para la leyenda
  Widget legendItem(String texto, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.black12),
          ),
        ),
        const SizedBox(width: 8),
        Text(texto, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
