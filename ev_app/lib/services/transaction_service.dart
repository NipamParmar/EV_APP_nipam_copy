import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';
import 'wallet_service.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final WalletService _walletService = WalletService();

  // Store a transaction and update wallet if necessary
  Future<void> storeTransaction(TransactionModel transaction) async {
    try {
      await _firestore.collection('transactions').doc(transaction.id).set(transaction.toMap());
      
      // If it's a success and wallet is involved, adjust balance
      if (transaction.status == 'success') {
        // Here you might decide based on transaction type if you add or subtract.
        // For standard payment tracking, mostly logging, but if money is added to wallet:
        // await _walletService.updateBalance(transaction.userId, transaction.amount, isAddition: true);
      }
    } catch (e) {
      print('Store Transaction Error: $e');
      rethrow;
    }
  }

  // Get transaction history
  Stream<List<TransactionModel>> getTransactionHistory(String userId) {
    return _firestore
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => TransactionModel.fromMap(doc.data(), doc.id)).toList();
    });
  }
}
