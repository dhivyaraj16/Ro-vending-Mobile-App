import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/machine_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/other_providers.dart';
import '../../models/models.dart';
import '../../utils/app_theme.dart';
import '../../widgets/machine_card.dart';
import '../../widgets/stat_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MachineProvider>().fetchMachines();
      final user = context.read<AuthProvider>().userModel;
      if (user != null) {
        context.read<WalletProvider>().initWallet(user.walletBalance);
        // Load real transaction data for stats
        context.read<TransactionProvider>().fetchTransactions(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().userModel;
    final wallet = context.watch<WalletProvider>();
    final machines = context.watch<MachineProvider>();
    final txProvider = context.watch<TransactionProvider>();

    // Real stats from transaction data
    final totalLitres = txProvider.getTotalLitres();
    final totalTxns   = txProvider.transactions
        .where((t) => t.type == TransactionType.waterPurchase)
        .length;

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<MachineProvider>().fetchMachines();
          final u = context.read<AuthProvider>().userModel;
          if (u != null) {
            await context.read<TransactionProvider>().fetchTransactions(u.uid);
          }
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 180,
              pinned: true,
              backgroundColor: AppTheme.primaryBlue,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppTheme.deepBlue, AppTheme.primaryBlue, AppTheme.lightBlue],
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, ${user?.name.split(' ').first ?? 'User'}! 👋',
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Stay Hydrated Today 💧',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => context.push('/chat'),
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.support_agent, color: Colors.white, size: 26),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: AppTheme.warning,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Wallet Card
                    _buildWalletCard(wallet.balance, context),
                    const SizedBox(height: 20),

                    // Quick Actions
                    _buildQuickActions(context),
                    const SizedBox(height: 20),

                    // Stats — REAL DATA from API/Firestore
                    const Text(
                      'Your Stats',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.deepBlue,
                      ),
                    ),
                    const SizedBox(height: 12),
                    txProvider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Row(
                            children: [
                              Expanded(
                                child: StatCard(
                                  icon: Icons.water_drop,
                                  iconColor: AppTheme.lightBlue,
                                  label: 'Litres Used',
                                  value: '${totalLitres.toStringAsFixed(1)}L',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: StatCard(
                                  icon: Icons.receipt_long,
                                  iconColor: AppTheme.success,
                                  label: 'Transactions',
                                  value: '$totalTxns',
                                ),
                              ),
                            ],
                          ),
                    const SizedBox(height: 20),

                    // Nearby Machines
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Nearby Machines',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.deepBlue,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/map'),
                          child: const Text('View Map',
                              style: TextStyle(color: AppTheme.primaryBlue)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    machines.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : machines.machines.isEmpty
                            ? _buildEmptyMachines()
                            : Column(
                                children: machines.machines
                                    .map((m) => MachineCard(machine: m))
                                    .toList(),
                              ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletCard(double balance, BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/wallet'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.primaryBlue, AppTheme.lightBlue],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Wallet Balance',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 6),
                Text(
                  '₹${balance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () => context.go('/wallet/add-money'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryBlue,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Money', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {'icon': Icons.qr_code_scanner, 'label': 'Scan QR',     'route': '/scanner'},
      {'icon': Icons.location_on,      'label': 'Find Machine','route': '/map'},
      {'icon': Icons.history,           'label': 'History',    'route': '/transactions'},
      {'icon': Icons.chat_bubble_outline,'label': 'Support',   'route': '/chat'},
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: actions.map((action) {
        return GestureDetector(
          onTap: () => context.go(action['route'] as String),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Icon(action['icon'] as IconData,
                    color: AppTheme.primaryBlue, size: 24),
              ),
              const SizedBox(height: 6),
              Text(action['label'] as String,
                  style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyMachines() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: const Column(
        children: [
          Icon(Icons.location_searching, size: 60, color: AppTheme.textGrey),
          SizedBox(height: 12),
          Text('No machines found nearby',
              style: TextStyle(color: AppTheme.textGrey)),
        ],
      ),
    );
  }
}