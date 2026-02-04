import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../widgets/add_transaction_dialog.dart';
import '../models/transaction.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionProvider);
    final notifier = ref.read(transactionProvider.notifier);
    final currencyFormat = NumberFormat.currency(locale: 'ko_KR', symbol: '₩');

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Smart Wallet', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dashboard Section
            _buildDashboard(context, notifier, currencyFormat),
            const SizedBox(height: 32),
            const Text(
              '최근 거래 내역',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (transactions.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Text('거래 내역이 없습니다. 새로운 내역을 추가해 보세요!'),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final t = transactions[index];
                  return _buildTransactionItem(context, t, notifier, currencyFormat);
                },
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => const AddTransactionDialog(),
        ),
        label: const Text('내역 추가'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.indigoAccent,
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, TransactionNotifier notifier, NumberFormat fmt) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.indigo, Colors.blueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text('현재 잔액', style: TextStyle(color: Colors.white70, fontSize: 16)),
          Text(
            fmt.format(notifier.balance),
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem('수입', notifier.totalIncome, Colors.greenAccent),
              Container(width: 1, height: 40, color: Colors.white24),
              _buildSummaryItem('지출', notifier.totalExpense, Colors.orangeAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, double amount, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        Text(
          NumberFormat.compactCurrency(locale: 'ko_KR', symbol: '₩').format(amount),
          style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(BuildContext context, Transaction t, TransactionNotifier notifier, NumberFormat fmt) {
    final isIncome = t.type == TransactionType.income;
    return Dismissible(
      key: Key(t.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        notifier.deleteTransaction(t.id);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('내역이 삭제되었습니다.')));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: (isIncome ? Colors.green : Colors.red).withOpacity(0.1),
              child: Icon(
                isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                color: isIncome ? Colors.green : Colors.red,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(
                    DateFormat('yyyy.MM.dd').format(t.date),
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ),
            Text(
              '${isIncome ? '+' : '-'}${fmt.format(t.amount)}',
              style: TextStyle(
                color: isIncome ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
