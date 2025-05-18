import 'package:flutter/material.dart';
import '../models/gasto.dart';

class FormScreen extends StatefulWidget {
  // Fixed: 'Class' to 'class'
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gasto == null ? 'Agregar Gasto' : 'Editar Gasto'),
        actions: [
          IconButton(icon: Icon(Icons.save), onPressed: guardarFormulario),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _descripcionController,
                decoration: InputDecoration(labelText: 'Descripción'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una descripción';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _categoriaController,
                decoration: InputDecoration(labelText: 'Categoría'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una categoría';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _montoController,
                decoration: InputDecoration(labelText: 'Monto'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un monto';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _fechaController,
                decoration: InputDecoration(labelText: 'Fecha'),
                readOnly: true,
                onTap: seleccionarFecha,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
