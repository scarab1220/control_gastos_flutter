import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/gasto.dart';
import '../database/database_helper.dart';
import 'form_screen.dart';
import '../utils/limite_helper.dart';

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
    final categoriasGastos =
        listaGastos
            .map((g) => g.categoria)
            .where((cat) => cat != 'Todos')
            .toSet();
    return [
      ...categoriasPredefinidas,
      ...categoriasGastos.where((cat) => !categoriasPredefinidas.contains(cat)),
    ];
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
                    items: [
                      const DropdownMenuItem(
                        value: 'Todos',
                        child: Text('Todos'),
                      ),
                      ..._categoriasUnicas().map(
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
                        if (nuevaCategoria != null &&
                            nuevaCategoria.isNotEmpty) {
                          setState(() {
                            categoriaSeleccionada = nuevaCategoria;
                          });
                          _aplicarFiltros();
                        }
                      } else if (value != null) {
                        setState(() {
                          categoriaSeleccionada = value;
                        });
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
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '\$${gasto.monto.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF388E3C),
                                          fontSize: 16,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () async {
                                          try {
                                            final confirm = await showDialog<
                                              bool
                                            >(
                                              context: context,
                                              builder:
                                                  (context) => AlertDialog(
                                                    title: const Text(
                                                      'Eliminar gasto',
                                                    ),
                                                    content: const Text(
                                                      '¿Estás seguro de que deseas eliminar este gasto?',
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed:
                                                            () => Navigator.pop(
                                                              context,
                                                              false,
                                                            ),
                                                        child: const Text(
                                                          'Cancelar',
                                                        ),
                                                      ),
                                                      TextButton(
                                                        onPressed:
                                                            () => Navigator.pop(
                                                              context,
                                                              true,
                                                            ),
                                                        child: const Text(
                                                          'Eliminar',
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                            );
                                            if (confirm == true &&
                                                gasto.id != null) {
                                              await DatabaseHelper()
                                                  .eliminarGasto(gasto.id!);
                                              await _cargarGastos();
                                              await _verificarLimite();
                                            }
                                          } catch (e) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Error al eliminar gasto: $e',
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ],
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
