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

  final List<String> categoriasPredefinidas = [
    'Comida',
    'Transporte',
    'Salud',
    'Entretenimiento',
    'Educación',
    'Hogar',
    'Otros',
  ];

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
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF43A047), // Light green
              onPrimary: Colors.white,
              surface: const Color(0xFFE8F5E9),
              onSurface: Colors.black,
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
    final surface = Theme.of(context).colorScheme.surface;
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
                    fillColor: surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  style: const TextStyle(color: Colors.black),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'La descripción es obligatoria';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _categoriaController.text.isNotEmpty
                      ? _categoriaController.text
                      : null,
                  decoration: InputDecoration(
                    labelText: 'Categoría',
                    filled: true,
                    fillColor: surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: [
                    ...categoriasPredefinidas.map(
                      (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                    ),
                    const DropdownMenuItem(
                      value: 'agregar',
                      child: Text('Agregar categoría...'),
                    ),
                  ],
                  onChanged: (value) async {
                    if (value == 'agregar') {
                      final nuevaCategoria = await showDialog<String>(
                        context: context,
                        builder: (context) {
                          final controller = TextEditingController();
                          return AlertDialog(
                            title: const Text('Nueva categoría'),
                            content: TextField(
                              controller: controller,
                              decoration: const InputDecoration(
                                labelText: 'Nombre de la categoría',
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () {
                                  final text = controller.text.trim();
                                  if (text.isNotEmpty) {
                                    Navigator.pop(context, text);
                                  }
                                },
                                child: const Text('Agregar'),
                              ),
                            ],
                          );
                        },
                      );
                      if (nuevaCategoria != null && nuevaCategoria.isNotEmpty) {
                        setState(() {
                          _categoriaController.text = nuevaCategoria;
                        });
                      }
                    } else if (value != null) {
                      setState(() {
                        _categoriaController.text = value;
                      });
                    }
                  },
                  validator: (value) {
                    if (_categoriaController.text.trim().isEmpty) {
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
                    fillColor: surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  style: const TextStyle(color: Colors.black),
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
                    fillColor: surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: Icon(Icons.calendar_today, color: green),
                  ),
                  style: const TextStyle(color: Colors.black),
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
