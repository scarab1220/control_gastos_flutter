import 'package:flutter/material.dart';
import '../models/gasto.dart';

Class FormScreen extends StatefulWidget {
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
    _descripcionController = TextEditingController(text: widget.gasto?.descripcion ?? '');
    _categoriaController = TextEditingController(text: widget.gasto?.categoria ?? '');
    _montoController = TextEditingController(text: widget.gasto?.monto.toString() ?? '');
    _fechaController = TextEditingController(text: widget.gasto?.fecha.toString() ?? '');
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    _categoriaController.dispose();
    _montoController.dispose();
    _fechaController.dispose();
    super.dispose();
  }

  void seleccionarFecha