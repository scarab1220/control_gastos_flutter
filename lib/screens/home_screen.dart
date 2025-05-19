import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/gasto.dart';
import '../database/database_helper.dart';
import 'form_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LimiteHelper {
  static const String _limiteKey = 'limite_mensual';

  static Future<void> guardarLimite(double limite) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_limiteKey, limite);
  }

  static Future<double> obtenerLimite() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_limiteKey) ?? 0.0;
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Gasto> listaGastos = [];
  List<Gasto> listaFiltrada = [];
  String categoriaSeleccionada = 'Todos'; // <-- Not nullable
  int mesSeleccionado = 0;

  @override
  void initState() {
    super.initState();
    _cargarGastos();
  }

  Future<void> _verificarLimite() async {
    final limite = await LimiteHelper.obtenerLimite();
    final mesActual = DateTime.now().month;

    final totalMes = listaGastos
        .where((g) => g.fecha.month == mesActual)
        .fold(0.0, (sum, g) => sum + g.monto);

    if (limite > 0 && totalMes > limite) {
      // Alerta si se supera el límite
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '¡Has superado tu límite mensual de \$${limite.toStringAsFixed(2)}!',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _cargarGastos() async {
    final gastos = await DatabaseHelper().obtenerGastos();
    setState(() {
      listaGastos = gastos;
      listaFiltrada = gastos;
    });
    await _verificarLimite(); // <-- Add this
  }

  double get totalGastos {
    // Show total of filtered gastos
    return listaFiltrada.fold(0, (total, gasto) => total + gasto.monto);
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
    listaFiltrada =
        listaGastos.where((g) {
          final coincideCategoria =
              categoriaSeleccionada == 'Todos' ||
              g.categoria == categoriaSeleccionada;
          final coincideMes =
              mesSeleccionado == 0 || g.fecha.month == mesSeleccionado;
          return coincideCategoria && coincideMes;
        }).toList();
    setState(() {});
  }

  void _mostrarDialogoLimite() async {
    final currentLimite = await LimiteHelper.obtenerLimite();
    final controller = TextEditingController(
      text: currentLimite > 0 ? currentLimite.toStringAsFixed(2) : '',
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Establecer Límite Mensual'),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Monto en \$'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final monto = double.tryParse(controller.text) ?? 0;
                  await LimiteHelper.guardarLimite(monto);
                  Navigator.pop(context);
                  await _verificarLimite();
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final green = Theme.of(context).colorScheme.primary;
    final surface = Theme.of(context).colorScheme.surface;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: green,
        title: const Text(
          'Gastos App',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.2,
            color: Colors.white, // Ensure readable on green
          ),
        ),
        actions: [
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
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: 'limite',
                    child: const Text('Establecer Límite Mensual'),
                  ),
                ],
            onSelected: (value) {
              if (value == 'limite') {
                _mostrarDialogoLimite();
              }
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
                      if (value != null) {
                        categoriaSeleccionada = value;
                        _aplicarFiltros();
                      }
                    },
                    dropdownColor: surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 16),
                // Filtro de mes
                DropdownButton<int>(
                  value: mesSeleccionado,
                  onChanged: (valor) {
                    if (valor != null) {
                      mesSeleccionado = valor;
                      _aplicarFiltros();
                    }
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
                  dropdownColor: surface,
                  borderRadius: BorderRadius.circular(8),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Total Gastos: \$${totalGastos.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
                color: green,
              ),
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child:
                  listaFiltrada.isEmpty
                      ? Center(
                        key: const ValueKey('empty'),
                        child: Text(
                          'No hay gastos registrados.',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      )
                      : RefreshIndicator(
                        onRefresh: _cargarGastos,
                        child: ListView.builder(
                          key: const ValueKey('list'),
                          itemCount: listaFiltrada.length,
                          itemBuilder: (context, index) {
                            final gasto = listaFiltrada[index];
                            return TweenAnimationBuilder<double>(
                              duration: const Duration(milliseconds: 400),
                              tween: Tween(begin: 0, end: 1),
                              builder:
                                  (context, value, child) => Opacity(
                                    opacity: value,
                                    child: Transform.translate(
                                      offset: Offset(0, 30 * (1 - value)),
                                      child: child,
                                    ),
                                  ),
                              child: Card(
                                color: surface,
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                  horizontal: 16.0,
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: green,
                                    child: const Icon(
                                      Icons.attach_money,
                                      color: Colors.white,
                                    ),
                                  ),
                                  title: Text(
                                    gasto.descripcion,
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                  subtitle: Text(
                                    '${gasto.categoria} - ${DateFormat('dd/MM/yyyy').format(gasto.fecha)}',
                                    style: TextStyle(color: Colors.green[900]),
                                  ),
                                  trailing: Text(
                                    '\$${gasto.monto.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF388E3C), // Dark green
                                      fontSize: 16,
                                    ),
                                  ),
                                  onTap: () async {
                                    final gastoEditado = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                FormScreen(gasto: gasto),
                                      ),
                                    );
                                    if (gastoEditado != null &&
                                        gastoEditado is Gasto) {
                                      await DatabaseHelper().updateGasto(
                                        gastoEditado,
                                      );
                                      await _cargarGastos();
                                      await _verificarLimite();
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: green,
        child: const Icon(Icons.add),
        onPressed: () async {
          final nuevoGasto = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FormScreen()),
          );
          if (nuevoGasto != null && nuevoGasto is Gasto) {
            await DatabaseHelper().insertGasto(nuevoGasto);
            await _cargarGastos();
            await _verificarLimite(); // <-- Add this
          }
        },
      ),
    );
  }
}
