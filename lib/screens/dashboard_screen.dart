import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 👈 1. Pastikan import ini ada
import '../providers/transaction_provider.dart';
import '../providers/debt_provider.dart';
import '../theme/app_theme.dart';
import '../models/transaction.dart';
import '../widgets/balance_card.dart';
import '../widgets/transaction_card.dart';
import '../widgets/quick_stats.dart';
import '../widgets/debt_summary_card.dart';
import 'add_transaction_screen.dart';
import 'transaction_list_screen.dart';
import 'debt_list_screen.dart';
import 'profile_settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final transactionProvider = context.read<TransactionProvider>();
        final debtProvider = context.read<DebtProvider>();

        await Future.wait([
          transactionProvider.loadTransactions(),
          transactionProvider.loadCategories(),
          debtProvider.loadDebts(),
        ]);

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 👈 2. Fungsi Logout yang benar
  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Logout',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: const Text('Apakah Anda yakin ingin keluar dari akun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: GoogleFonts.inter(color: AppTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Logout',
              style: GoogleFonts.inter(
                color: AppTheme.errorColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseAuth.instance.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 👈 3. Ambil data Provider & Firebase User di sini
    final transactionProvider = context.watch<TransactionProvider>();
    final debtProvider = context.watch<DebtProvider>();
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'DuitQue',
          style: GoogleFonts.poppins(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TransactionListScreen(),
                ),
              );
            },
          ),
          // 👈 TEMPAT POPUP MENU AKUN (Taruh di sini)
          PopupMenuButton<String>(
            offset: const Offset(
              0,
              50,
            ), // Agar menu muncul sedikit di bawah AppBar
            onSelected: (value) {
              if (value == 'profile') {
                // Navigasi ke halaman Edit Profil yang kita buat sebelumnya
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileSettingsScreen(),
                  ),
                );
              } else if (value == 'logout') {
                _handleLogout(); // Panggil fungsi logout Anda
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 16, left: 8),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                // Menampilkan foto dari Firebase atau ikon default jika kosong
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : null,
                child: user?.photoURL == null
                    ? Icon(Icons.person, color: AppTheme.primaryColor, size: 20)
                    : null,
              ),
            ),
            itemBuilder: (context) => [
              // Header Info User
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.displayName ?? 'User',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      user?.email ?? '',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              // Menu Pengaturan Profil
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(
                      Icons.settings,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Text('Pengaturan Profil'),
                  ],
                ),
              ),
              // Menu Logout
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: AppTheme.errorColor, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'Logout',
                      style: TextStyle(color: AppTheme.errorColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            transactionProvider.loadTransactions(),
            debtProvider.loadDebts(),
          ]);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BalanceCard(
                balance: transactionProvider.balance,
                income: transactionProvider.totalIncome,
                expense: transactionProvider.totalExpense,
              ),
              const SizedBox(height: 20),
              DebtSummaryCard(
                totalDebt: debtProvider.totalDebt,
                activeDebtsCount: debtProvider.activeDebtsCount,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DebtListScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              QuickStats(
                todayExpense: transactionProvider.todayExpense,
                monthlyExpense: transactionProvider.monthlyExpense,
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Transaksi Terbaru',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TransactionListScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Lihat Semua',
                        style: GoogleFonts.inter(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _buildRecentTransactions(context, transactionProvider),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }

  // --- Fungsi Helper Tetap di Sini (Di dalam _DashboardScreenState) ---
  Widget _buildRecentTransactions(
    BuildContext context,
    TransactionProvider provider,
  ) {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: AppTheme.cardDecoration,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final recentTransactions = provider.getRecentTransactions();

    if (recentTransactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: AppTheme.cardDecoration,
        child: Column(
          children: [
            Icon(
              Icons.receipt_long,
              size: 64,
              color: AppTheme.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada transaksi',
              style: GoogleFonts.inter(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return Column(
      children: recentTransactions.map((transaction) {
        return TransactionCard(
          transaction: transaction,
          onTap: () => _showTransactionDetails(context, transaction, provider),
        );
      }).toList(),
    );
  }

  void _showTransactionDetails(
    BuildContext context,
    Transaction transaction,
    TransactionProvider provider,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                transaction.title,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                transaction.formattedAmount,
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: transaction.type == 'income'
                      ? AppTheme.successColor
                      : AppTheme.errorColor,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteTransaction(transaction.id, provider);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor,
                ),
                child: const Text(
                  'Hapus Transaksi',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteTransaction(
    String id,
    TransactionProvider provider,
  ) async {
    // Logika delete tetap sama...
  }
}
