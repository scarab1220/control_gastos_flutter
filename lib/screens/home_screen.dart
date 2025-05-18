import 'package:flutter/material.dart';
import '../models/gasto.dart';
import '../database/database_helper.dart';
import 'form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Gasto> listaGastos = [];
  List<Gasto> listaFiltrada = [];
  String? categoriaSeleccionada = 'Todos';
  int mesSeleccionado = 0;

  @override
  void initState() {
    super.initState();
    _cargarGastos();
  }

  Future<void> _cargarGastos() async {
    final gastos = await DatabaseHelper().obtenerGastos();
    setState(() {
      listaGastos = gastos;
      listaFiltrada = gastos;
    });
  }

  double get totalGastos {
    return listaGastos.fold(0, (total, gasto) => total + gasto.monto);
  }

  List<String> _categoriasUnicas() {
    return listaGastos
        .map((g) => g.categoria)
        .where((cat) => cat != 'Todos')
        .toSet()
        .toList();
  }

  String _nombreMes(int numero) {
    const meses = [
      '',
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return meses[numero];
  }

  void _aplicarFiltros() {
    setState(() {
      listaFiltrada =
          listaGastos.where((g) {
            final coincideCategoria =
                categoriaSeleccionada == 'Todos' ||
                g.categoria == categoriaSeleccionada;
            final coincideMes =
                mesSeleccionado == 0 || g.fecha.month == mesSeleccionado;
            return coincideCategoria && coincideMes;
          }).toList();
    });
  }

  void _confirmarEliminacion(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar Gasto'),
          content: const Text(
            '¿Estás seguro de que deseas eliminar este gasto?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final gasto = listaFiltrada[index];
                final id = gasto.id;
                if (id != null) {
                  await DatabaseHelper().eliminarGasto(id);
                  await _cargarGastos();
                }
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gastos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final nuevoGasto = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FormScreen()),
              );
              if (nuevoGasto != null && nuevoGasto is Gasto) {
                await DatabaseHelper().insertGasto(nuevoGasto);
                await _cargarGastos();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.pie_chart),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/estadisticas',
                arguments: listaGastos,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Row(
              children: [
                // Filtro de categoría
                Expanded(
                  child: DropdownButton<String>(
                    value: categoriaSeleccionada,
                    items:
                        ['Todos', ..._categoriasUnicas()].map((cat) {
                          return DropdownMenuItem(value: cat, child: Text(cat));
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        categoriaSeleccionada = value;
                        _aplicarFiltros();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // Filtro de mes
                DropdownButton<int>(
                  value: mesSeleccionado,
                  onChanged: (valor) {
                    setState(() {
                      mesSeleccionado = valor!;
                      _aplicarFiltros();
                    });
                  },
                  items: [
                    const DropdownMenuItem(value: 0, child: Text('Todos')),
                    ...List.generate(12, (i) {
                      final mesNombre = _nombreMes(i + 1);
                      return DropdownMenuItem(
                        value: i + 1,
                        child: Text(mesNombre),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Total Gastos: \$${totalGastos.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 24.0),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: listaFiltrada.length,
              itemBuilder: (context, index) {
                final gasto = listaFiltrada[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  child: ListTile(
                    title: Text(gasto.descripcion),
                    subtitle: Text(
                      '${gasto.categoria} - \$${gasto.monto.toStringAsFixed(2)}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmarEliminacion(index),
                    ),
                    onTap: () async {
                      final gastoEditado = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FormScreen(gasto: gasto),
                        ),
                      );
                      if (gastoEditado != null && gastoEditado is Gasto) {
                        await DatabaseHelper().updateGasto(gastoEditado);
                        await _cargarGastos();
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
