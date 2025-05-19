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
        brightness: Brightness.light,
        primaryColor: const Color(0xFF43A047), // Light green
        scaffoldBackgroundColor: const Color(0xFFE8F5E9), // Very light green
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF43A047), // Light green
          secondary: const Color(0xFF81C784), // Lighter green
          background: const Color(0xFFE8F5E9),
          surface: const Color(0xFFC8E6C9),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF43A047),
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF81C784),
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
