import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/gasto.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(); // Fixed method name
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'gastos.db');
    return await openDatabase(path, version: 1, onCreate: _crearTabla);
  }

  Future<void> _crearTabla(Database db, int version) async {
    await db.execute('''
      CREATE TABLE gastos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        descripcion TEXT,
        categoria TEXT,
        monto REAL,
        fecha TEXT
      )
    ''');
  }

  Future<int> insertGasto(Gasto gasto) async {
    final db = await database;
    return await db.insert('gastos', gasto.toMap());
  }

  Future<List<Gasto>> obtenerGastos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('gastos');
    return List.generate(maps.length, (i) => Gasto.fromMap(maps[i]));
  }

  Future<int> updateGasto(Gasto gasto) async {
    final db = await database;
    return await db.update(
      'gastos',
      gasto.toMap(),
      where: 'id = ?',
      whereArgs: [gasto.id],
    );
  }

  Future<int> eliminarGasto(int id) async {
    final db = await database;
    return await db.delete('gastos', where: 'id = ?', whereArgs: [id]);
  }
}
