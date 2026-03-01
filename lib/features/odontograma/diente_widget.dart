import 'package:flutter/material.dart';
import 'estado_diente.dart';

class DienteWidget extends StatefulWidget {
  final String numero;
  final EstadoDiente estadoInicial;
  final Function(String numero, EstadoDiente estado) onChanged;

  const DienteWidget({
    super.key,
    required this.numero,
    required this.estadoInicial,
    required this.onChanged,
  });

  @override
  State<DienteWidget> createState() => _DienteWidgetState();
}

class _DienteWidgetState extends State<DienteWidget> {
  late EstadoDiente estado;

  @override
  void initState() {
    super.initState();
    // Inicializamos el estado interno con el valor que viene de Firebase
    estado = widget.estadoInicial;
  }

  // Actualizamos el estado interno si el widget padre cambia (ej. al cargar datos)
  @override
  void didUpdateWidget(covariant DienteWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.estadoInicial != widget.estadoInicial) {
      setState(() {
        estado = widget.estadoInicial;
      });
    }
  }

  void cambiarEstado() {
    setState(() {
      // Cicla entre los estados definidos en el enum EstadoDiente
      estado =
          EstadoDiente.values[(EstadoDiente.values.indexOf(estado) + 1) %
              EstadoDiente.values.length];
    });

    // Notifica al OdontogramaPage para que guarde en Firebase
    widget.onChanged(widget.numero, estado);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: cambiarEstado,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              // Usamos el color definido en tu enum
              color: Color(estado.colorValue),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                widget.numero,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  // Opcional: podrías cambiar el color del texto según el fondo
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Aquí podrías agregar un pequeño texto con el nombre del estado si quisieras
        ],
      ),
    );
  }
}
