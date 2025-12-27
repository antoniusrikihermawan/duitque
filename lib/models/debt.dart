import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class Debt {
  final String id;
  final String creditorName;
  final double amount;
  final double paidAmount;
  final DateTime borrowDate;
  final DateTime? dueDate;
  final String? notes;
  final String? category;
  final List<DebtPayment> payments;

  Debt({
    String? id,
    required this.creditorName,
    required this.amount,
    this.paidAmount = 0,
    required this.borrowDate,
    this.dueDate,
    this.notes,
    this.category,
    this.payments = const [],
  }) : id = id ?? const Uuid().v4();

  double get remainingAmount => amount - paidAmount;
  bool get isPaidOff => remainingAmount <= 0;
  
  int get daysUntilDue {
    if (dueDate == null) return 0;
    return dueDate!.difference(DateTime.now()).inDays;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'creditorName': creditorName,
    'amount': amount,
    'paidAmount': paidAmount,
    'borrowDate': borrowDate.toIso8601String(),
    'dueDate': dueDate?.toIso8601String(),
    'notes': notes,
    'category': category,
    'payments': payments.map((p) => p.toJson()).toList(),
  };

  factory Debt.fromJson(Map<String, dynamic> json) => Debt(
    id: json['id'],
    creditorName: json['creditorName'],
    amount: json['amount'],
    paidAmount: json['paidAmount'] ?? 0,
    borrowDate: DateTime.parse(json['borrowDate']),
    dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
    notes: json['notes'],
    category: json['category'],
    payments: (json['payments'] as List?)?.map((p) => DebtPayment.fromJson(p)).toList() ?? [],
  );
}

class DebtPayment {
  final String id;
  final double amount;
  final DateTime date;
  final String? notes;

  DebtPayment({
    String? id,
    required this.amount,
    required this.date,
    this.notes,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'date': date.toIso8601String(),
    'notes': notes,
  };

  factory DebtPayment.fromJson(Map<String, dynamic> json) => DebtPayment(
    id: json['id'],
    amount: json['amount'],
    date: DateTime.parse(json['date']),
    notes: json['notes'],
  );
}