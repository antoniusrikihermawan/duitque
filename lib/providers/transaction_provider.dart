import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/transaction.dart';

class TransactionProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];
  List<Map<String, dynamic>> _categories = [];
  double _totalIncome = 0;
  double _totalExpense = 0;
  double _balance = 0;
  double _todayExpense = 0;
  double _monthlyExpense = 0;

  List<Transaction> get transactions => _transactions;
  List<Map<String, dynamic>> get categories => _categories;
  double get totalIncome => _totalIncome;
  double get totalExpense => _totalExpense;
  double get balance => _balance;
  double get todayExpense => _todayExpense;
  double get monthlyExpense => _monthlyExpense;

  TransactionProvider() {
    loadTransactions();
    loadCategories();
  }

  Future<void> loadTransactions() async {
    _transactions = await DatabaseHelper.instance.getAllTransactions();
    await _calculateTotals();
    notifyListeners();
  }

  Future<void> loadCategories() async {
    _categories = await DatabaseHelper.instance.getAllCategories();
    notifyListeners();
  }

  Future<void> _calculateTotals() async {
    _totalIncome = await DatabaseHelper.instance.getTotalIncome();
    _totalExpense = await DatabaseHelper.instance.getTotalExpense();
    _balance = _totalIncome - _totalExpense;
    _todayExpense = await DatabaseHelper.instance.getTodayExpense();
    _monthlyExpense = await DatabaseHelper.instance.getMonthlyExpense();
  }

  Future<void> addTransaction(Transaction transaction) async {
    await DatabaseHelper.instance.insertTransaction(transaction);
    await loadTransactions();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await DatabaseHelper.instance.updateTransaction(transaction);
    await loadTransactions();
  }

  Future<void> deleteTransaction(String id) async {
    await DatabaseHelper.instance.deleteTransaction(id);
    await loadTransactions();
  }

  List<Transaction> getRecentTransactions({int limit = 5}) {
    return _transactions.take(limit).toList();
  }

  List<Transaction> getTransactionsByDate(DateTime date) {
    return _transactions.where((transaction) {
      return transaction.date.year == date.year &&
          transaction.date.month == date.month &&
          transaction.date.day == date.day;
    }).toList();
  }

  List<Transaction> getTransactionsByCategory(String category) {
    return _transactions
        .where((transaction) => transaction.category == category)
        .toList();
  }

  List<Transaction> getTransactionsByType(String type) {
    return _transactions
        .where((transaction) => transaction.type == type)
        .toList();
  }

  List<MonthlySummary> getMonthlySummaries() {
    final Map<String, MonthlySummary> summaries = {};

    for (var transaction in _transactions) {
      final monthKey = '${transaction.date.year}-${transaction.date.month.toString().padLeft(2, '0')}';
      
      if (!summaries.containsKey(monthKey)) {
        summaries[monthKey] = MonthlySummary(
          month: DateTime(transaction.date.year, transaction.date.month),
          totalIncome: 0,
          totalExpense: 0,
        );
      }

      final summary = summaries[monthKey]!;
      if (transaction.type == 'income') {
        summaries[monthKey] = MonthlySummary(
          month: summary.month,
          totalIncome: summary.totalIncome + transaction.amount,
          totalExpense: summary.totalExpense,
        );
      } else {
        summaries[monthKey] = MonthlySummary(
          month: summary.month,
          totalIncome: summary.totalIncome,
          totalExpense: summary.totalExpense + transaction.amount,
        );
      }
    }

    return summaries.values.toList()
      ..sort((a, b) => b.month.compareTo(a.month));
  }

  Future<List<Map<String, dynamic>>> getCategoryStats() async {
    return await DatabaseHelper.instance.getCategorySummary();
  }
}