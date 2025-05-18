import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/estadisticas_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Control de Gastos',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF145A32), // Dark green
        scaffoldBackgroundColor: const Color(0xFF1B2E20),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF145A32), // Dark green
          secondary: const Color(0xFF229954), // Lighter green
          background: const Color(0xFF1B2E20),
          surface: const Color(0xFF223322),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF145A32),
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF229954),
        ),
      ),
      home: const HomeScreen(),
      onGenerateRoute: (settings) {
        if (settings.name == '/estadisticas') {
          final args = settings.arguments;
          return MaterialPageRoute(
            builder: (context) => EstadisticasScreen(gastos: args),
          );
        }
        return MaterialPageRoute(builder: (context) => const HomeScreen());
      },
    );
  }
}
