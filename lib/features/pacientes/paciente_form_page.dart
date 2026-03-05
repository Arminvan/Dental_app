import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/paciente_model.dart';

class PacienteFormPage extends StatefulWidget {
  final Paciente? paciente;

  const PacienteFormPage({super.key, this.paciente});

  @override
  State<PacienteFormPage> createState() => _PacienteFormPageState();
}

class _PacienteFormPageState extends State<PacienteFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos personales y clínicos
  final _nombreController = TextEditingController();
  final _edadController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _alergiasController = TextEditingController();
  final _observacionesController = TextEditingController();

  DateTime _fechaAlta = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Si editamos, cargamos los datos existentes
    if (widget.paciente != null) {
      _nombreController.text = widget.paciente!.nombre;
      _edadController.text = widget.paciente!.edad.toString();
      _telefonoController.text = widget.paciente!.telefono;
      _alergiasController.text = widget.paciente!.alergias;
      _observacionesController.text = widget.paciente!.observaciones;
      _fechaAlta = widget.paciente!.fechaAlta;
    }
  }

  Future<void> _guardarPaciente() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final db = FirebaseFirestore.instance;

    // Mapeo de datos (El costo se mantiene igual si existe, o inicia en 0)
    final datos = {
      "nombre": _nombreController.text.trim(),
      "edad": int.tryParse(_edadController.text.trim()) ?? 0,
      "telefono": _telefonoController.text.trim(),
      "alergias": _alergiasController.text.trim(),
      "observaciones": _observacionesController.text.trim(),
      "fechaAlta": Timestamp.fromDate(_fechaAlta),
      // Mantenemos el costo si ya existía (edición), de lo contrario 0.0
      "costoTotalTratamiento": widget.paciente?.costoTotalTratamiento ?? 0.0,
    };

    try {
      if (widget.paciente == null) {
        await db.collection("pacientes").add(datos);
      } else {
        await db.collection("pacientes").doc(widget.paciente!.id).update(datos);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al guardar: $e")));
    }

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _edadController.dispose();
    _telefonoController.dispose();
    _alergiasController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.paciente != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Editar Expediente" : "Nuevo Registro Médico"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Datos Personales",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 15),

              /// Nombre
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: "Nombre completo",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return "Ingrese el nombre";
                  if (RegExp(r'[0-9]').hasMatch(value))
                    return "El nombre no puede contener números";
                  return null;
                },
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  /// Edad
                  Expanded(
                    child: TextFormField(
                      controller: _edadController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Edad",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Requerido";
                        if (int.tryParse(value) == null) return "Solo números";
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),

                  /// Fecha de Alta (Solo lectura)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        "Alta: ${_fechaAlta.day}/${_fechaAlta.month}/${_fechaAlta.year}",
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              /// Teléfono
              TextFormField(
                controller: _telefonoController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Teléfono (10 dígitos)",
                  border: OutlineInputBorder(),
                  prefixText: "+52 ",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return "Ingrese el teléfono";
                  if (value.length != 10) return "Deben ser 10 dígitos";
                  if (int.tryParse(value) == null) return "Solo números";
                  return null;
                },
              ),
              const SizedBox(height: 30),

              const Text(
                "Información Clínica",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 15),

              /// Alergias
              TextFormField(
                controller: _alergiasController,
                decoration: const InputDecoration(
                  labelText: "Alergias / Advertencias",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.warning_amber, color: Colors.orange),
                ),
              ),
              const SizedBox(height: 16),

              /// Observaciones
              TextFormField(
                controller: _observacionesController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: "Observaciones y diagnóstico inicial",
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 35),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isLoading ? null : _guardarPaciente,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          isEditing
                              ? "Actualizar Expediente"
                              : "Guardar Registro Médico",
                          style: const TextStyle(fontSize: 16),
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
