import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/debt.dart';
import '../theme/app_theme.dart';

class DebtCard extends StatelessWidget {
  final Debt debt;
  final VoidCallback onTap;

  const DebtCard({
    Key? key,
    required this.debt,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = debt.paidAmount / debt.amount;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: debt.isPaidOff 
                ? AppTheme.successColor.withOpacity(0.3)
                : Colors.orange.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: debt.isPaidOff
                        ? AppTheme.successColor.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    debt.isPaidOff ? Icons.check_circle : Icons.account_balance_wallet,
                    color: debt.isPaidOff ? AppTheme.successColor : Colors.orange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        debt.creditorName,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        DateFormat('dd MMM yyyy', 'id_ID').format(debt.borrowDate),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Rp ${NumberFormat('#,###', 'id_ID').format(debt.remainingAmount)}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: debt.isPaidOff ? AppTheme.successColor : Colors.orange,
                      ),
                    ),
                    if (debt.dueDate != null && !debt.isPaidOff)
                      Text(
                        '${debt.daysUntilDue} hari lagi',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: debt.daysUntilDue < 0
                              ? AppTheme.errorColor 
                              : debt.daysUntilDue < 7 
                                ? Colors.orange 
                                : AppTheme.textSecondary,
                          fontWeight: debt.daysUntilDue < 7 
                              ? FontWeight.w600 
                              : FontWeight.normal,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            if (!debt.isPaidOff) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress > 0.7 ? AppTheme.successColor : Colors.orange,
                  ),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Terbayar ${(progress * 100).toStringAsFixed(0)}%',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  Text(
                    'Total: Rp ${NumberFormat('#,###', 'id_ID').format(debt.amount)}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '✓ Lunas',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.successColor,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}