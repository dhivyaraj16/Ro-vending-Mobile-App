import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/models.dart';
import '../../utils/app_theme.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().userModel;
      if (user != null) {
        context.read<TransactionProvider>().fetchTransactions(user.uid);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final txProvider = context.watch<TransactionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Water'),
            Tab(text: 'Recharge'),
          ],
        ),
      ),
      body: txProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _TransactionList(transactions: txProvider.transactions),
                _TransactionList(
                    transactions: txProvider.transactions
                        .where((t) => t.type == TransactionType.waterPurchase)
                        .toList()),
                _TransactionList(
                    transactions: txProvider.transactions
                        .where((t) => t.type == TransactionType.walletTopup)
                        .toList()),
              ],
            ),
    );
  }
}

class _TransactionList extends StatelessWidget {
  final List<TransactionModel> transactions;
  const _TransactionList({required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: AppTheme.textGrey),
            SizedBox(height: 16),
            Text('No transactions', style: TextStyle(color: AppTheme.textGrey)),
          ],
        ),
      );
    }

    // Group by date
    final grouped = <String, List<TransactionModel>>{};
    for (final tx in transactions) {
      final date = '${tx.createdAt.day}/${tx.createdAt.month}/${tx.createdAt.year}';
      grouped.putIfAbsent(date, () => []).add(tx);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final date = grouped.keys.elementAt(index);
        final txList = grouped[date]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                date,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textGrey,
                  fontSize: 13,
                ),
              ),
            ),
            ...txList.map((tx) => _TxCard(tx: tx)),
          ],
        );
      },
    );
  }
}

class _TxCard extends StatelessWidget {
  final TransactionModel tx;
  const _TxCard({required this.tx});

  @override
  Widget build(BuildContext context) {
    final isDebit = tx.type == TransactionType.waterPurchase;
    final isRefund = tx.type == TransactionType.refund;

    Color iconColor;
    IconData icon;
    if (tx.type == TransactionType.walletTopup) {
      iconColor = AppTheme.success;
      icon = Icons.account_balance_wallet;
    } else if (tx.type == TransactionType.refund) {
      iconColor = AppTheme.warning;
      icon = Icons.undo;
    } else {
      iconColor = AppTheme.primaryBlue;
      icon = Icons.water_drop;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.description,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      '${tx.createdAt.hour}:${tx.createdAt.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(color: AppTheme.textGrey, fontSize: 12),
                    ),
                    if (tx.litresDispensed != null) ...[
                      const Text(' • ', style: TextStyle(color: AppTheme.textGrey)),
                      Text(
                        '${tx.litresDispensed}L',
                        style: const TextStyle(
                          color: AppTheme.primaryBlue,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isDebit ? '-' : '+'}₹${tx.amount.toStringAsFixed(1)}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: isDebit ? AppTheme.error : AppTheme.success,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: tx.status == TransactionStatus.success
                      ? AppTheme.success.withOpacity(0.1)
                      : AppTheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tx.status.name,
                  style: TextStyle(
                    fontSize: 10,
                    color: tx.status == TransactionStatus.success
                        ? AppTheme.success
                        : AppTheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
