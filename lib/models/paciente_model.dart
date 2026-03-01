class Paciente {
  final String id;
  final String nombre;
  final String telefono;
  final String email;

  Paciente({
    required this.id,
    required this.nombre,
    required this.telefono,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return {"nombre": nombre, "telefono": telefono, "email": email};
  }

  factory Paciente.fromMap(String id, Map<String, dynamic> map) {
    return Paciente(
      id: id,
      nombre: map['nombre'] ?? '',
      telefono: map['telefono'] ?? '',
      email: map['email'] ?? '',
    );
  }
}
