import 'package:shared_preferences/shared_preferences.dart';

class LimiteHelper {
  static const String claveLimite = 'limite_mensual';

  static Future<void> guardarLimite(double monto) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(claveLimite, monto);
  }

  static Future<double> obtenerLimite() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(claveLimite) ?? 0.0;
  }
}
