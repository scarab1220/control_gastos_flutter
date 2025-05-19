import 'package:shared_preferences/shared_preferences.dart';

class LimiteHelper {
  static const String _keyLimite = 'limite_mensual';

  static Future<void> guardarLimite(double monto) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyLimite, monto);
  }

  static Future<double> obtenerLimite() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyLimite) ?? 0.0;
  }
}
