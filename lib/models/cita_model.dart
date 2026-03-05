import 'package:cloud_firestore/cloud_firestore.dart';

class Cita {
  final String id;
  final String pacienteId;
  final String nombrePaciente;
  final String telefonoPaciente;
  final DateTime fechaHora;
  final String motivo;
  final bool recordatorioEnviado;
  final int duracionMinutos; // Para evitar encimar citas

  Cita({
    required this.id,
    required this.pacienteId,
    required this.nombrePaciente,
    required this.telefonoPaciente,
    required this.fechaHora,
    required this.motivo,
    this.recordatorioEnviado = false,
    this.duracionMinutos = 45, // Duración estándar por defecto
  });

  // Convierte un documento de Firestore a un objeto Cita
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

  // Convierte un objeto Cita a un Map para guardar en Firestore
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

  // Método útil para generar el link de WhatsApp con mensaje personalizado
  String generarEnlaceWhatsApp() {
    final mensaje =
        "Hola $nombrePaciente, le recordamos su cita dental el día "
        "${fechaHora.day}/${fechaHora.month} a las "
        "${fechaHora.hour}:${fechaHora.minute.toString().padLeft(2, '0')}. "
        "Por favor confirme su asistencia.";

    // Limpiamos el teléfono de caracteres extraños si los hay
    final telLimpio = telefonoPaciente.replaceAll(RegExp(r'[^0-9]'), '');
    return "https://wa.me/$telLimpio?text=${Uri.encodeComponent(mensaje)}";
  }
}
