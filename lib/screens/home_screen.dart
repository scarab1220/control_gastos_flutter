import 'package:flutter/material.dart';
import '../models/gasto.dart';

class HomeScreen extends StatefulWidget {
  // Changed to StatefulWidget
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Lista de gastos
  List<Gasto> gastos = [
    Gasto(
      id: 1,
      descripcion: 'Compra de comida',
      categoria: 'Alimentación',
      monto: 50.0,
      fecha: DateTime.now(),
    ),
    Gasto(
      id: 2,
      descripcion: 'Pago de alquiler',
      categoria: 'Vivienda',
      monto: 800.0,
      fecha: DateTime.now(),
    ),
    Gasto(
      id: 3,
      descripcion: 'Gasolina',
      categoria: 'Transporte',
      monto: 30.0,
      fecha: DateTime.now(),
    ),
    Gasto(
      id: 4,
      descripcion: 'Compra de ropa',
      categoria: 'Ropa',
      monto: 100.0,
      fecha: DateTime.now(),
    ),
    Gasto(
      id: 5,
      descripcion: 'Cine',
      categoria: 'Entretenimiento',
      monto: 20.0,
      fecha: DateTime.now(),
    ),
  ];

  double get totalGastos {
    // Changed Double to double
    return gastos.fold(0, (total, gasto) => total + gasto.monto);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gastos'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Navegar a la pantalla de agregar gasto
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Total Gastos: \$${totalGastos.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 24.0),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: gastos.length,
              itemBuilder: (context, index) {
                final gasto = gastos[index];
                return ListTile(
                  title: Text(gasto.descripcion),
                  subtitle: Text(gasto.categoria),
                  trailing: Text('\$${gasto.monto.toStringAsFixed(2)}'),
                  onTap: () {
                    // Navegar a la pantalla de detalles del gasto
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
