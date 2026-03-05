import 'package:cloud_firestore/cloud_firestore.dart';

class Cita {
  final String id;
  final String pacienteId;
  final String nombrePaciente;
  final String telefonoPaciente;
  final DateTime fechaHora;
  final String motivo;
  final bool recordatorioEnviado;
  final int duracionMinutos;

  Cita({
    required this.id,
    required this.pacienteId,
    required this.nombrePaciente,
    required this.telefonoPaciente,
    required this.fechaHora,
    required this.motivo,
    this.recordatorioEnviado = false,
    this.duracionMinutos = 45,
  });

  // --- NUEVOS GETTERS PARA VALIDACIÓN ---

  // Calcula la hora exacta en la que termina la cita
  DateTime get fechaHoraFin =>
      fechaHora.add(Duration(minutes: duracionMinutos));

  // Verifica si esta cita se cruza con otra cita propuesta
  bool tieneConflictoCon(DateTime otraFechaInicio, int otraDuracion) {
    final otraFechaFin = otraFechaInicio.add(Duration(minutes: otraDuracion));

    // Lógica de traslape: Una cita se encima si empieza antes de que la otra termine
    // Y termina después de que la otra empiece.
    return fechaHora.isBefore(otraFechaFin) &&
        otraFechaInicio.isBefore(fechaHoraFin);
  }

  // --- MÉTODOS EXISTENTES AJUSTADOS ---

  factory Cita.fromFirestore(Map<String, dynamic> data, String id) {
    return Cita(
      id: id,
      pacienteId: data['pacienteId'] ?? '',
      nombrePaciente: data['nombrePaciente'] ?? '',
      telefonoPaciente: data['telefonoPaciente'] ?? '',
      fechaHora: (data['fechaHora'] as Timestamp).toDate(),
      motivo: data['motivo'] ?? '',
      recordatorioEnviado: data['recordatorioEnviado'] ?? false,
      duracionMinutos: data['duracionMinutos'] ?? 45,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pacienteId': pacienteId,
      'nombrePaciente': nombrePaciente,
      'telefonoPaciente': telefonoPaciente,
      'fechaHora': Timestamp.fromDate(fechaHora),
      'motivo': motivo,
      'recordatorioEnviado': recordatorioEnviado,
      'duracionMinutos': duracionMinutos,
    };
  }

  String generarEnlaceWhatsApp() {
    final minutos = fechaHora.minute.toString().padLeft(2, '0');
    final mensaje =
        "Hola $nombrePaciente, le recordamos su cita dental el día "
        "${fechaHora.day}/${fechaHora.month} a las "
        "${fechaHora.hour}:$minutos. "
        "Por favor confirme su asistencia.";

    final telLimpio = telefonoPaciente.replaceAll(RegExp(r'[^0-9]'), '');
    return "https://wa.me/$telLimpio?text=${Uri.encodeComponent(mensaje)}";
  }
}
