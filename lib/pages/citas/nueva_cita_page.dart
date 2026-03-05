import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';
import 'package:intl/intl.dart'; // IMPORTANTE: Para dar formato a la fecha en la pantalla
import '../../main.dart';
import '../../models/paciente_model.dart';

class NuevaCitaPage extends StatefulWidget {
  final Paciente? paciente;
  const NuevaCitaPage({super.key, this.paciente});

  @override
  State<NuevaCitaPage> createState() => _NuevaCitaPageState();
}

class _NuevaCitaPageState extends State<NuevaCitaPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime _fechaSeleccionada = DateTime.now();
  TimeOfDay _horaSeleccionada = TimeOfDay.now();
  final _motivoController = TextEditingController();
  bool _guardando = false;

  // --- SELECTORES DE FECHA Y HORA ---
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _fechaSeleccionada = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _horaSeleccionada,
    );
    if (picked != null) setState(() => _horaSeleccionada = picked);
  }

  // --- FUNCIÓN PARA PROGRAMAR LA ALERTA 15 MIN ANTES ---
  Future<void> _programarNotificacion(DateTime fechaCita, String nombre) async {
    final fechaAlerta = fechaCita.subtract(const Duration(minutes: 15));

    if (fechaAlerta.isAfter(DateTime.now())) {
      try {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          fechaCita.hashCode,
          'Próxima Cita Dental',
          'En 15 min: $nombre - ${_motivoController.text}',
          tz.TZDateTime.from(fechaAlerta, tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'canal_citas',
              'Recordatorios de Citas',
              importance: Importance.max,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      } catch (e) {
        debugPrint("Error al programar alerta: $e");
      }
    }
  }

  void _guardarCita() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);

    final fechaCompleta = DateTime(
      _fechaSeleccionada.year,
      _fechaSeleccionada.month,
      _fechaSeleccionada.day,
      _horaSeleccionada.hour,
      _horaSeleccionada.minute,
    );

    final nuevaCitaMap = {
      "pacienteId": widget.paciente?.id ?? "manual",
      "nombrePaciente": widget.paciente?.nombre ?? "Paciente General",
      "telefonoPaciente": widget.paciente?.telefono ?? "",
      "fechaHora": Timestamp.fromDate(fechaCompleta),
      "motivo": _motivoController.text,
      "recordatorioEnviado": false,
      "duracionMinutos": 45,
    };

    try {
      await FirebaseFirestore.instance.collection("citas").add(nuevaCitaMap);
      await _programarNotificacion(
        fechaCompleta,
        widget.paciente?.nombre ?? "Paciente General",
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Cita y alerta programadas")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error al guardar: $e")));
      }
    } finally {
      setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Agendar Cita")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Paciente: ${widget.paciente?.nombre ?? 'General'}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // CAMPO MOTIVO
              TextFormField(
                controller: _motivoController,
                decoration: const InputDecoration(
                  labelText: "Motivo (ej: Limpieza)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.edit),
                ),
                validator: (v) => v!.isEmpty ? "Campo obligatorio" : null,
              ),
              const SizedBox(height: 20),

              // SELECTOR DE FECHA
              ListTile(
                tileColor: Colors.blue.withOpacity(0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                title: const Text("Fecha de la cita"),
                subtitle: Text(
                  DateFormat('dd/MM/yyyy').format(_fechaSeleccionada),
                ),
                leading: const Icon(Icons.calendar_today, color: Colors.blue),
                onTap: _pickDate,
              ),
              const SizedBox(height: 10),

              // SELECTOR DE HORA
              ListTile(
                tileColor: Colors.blue.withOpacity(0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                title: const Text("Hora de la cita"),
                subtitle: Text(_horaSeleccionada.format(context)),
                leading: const Icon(Icons.access_time, color: Colors.blue),
                onTap: _pickTime,
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _guardando ? null : _guardarCita,
                  child: _guardando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Guardar y Programar Alerta"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
