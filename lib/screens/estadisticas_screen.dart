import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class EstadisticasScreen extends StatelessWidget {
  final dynamic gastos;
  const EstadisticasScreen({Key? key, this.gastos}) : super(key: key);

  Map<String, double> _agruparPorCategoria() {
    final mapa = <String, double>{};
    for (var gasto in gastos) {
      mapa[gasto.categoria] = (mapa[gasto.categoria] ?? 0) + gasto.monto;
    }
    return mapa;
  }

  @override
  Widget build(BuildContext context) {
    final datos = _agruparPorCategoria();
    final total = datos.values.fold(0.0, (sum, val) => sum + val);

    final List<PieChartSectionData> secciones = [];
    final colores = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.brown,
    ];

    int i = 0;
    datos.forEach((categoria, monto) {
      secciones.add(
        PieChartSectionData(
          color: colores[i % colores.length],
          value: monto,
          title: '${(monto / total * 100).toStringAsFixed(1)}%',
          radius: 80,
          titleStyle: const TextStyle(fontSize: 14, color: Colors.white),
        ),
      );
      i++;
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas por Categoría')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: secciones,
                  centerSpaceRadius: 50,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ...datos.entries.map(
              (entry) => ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      colores[datos.keys.toList().indexOf(entry.key) %
                          colores.length],
                ),
                title: Text(entry.key),
                trailing: Text('\$${entry.value.toStringAsFixed(2)}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
