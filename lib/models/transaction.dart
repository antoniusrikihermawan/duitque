import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final String type; // 'income' | 'expense'
  final String? notes;
  final String? paymentMethod;

  Transaction({
    String? id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.type,
    this.notes,
    this.paymentMethod,
  }) : id = id ?? const Uuid().v4();

  Transaction copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    String? category,
    String? type,
    String? notes,
    String? paymentMethod,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      type: type ?? this.type,
      notes: notes ?? this.notes,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'amount': amount,
        'date': date.toIso8601String(),
        'category': category,
        'type': type,
        'notes': notes,
        'paymentMethod': paymentMethod,
      };

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as String,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      category: map['category'] as String,
      type: map['type'] as String,
      notes: map['notes'] as String?,
      paymentMethod: map['paymentMethod'] as String?,
    );
  }

  // ================= FORMATTER =================

  String get formattedDate =>
      DateFormat('dd MMM yyyy', 'id_ID').format(date);

  String get formattedTime =>
      DateFormat('HH:mm', 'id_ID').format(date);

  String get formattedAmount =>
      'Rp ${NumberFormat('#,###', 'id_ID').format(amount)}';

  String get dayName =>
      DateFormat('EEEE', 'id_ID').format(date);
}

// =================================================

class Category {
  final String id;
  final String name;
  final String icon;
  final String color;
  final String type; // 'income' | 'expense'

  Category({
    String? id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'icon': icon,
        'color': color,
        'type': type,
      };

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as String,
      name: map['name'] as String,
      icon: map['icon'] as String,
      color: map['color'] as String,
      type: map['type'] as String,
    );
  }
}

// =================================================

class MonthlySummary {
  final DateTime month;
  final double totalIncome;
  final double totalExpense;

  const MonthlySummary({
    required this.month,
    required this.totalIncome,
    required this.totalExpense,
  });

  double get balance => totalIncome - totalExpense;
}
