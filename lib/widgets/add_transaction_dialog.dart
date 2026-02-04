import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';

class AddTransactionDialog extends ConsumerStatefulWidget {
  const AddTransactionDialog({super.key});

  @override
  ConsumerState<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends ConsumerState<AddTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  TransactionType _type = TransactionType.expense;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final transaction = Transaction.create(
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        type: _type,
      );
      ref.read(transactionProvider.notifier).addTransaction(transaction);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('새로운 내역 추가'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SegmentedButton<TransactionType>(
              segments: const [
                ButtonSegment(value: TransactionType.expense, label: Text('지출'), icon: Icon(Icons.remove_circle_outline)),
                ButtonSegment(value: TransactionType.income, label: Text('수입'), icon: Icon(Icons.add_circle_outline)),
              ],
              selected: {_type},
              onSelectionChanged: (newSelection) {
                setState(() {
                  _type = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '항목 이름',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.isEmpty ? '이름을 입력하세요' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: '금액',
                border: OutlineInputBorder(),
                prefixText: '₩ ',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return '금액을 입력하세요';
                if (double.tryParse(value) == null) return '숫자만 입력 가능합니다';
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: _type == TransactionType.income ? Colors.green : Colors.redAccent,
            foregroundColor: Colors.white,
          ),
          child: const Text('저장'),
        ),
      ],
    );
  }
}
