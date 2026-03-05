import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../models/cita_model.dart';

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Cita> _todasLasCitasCache = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  Future<void> _enviarWhatsApp(Cita cita) async {
    final telefono = cita.telefonoPaciente.replaceAll(RegExp(r'[^0-9]'), '');
    final mensaje =
        "Hola ${cita.nombrePaciente}, le recordamos su cita dental "
        "hoy a las ${cita.fechaHora.hour.toString().padLeft(2, '0')}:${cita.fechaHora.minute.toString().padLeft(2, '0')}. "
        "¡Le esperamos!";

    final urlStr =
        "https://wa.me/52$telefono?text=${Uri.encodeComponent(mensaje)}";
    final Uri url = Uri.parse(urlStr);

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
        await FirebaseFirestore.instance
            .collection('citas')
            .doc(cita.id)
            .update({'recordatorioEnviado': true});
      }
    } catch (e) {
      debugPrint("Error al lanzar WhatsApp: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Agenda de Consultas"), elevation: 0),
      body: Column(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("citas")
                .where(
                  "fechaHora",
                  isGreaterThanOrEqualTo: Timestamp.fromDate(
                    DateTime.now().subtract(const Duration(days: 30)),
                  ),
                )
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                _todasLasCitasCache = snapshot.data!.docs.map((doc) {
                  return Cita.fromFirestore(
                    doc.data() as Map<String, dynamic>,
                    doc.id,
                  );
                }).toList();
              }

              return TableCalendar(
                locale: 'es_ES',
                firstDay: DateTime.utc(2024, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onFormatChanged: (format) =>
                    setState(() => _calendarFormat = format),
                eventLoader: (day) {
                  return _todasLasCitasCache
                      .where((cita) => isSameDay(cita.fechaHora, day))
                      .toList();
                },
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.orangeAccent,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              );
            },
          ),
          const Divider(height: 1),
          Expanded(child: _buildListaCitasDelDia()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/nueva_cita'),
        label: const Text("Nueva Cita"),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildListaCitasDelDia() {
    final citasDia = _todasLasCitasCache
        .where((cita) => isSameDay(cita.fechaHora, _selectedDay))
        .toList();
    citasDia.sort((a, b) => a.fechaHora.compareTo(b.fechaHora));

    if (citasDia.isEmpty) {
      return const Center(child: Text("Sin citas para este día."));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: citasDia.length,
      itemBuilder: (context, index) {
        final cita = citasDia[index];
        final hora =
            "${cita.fechaHora.hour.toString().padLeft(2, '0')}:${cita.fechaHora.minute.toString().padLeft(2, '0')}";

        return Dismissible(
          key: Key(cita.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("¿Eliminar Cita?"),
                content: Text(
                  "¿Deseas cancelar la cita de ${cita.nombrePaciente}?",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text("VOLVER"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text(
                      "ELIMINAR",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );
          },
          onDismissed: (direction) async {
            await FirebaseFirestore.instance
                .collection('citas')
                .doc(cita.id)
                .delete();
          },
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.delete_sweep,
              color: Colors.white,
              size: 30,
            ),
          ),
          child: Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              // --- AJUSTE DE EDICIÓN: Al tocar la cita, navegamos al formulario con el 'extra' ---
              onTap: () => context.push('/nueva_cita', extra: cita),
              leading: CircleAvatar(
                backgroundColor: Colors.blue[50],
                child: Text(
                  hora,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              title: Text(
                cita.nombrePaciente,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("${cita.motivo}\nTel: ${cita.telefonoPaciente}"),
              isThreeLine: true,
              trailing: IconButton(
                icon: FaIcon(
                  FontAwesomeIcons.whatsapp,
                  color: cita.recordatorioEnviado ? Colors.grey : Colors.green,
                  size: 28,
                ),
                onPressed: () => _enviarWhatsApp(cita),
              ),
            ),
          ),
        );
      },
    );
  }
}
