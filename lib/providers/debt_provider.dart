import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/debt.dart';

class DebtProvider extends ChangeNotifier {
  List<Debt> _debts = [];
  
  List<Debt> get debts => _debts;
  List<Debt> get activeDebts => _debts.where((d) => !d.isPaidOff).toList();
  
  double get totalDebt => activeDebts.fold(0, (sum, debt) => sum + debt.remainingAmount);
  int get activeDebtsCount => activeDebts.length;

  DebtProvider() {
    loadDebts();
  }

  Future<void> loadDebts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final debtsJson = prefs.getStringList('debts') ?? [];
      _debts = debtsJson.map((json) => Debt.fromJson(jsonDecode(json))).toList();
      _debts.sort((a, b) => b.borrowDate.compareTo(a.borrowDate));
      notifyListeners();
    } catch (e) {
      print('Error loading debts: $e');
      _debts = [];
      notifyListeners();
    }
  }

  Future<void> addDebt(Debt debt) async {
    _debts.add(debt);
    await _saveDebts();
    notifyListeners();
  }

  Future<void> addPayment(String debtId, DebtPayment payment) async {
    final debtIndex = _debts.indexWhere((d) => d.id == debtId);
    if (debtIndex != -1) {
      final debt = _debts[debtIndex];
      final updatedPayments = [...debt.payments, payment];
      final updatedPaidAmount = debt.paidAmount + payment.amount;
      
      _debts[debtIndex] = Debt(
        id: debt.id,
        creditorName: debt.creditorName,
        amount: debt.amount,
        paidAmount: updatedPaidAmount,
        borrowDate: debt.borrowDate,
        dueDate: debt.dueDate,
        notes: debt.notes,
        category: debt.category,
        payments: updatedPayments,
      );
      
      await _saveDebts();
      notifyListeners();
    }
  }

  Future<void> deleteDebt(String id) async {
    _debts.removeWhere((debt) => debt.id == id);
    await _saveDebts();
    notifyListeners();
  }

  Future<void> _saveDebts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final debtsJson = _debts.map((debt) => jsonEncode(debt.toJson())).toList();
      await prefs.setStringList('debts', debtsJson);
    } catch (e) {
      print('Error saving debts: $e');
    }
  }

  List<Debt> getOverdueDebts() {
    final now = DateTime.now();
    return _debts.where((debt) {
      if (debt.isPaidOff || debt.dueDate == null) return false;
      return debt.dueDate!.isBefore(now);
    }).toList();
  }

  List<Debt> getUpcomingDebts() {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));
    return _debts.where((debt) {
      if (debt.isPaidOff || debt.dueDate == null) return false;
      return debt.dueDate!.isAfter(now) && debt.dueDate!.isBefore(nextWeek);
    }).toList();
  }
}