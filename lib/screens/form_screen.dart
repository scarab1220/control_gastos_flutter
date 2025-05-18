import 'package:flutter/material.dart';
import '../models/gasto.dart';

class FormScreen extends StatefulWidget {
  final Gasto? gasto; // null si es un nuevo gasto

  const FormScreen({Key? key, this.gasto}) : super(key: key);

  @override
  _FormScreenState createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _descripcionController;
  late TextEditingController _categoriaController;
  late TextEditingController _montoController;
  late TextEditingController _fechaController;

  @override
  void initState() {
    super.initState();
    _descripcionController = TextEditingController(
      text: widget.gasto?.descripcion ?? '',
    );
    _categoriaController = TextEditingController(
      text: widget.gasto?.categoria ?? '',
    );
    _montoController = TextEditingController(
      text: widget.gasto?.monto.toString() ?? '',
    );
    _fechaController = TextEditingController(
      text:
          widget.gasto?.fecha != null
              ? widget.gasto!.fecha.toIso8601String().split('T').first
              : '',
    );
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    _categoriaController.dispose();
    _montoController.dispose();
    _fechaController.dispose();
    super.dispose();
  }

  void seleccionarFecha() async {
    DateTime? fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: widget.gasto?.fecha ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: const Color(0xFF145A32), // Dark green
              onPrimary: Colors.white,
              surface: const Color(0xFF223322),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (fechaSeleccionada != null) {
      setState(() {
        _fechaController.text =
            fechaSeleccionada.toIso8601String().split('T').first;
      });
    }
  }

  void guardarFormulario() {
    if (_formKey.currentState!.validate()) {
      final nuevoGasto = Gasto(
        id: widget.gasto?.id,
        descripcion: _descripcionController.text,
        categoria: _categoriaController.text,
        monto: double.tryParse(_montoController.text) ?? 0.0,
        fecha: DateTime.parse(_fechaController.text),
      );
      Navigator.pop(context, nuevoGasto);
    }
  }

  @override
  Widget build(BuildContext context) {
    final green = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: green,
        title: Text(widget.gasto == null ? 'Agregar Gasto' : 'Editar Gasto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: guardarFormulario,
            tooltip: 'Guardar',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _descripcionController,
                  decoration: InputDecoration(
                    labelText: 'Descripción',
                    filled: true,
                    fillColor: Colors.green[900]?.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'La descripción es obligatoria';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _categoriaController,
                  decoration: InputDecoration(
                    labelText: 'Categoría',
                    filled: true,
                    fillColor: Colors.green[900]?.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'La categoría es obligatoria';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _montoController,
                  decoration: InputDecoration(
                    labelText: 'Monto',
                    filled: true,
                    fillColor: Colors.green[900]?.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El monto es obligatorio';
                    }
                    final monto = double.tryParse(value);
                    if (monto == null || monto <= 0) {
                      return 'Ingresa un monto válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _fechaController,
                  decoration: InputDecoration(
                    labelText: 'Fecha',
                    filled: true,
                    fillColor: Colors.green[900]?.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: Icon(Icons.calendar_today, color: green),
                  ),
                  style: const TextStyle(color: Colors.white),
                  readOnly: true,
                  onTap: seleccionarFecha,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'La fecha es obligatoria';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Guardar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: guardarFormulario,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
