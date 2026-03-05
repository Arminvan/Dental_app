import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/paciente_model.dart';
import '../../models/cita_model.dart';

class NuevaCitaPage extends StatefulWidget {
  final Paciente? paciente;

  const NuevaCitaPage({super.key, this.paciente});

  @override
  State<NuevaCitaPage> createState() => _NuevaCitaPageState();
}

class _NuevaCitaPageState extends State<NuevaCitaPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nombreController;
  late TextEditingController _telController;
  final _motivoController = TextEditingController();

  // Variable para guardar el ID si se selecciona del buscador
  String? _pacienteIdSeleccionado;

  DateTime _fechaSeleccionada = DateTime.now();
  TimeOfDay _horaSeleccionada = const TimeOfDay(hour: 9, minute: 0);
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(
      text: widget.paciente?.nombre ?? "",
    );
    _telController = TextEditingController(
      text: widget.paciente?.telefono ?? "",
    );
    _pacienteIdSeleccionado = widget.paciente?.id;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _telController.dispose();
    _motivoController.dispose();
    super.dispose();
  }

  void _mostrarAlertaOcupado() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("⚠️ Horario Ocupado"),
        content: const Text(
          "Ya existe una cita en este horario o se traslapa con otra.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ENTENDIDO"),
          ),
        ],
      ),
    );
  }

  Future<bool> _verificarDisponibilidad(
    DateTime inicioNueva,
    int duracion,
  ) async {
    final inicioDia = DateTime(
      inicioNueva.year,
      inicioNueva.month,
      inicioNueva.day,
    );
    final finDia = inicioDia.add(const Duration(days: 1));

    final query = await FirebaseFirestore.instance
        .collection('citas')
        .where(
          'fechaHora',
          isGreaterThanOrEqualTo: Timestamp.fromDate(inicioDia),
        )
        .where('fechaHora', isLessThan: Timestamp.fromDate(finDia))
        .get();

    for (var doc in query.docs) {
      final citaExistente = Cita.fromFirestore(doc.data(), doc.id);
      if (citaExistente.tieneConflictoCon(inicioNueva, duracion)) return false;
    }
    return true;
  }

  Future<void> _seleccionarHora() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _horaSeleccionada,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );

    if (picked != null) {
      int minutoAjustado = (picked.minute < 15)
          ? 0
          : (picked.minute < 45 ? 30 : 0);
      int horaAjustada = (picked.minute >= 45)
          ? (picked.hour + 1) % 24
          : picked.hour;
      setState(() {
        _horaSeleccionada = TimeOfDay(
          hour: horaAjustada,
          minute: minutoAjustado,
        );
      });
    }
  }

  Future<void> _guardarCita() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final fechaHoraCita = DateTime(
      _fechaSeleccionada.year,
      _fechaSeleccionada.month,
      _fechaSeleccionada.day,
      _horaSeleccionada.hour,
      _horaSeleccionada.minute,
    );

    const int duracionCita = 45;
    final disponible = await _verificarDisponibilidad(
      fechaHoraCita,
      duracionCita,
    );

    if (!disponible) {
      setState(() => _isLoading = false);
      _mostrarAlertaOcupado();
      return;
    }

    try {
      final batch = FirebaseFirestore.instance.batch();
      // Usamos el ID del buscador o del widget, si ambos son null, es paciente nuevo
      String finalPacienteId = _pacienteIdSeleccionado ?? "";

      if (finalPacienteId.isEmpty) {
        final nuevoPacienteRef = FirebaseFirestore.instance
            .collection('pacientes')
            .doc();
        finalPacienteId = nuevoPacienteRef.id;

        batch.set(nuevoPacienteRef, {
          'nombre': _nombreController.text.trim(),
          'telefono': _telController.text.trim(),
          'fechaAlta': Timestamp.now(),
          'observaciones': "Paciente creado desde buscador de agenda",
        });
      }

      final nuevaCitaRef = FirebaseFirestore.instance.collection('citas').doc();
      batch.set(nuevaCitaRef, {
        'pacienteId': finalPacienteId,
        'nombrePaciente': _nombreController.text.trim(),
        'telefonoPaciente': _telController.text.trim(),
        'fechaHora': Timestamp.fromDate(fechaHoraCita),
        'motivo': _motivoController.text.trim(),
        'recordatorioEnviado': false,
        'duracionMinutos': duracionCita,
      });

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Éxito al agendar")));
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Si ya viene un paciente por parámetro, no permitimos editar para evitar errores
    final bool esCampoEditable =
        widget.paciente == null && _pacienteIdSeleccionado == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.paciente == null ? "Nueva Cita" : "Programar Cita"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Datos del Paciente",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // --- BUSCADOR AUTOCOMPLETE ---
              Autocomplete<Paciente>(
                displayStringForOption: (Paciente p) => p.nombre,
                optionsBuilder: (TextEditingValue textEditingValue) async {
                  if (textEditingValue.text.isEmpty)
                    return const Iterable<Paciente>.empty();

                  final query = await FirebaseFirestore.instance
                      .collection('pacientes')
                      .where(
                        'nombre',
                        isGreaterThanOrEqualTo: textEditingValue.text,
                      )
                      .where(
                        'nombre',
                        isLessThanOrEqualTo: '${textEditingValue.text}\uf8ff',
                      )
                      .get();

                  return query.docs.map(
                    (doc) => Paciente.fromFirestore(doc.data(), doc.id),
                  );
                },
                onSelected: (Paciente p) {
                  setState(() {
                    _pacienteIdSeleccionado = p.id;
                    _nombreController.text = p.nombre;
                    _telController.text = p.telefono;
                  });
                },
                fieldViewBuilder:
                    (context, controller, focusNode, onFieldSubmitted) {
                      // Sincronizar controlador de Autocomplete con el nuestro inicial
                      if (controller.text.isEmpty &&
                          _nombreController.text.isNotEmpty) {
                        controller.text = _nombreController.text;
                      }

                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        enabled:
                            esCampoEditable || _pacienteIdSeleccionado != null,
                        decoration: InputDecoration(
                          labelText: "Nombre completo",
                          prefixIcon: const Icon(Icons.search),
                          border: const OutlineInputBorder(),
                          suffixIcon:
                              _pacienteIdSeleccionado != null &&
                                  widget.paciente == null
                              ? IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    setState(() {
                                      _pacienteIdSeleccionado = null;
                                      controller.clear();
                                      _nombreController.clear();
                                      _telController.clear();
                                    });
                                  },
                                )
                              : null,
                        ),
                        onChanged: (val) => _nombreController.text = val,
                        validator: (v) =>
                            v!.isEmpty ? "Campo obligatorio" : null,
                      );
                    },
              ),

              const SizedBox(height: 15),
              TextFormField(
                controller: _telController,
                enabled: esCampoEditable,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Teléfono",
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.length < 10 ? "Mínimo 10 dígitos" : null,
              ),

              const Divider(height: 40),

              // Selectores de Fecha y Hora (Igual a tu código previo)
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text("Fecha"),
                      subtitle: Text(
                        "${_fechaSeleccionada.day}/${_fechaSeleccionada.month}/${_fechaSeleccionada.year}",
                      ),
                      leading: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _fechaSeleccionada,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (picked != null)
                          setState(() => _fechaSeleccionada = picked);
                      },
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text("Hora"),
                      subtitle: Text(_horaSeleccionada.format(context)),
                      leading: const Icon(Icons.access_time),
                      onTap: _seleccionarHora,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              TextFormField(
                controller: _motivoController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: "Motivo",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "Ingrese el motivo" : null,
              ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isLoading ? null : _guardarCita,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _pacienteIdSeleccionado == null
                              ? "Crear Expediente y Cita"
                              : "Confirmar Cita",
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
