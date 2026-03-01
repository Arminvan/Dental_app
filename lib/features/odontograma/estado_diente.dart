enum EstadoDiente { sano, caries, endodoncia, ausente, protesis }

extension EstadoDienteColor on EstadoDiente {
  int get colorValue {
    switch (this) {
      case EstadoDiente.sano:
        return 0xFFFFFFFF;
      case EstadoDiente.caries:
        return 0xFFE53935;
      case EstadoDiente.endodoncia:
        return 0xFFFFB300;
      case EstadoDiente.ausente:
        return 0xFF9E9E9E;
      case EstadoDiente.protesis:
        return 0xFF1E88E5;
    }
  }
}
