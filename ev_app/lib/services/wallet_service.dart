import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/wallet_model.dart';

class WalletService {

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;


  /// STREAM WALLET REALTIME
  Stream<WalletModel?> getWalletStream(
      String userId) {

    return _firestore
        .collection('wallets')
        .doc(userId)
        .snapshots()
        .map((doc) {

      if (!doc.exists) return null;

      return WalletModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id);
    });
  }



  /// CREATE WALLET IF NOT EXISTS
  Future<void> createWalletIfNotExists(
      String userId) async {

    DocumentReference walletRef =
        _firestore.collection('wallets').doc(userId);

    DocumentSnapshot walletSnap =
        await walletRef.get();

    if (!walletSnap.exists) {

      await walletRef.set({

        'balance': 0.0,
        'createdAt':
            FieldValue.serverTimestamp(),

        'lastUpdated':
            FieldValue.serverTimestamp(),
      });
    }
  }



  /// UPDATE BALANCE (ADD / SUBTRACT)
  Future<void> updateBalance(
      String userId,
      double amount,
      {required bool isAddition}) async {

    DocumentReference walletRef =
        _firestore.collection('wallets').doc(userId);

    DocumentReference userRef =
        _firestore.collection('users').doc(userId);


    await _firestore.runTransaction(
        (transaction) async {

      DocumentSnapshot walletSnap =
          await transaction.get(walletRef);


      /// CREATE WALLET IF NOT EXISTS
      if (!walletSnap.exists) {

        transaction.set(walletRef, {

          'balance': amount,
          'createdAt':
              FieldValue.serverTimestamp(),

          'lastUpdated':
              FieldValue.serverTimestamp(),
        });


        transaction.set(userRef, {

          'walletBalance': amount

        }, SetOptions(merge: true));

        return;
      }


      double currentBalance =
          (walletSnap.data()
              as Map<String, dynamic>)['balance'] ??
              0.0;


      double newBalance =
          isAddition
              ? currentBalance + amount
              : currentBalance - amount;


      if (newBalance < 0) {

        throw Exception(
            "Insufficient balance");
      }


      transaction.update(walletRef, {

        'balance': newBalance,

        'lastUpdated':
            FieldValue.serverTimestamp(),
      });


      /// MIRROR UPDATE USER COLLECTION
      transaction.set(userRef, {

        'walletBalance': newBalance

      }, SetOptions(merge: true));

    });
  }



  /// SIMPLE TOP-UP FUNCTION
  Future<void> topUpWallet(
      String userId,
      double amount) async {

    await updateBalance(
      userId,
      amount,
      isAddition: true,
    );
  }



  /// DEDUCT FUNCTION
  Future<void> deductWallet(
      String userId,
      double amount) async {

    await updateBalance(
      userId,
      amount,
      isAddition: false,
    );
  }

}