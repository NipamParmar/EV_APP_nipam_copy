import 'package:flutter_upi_india/flutter_upi_india.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpiService {

  Future<List<ApplicationMeta>> getInstalledUpiApps() async {
    return await UpiPay.getInstalledUpiApplications(
      statusType:
      UpiApplicationDiscoveryAppStatusType.all,
    );
  }

  Future<UpiTransactionResponse> initiateTransaction({
    required UpiApplication app,
    required double amount,
    required String bookingId,
    String? receiverUpiId,
    String? receiverName,
  }) async {

    return await UpiPay.initiateTransaction(
      app: app,
      receiverUpiAddress:
      receiverUpiId ?? "nirmaljoshi123456789@okaxis",
      receiverName:
      receiverName ?? "EV Charging Station",
      transactionRef: bookingId,
      transactionNote:
      "EV Charging Slot Booking",
      amount: amount.toStringAsFixed(2),
    );
  }

  Future<void> handlePaymentResponse({
    required UpiTransactionResponse response,
    required String bookingId,
    required String userId,
    required double amount,
  }) async {

    final status = response.status;

    final txnId =
        response.txnId ??
            DateTime.now()
                .millisecondsSinceEpoch
                .toString();

    if (status == UpiTransactionStatus.success) {

      await FirebaseFirestore.instance
          .collection("bookings")
          .doc(bookingId)
          .set({
        "bookingId": bookingId,
        "userId": userId,
        "amount": amount,
        "paymentStatus": "paid",
        "bookingStatus": "confirmed",
        "transactionId": txnId,
        "timestamp":
        FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance
          .collection("transactions")
          .doc(txnId)
          .set({
        "bookingId": bookingId,
        "userId": userId,
        "amount": amount,
        "status": "success",
        "timestamp":
        FieldValue.serverTimestamp(),
      });

    } else if (status ==
        UpiTransactionStatus.submitted) {

      await FirebaseFirestore.instance
          .collection("bookings")
          .doc(bookingId)
          .set({
        "paymentStatus": "pending",
        "bookingStatus": "pending",
      }, SetOptions(merge: true));

    } else {

      await FirebaseFirestore.instance
          .collection("bookings")
          .doc(bookingId)
          .set({
        "paymentStatus": "failed",
        "bookingStatus": "cancelled",
      }, SetOptions(merge: true));
    }
  }
}