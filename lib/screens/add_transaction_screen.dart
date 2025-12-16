import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../theme/app_theme.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({Key? key}) : super(key: key);

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedType = 'expense';
  String? _selectedCategory;
  String? _selectedPaymentMethod;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  final List<String> _paymentMethods = [
    'Tunai',
    'Kartu Kredit',
    'Transfer Bank',
    'E-Wallet',
    'Debit',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadCategories();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pilih kategori terlebih dahulu'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }

      final cleanAmount = _amountController.text
          .replaceAll('.', '')
          .replaceAll('Rp ', '');

      final transaction = Transaction(
        title: _titleController.text,
        amount: double.parse(cleanAmount),
        date: DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        ),
        category: _selectedCategory!,
        type: _selectedType,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        paymentMethod: _selectedPaymentMethod,
      );

      await context.read<TransactionProvider>().addTransaction(transaction);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Transaksi berhasil ditambahkan',
              style: GoogleFonts.inter(),
            ),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final categories = provider.categories
        .where((category) => category['type'] == _selectedType)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tambah Transaksi',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveTransaction,
            child: Text(
              'Simpan',
              style: GoogleFonts.inter(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Transaction Type Selector
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: Text(
                          'Pengeluaran',
                          style: GoogleFonts.inter(
                            color: _selectedType == 'expense'
                                ? Colors.white
                                : AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        selected: _selectedType == 'expense',
                        onSelected: (_) {
                          setState(() {
                            _selectedType = 'expense';
                            _selectedCategory = null;
                          });
                        },
                        selectedColor: AppTheme.errorColor,
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ChoiceChip(
                        label: Text(
                          'Pemasukan',
                          style: GoogleFonts.inter(
                            color: _selectedType == 'income'
                                ? Colors.white
                                : AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        selected: _selectedType == 'income',
                        onSelected: (_) {
                          setState(() {
                            _selectedType = 'income';
                            _selectedCategory = null;
                          });
                        },
                        selectedColor: AppTheme.successColor,
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Title Field
              Text(
                'Judul Transaksi',
                style: GoogleFonts.inter(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Contoh: Beli kopi, Bayar listrik, dll.',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul transaksi harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Amount Field
              Text(
                'Jumlah',
                style: GoogleFonts.inter(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: '0',
                  prefixText: 'Rp ',
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    final number = value
                        .replaceAll('.', '')
                        .replaceAll('Rp ', '');
                    final formatted = NumberFormat('#,###', 'id_ID')
                        .format(int.tryParse(number) ?? 0);
                    _amountController.value = _amountController.value.copyWith(
                      text: 'Rp $formatted',
                      selection: TextSelection.collapsed(
                        offset: formatted.length + 3,
                      ),
                    );
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah harus diisi';
                  }
                  final cleanValue = value
                      .replaceAll('.', '')
                      .replaceAll('Rp ', '');
                  if (double.tryParse(cleanValue) == null) {
                    return 'Masukkan angka yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Category Selection
              if (categories.isNotEmpty) ...[
                Text(
                  'Kategori',
                  style: GoogleFonts.inter(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categories.map((category) {
                    final color = Color(int.parse(
                      category['color'].replaceAll('#', '0xFF'),
                    ));
                    return ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(category['icon']),
                          const SizedBox(width: 8),
                          Text(category['name']),
                        ],
                      ),
                      selected: _selectedCategory == category['name'],
                      onSelected: (_) {
                        setState(() {
                          _selectedCategory = category['name'];
                        });
                      },
                      selectedColor: color.withOpacity(0.1),
                      backgroundColor: AppTheme.backgroundColor,
                      labelStyle: GoogleFonts.inter(
                        color: _selectedCategory == category['name']
                            ? color
                            : AppTheme.textPrimary,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: _selectedCategory == category['name']
                              ? color
                              : Colors.grey[300]!,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
              ],

              // Date and Time
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tanggal',
                          style: GoogleFonts.inter(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () => _selectDate(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('dd MMM yyyy').format(_selectedDate),
                                style: GoogleFonts.inter(
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const Icon(Icons.calendar_today, size: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Waktu',
                          style: GoogleFonts.inter(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () => _selectTime(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedTime.format(context),
                                style: GoogleFonts.inter(
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const Icon(Icons.access_time, size: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Payment Method
              Text(
                'Metode Pembayaran (Opsional)',
                style: GoogleFonts.inter(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _paymentMethods.map((method) {
                  return ChoiceChip(
                    label: Text(method),
                    selected: _selectedPaymentMethod == method,
                    onSelected: (_) {
                      setState(() {
                        _selectedPaymentMethod = method;
                      });
                    },
                    selectedColor: AppTheme.primaryColor.withOpacity(0.1),
                    backgroundColor: AppTheme.backgroundColor,
                    labelStyle: GoogleFonts.inter(
                      color: _selectedPaymentMethod == method
                          ? AppTheme.primaryColor
                          : AppTheme.textPrimary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: _selectedPaymentMethod == method
                            ? AppTheme.primaryColor
                            : Colors.grey[300]!,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Notes
              Text(
                'Catatan (Opsional)',
                style: GoogleFonts.inter(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Tambahkan catatan untuk transaksi ini...',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}