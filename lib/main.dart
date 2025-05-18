import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/estadisticas_screen.dart'; // Make sure this exists

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Control de Gastos',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const HomeScreen(),
      onGenerateRoute: (settings) {
        if (settings.name == '/estadisticas') {
          final args = settings.arguments;
          return MaterialPageRoute(
            builder: (context) => EstadisticasScreen(gastos: args),
          );
        }
        // Default route
        return MaterialPageRoute(builder: (context) => const HomeScreen());
      },
    );
  }
}
