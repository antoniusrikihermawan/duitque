import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart';
import '../models/transaction.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static sql.Database? _database;

  DatabaseHelper._init();

  Future<sql.Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('finance_tracker.db');
    return _database!;
  }

  Future<sql.Database> _initDB(String filePath) async {
    final dbPath = await sql.getDatabasesPath();
    final path = join(dbPath, filePath);

    return await sql.openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(sql.Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon TEXT NOT NULL,
        color TEXT NOT NULL,
        type TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        category TEXT NOT NULL,
        type TEXT NOT NULL,
        notes TEXT,
        paymentMethod TEXT
      )
    ''');

    await _insertDefaultCategories(db);
  }

  Future _insertDefaultCategories(sql.Database db) async {
    final defaultCategories = [
      {'name': 'Gaji', 'icon': '💰', 'color': '#4CAF50', 'type': 'income'},
      {'name': 'Investasi', 'icon': '📈', 'color': '#2196F3', 'type': 'income'},
      {'name': 'Hadiah', 'icon': '🎁', 'color': '#9C27B0', 'type': 'income'},
      {'name': 'Makanan', 'icon': '🍔', 'color': '#FF9800', 'type': 'expense'},
      {'name': 'Transportasi', 'icon': '🚗', 'color': '#3F51B5', 'type': 'expense'},
      {'name': 'Belanja', 'icon': '🛍️', 'color': '#E91E63', 'type': 'expense'},
      {'name': 'Hiburan', 'icon': '🎬', 'color': '#00BCD4', 'type': 'expense'},
      {'name': 'Kesehatan', 'icon': '💊', 'color': '#F44336', 'type': 'expense'},
      {'name': 'Pendidikan', 'icon': '📚', 'color': '#795548', 'type': 'expense'},
      {'name': 'Tagihan', 'icon': '🧾', 'color': '#607D8B', 'type': 'expense'},
    ];

    for (var category in defaultCategories) {
      await db.insert('categories', category);
    }
  }

  // ================= TRANSACTION =================

  Future<int> insertTransaction(Transaction transaction) async {
    final db = await instance.database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<List<Transaction>> getAllTransactions() async {
    final db = await instance.database;
    final maps = await db.query('transactions', orderBy: 'date DESC');
    return maps.map((e) => Transaction.fromMap(e)).toList();
  }

  Future<List<Transaction>> getTransactionsByDate(DateTime date) async {
    final db = await instance.database;
    final start = DateTime(date.year, date.month, date.day);
    final end = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final maps = await db.query(
      'transactions',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC',
    );

    return maps.map((e) => Transaction.fromMap(e)).toList();
  }

  Future<int> updateTransaction(Transaction transaction) async {
    final db = await instance.database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(String id) async {
    final db = await instance.database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<double> getTodayExpense() async {
    final db = await database;

    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day).toIso8601String();
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59).toIso8601String();

    final result = await db.rawQuery('''
      SELECT SUM(amount) as total
      FROM transactions
      WHERE type = 'expense'
      AND date BETWEEN ? AND ?
    ''', [startOfDay, endOfDay]);

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getMonthlyExpense() async {
    final db = await database;

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1).toIso8601String();
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59).toIso8601String();

    final result = await db.rawQuery('''
      SELECT SUM(amount) as total
      FROM transactions
      WHERE type = 'expense'
      AND date BETWEEN ? AND ?
    ''', [startOfMonth, endOfMonth]);

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }


  // ================= CATEGORY =================

  Future<List<Map<String, dynamic>>> getAllCategories() async {
    final db = await instance.database;
    return await db.query('categories');
  }

  Future<List<Map<String, dynamic>>> getCategoriesByType(String type) async {
    final db = await instance.database;
    return await db.query('categories', where: 'type = ?', whereArgs: [type]);
  }

  // ================= STATISTICS =================

  Future<double> _getSum(String where) async {
    final db = await instance.database;
    final result = await db.rawQuery(
      "SELECT SUM(amount) as total FROM transactions WHERE $where",
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getTotalIncome() => _getSum("type = 'income'");
  Future<double> getTotalExpense() => _getSum("type = 'expense'");
  Future<double> getBalance() async => await getTotalIncome() - await getTotalExpense();

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }

  Future<List<Map<String, dynamic>>> getCategorySummary() async {
    final db = await database;

    return await db.rawQuery('''
      SELECT category, SUM(amount) as total
      FROM transactions
      WHERE type = 'expense'
      GROUP BY category
      ORDER BY total DESC
    ''');
  }

}
