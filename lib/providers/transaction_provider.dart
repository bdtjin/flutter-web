import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';

final transactionProvider = NotifierProvider<TransactionNotifier, List<Transaction>>(() {
  return TransactionNotifier();
});

class TransactionNotifier extends Notifier<List<Transaction>> {
  @override
  List<Transaction> build() {
    _loadTransactions();
    return [];
  }

  static const String _key = 'transactions';

  Future<void> _loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_key);
    if (data != null) {
      final List<dynamic> jsonList = jsonDecode(data);
      final list = jsonList.map((json) => Transaction.fromJson(json)).toList();
      // 날짜 순 정렬 (최신순)
      list.sort((a, b) => b.date.compareTo(a.date));
      state = list;
    }
  }

  Future<void> _saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String data = jsonEncode(state.map((t) => t.toJson()).toList());
    await prefs.setString(_key, data);
  }

  void addTransaction(Transaction transaction) {
    state = [transaction, ...state];
    state.sort((a, b) => b.date.compareTo(a.date));
    _saveTransactions();
  }

  void deleteTransaction(String id) {
    state = state.where((t) => t.id != id).toList();
    _saveTransactions();
  }

  double get totalIncome => state
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, item) => sum + item.amount);

  double get totalExpense => state
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, item) => sum + item.amount);

  double get balance => totalIncome - totalExpense;
}
