import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:seller_rent_car/pages/notification/detail_notification.dart';

import '../../../model/payment_model.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  Future<Map<String, String>> _fetchCarNames(List<String> carIds) async {
    var carNames = <String, String>{};
    for (var carId in carIds) {
      var carSnapshot =
          await FirebaseFirestore.instance.collection('cars').doc(carId).get();
      carNames[carId] = carSnapshot.data()?['name'] ?? 'Unknown Car';
    }
    return carNames;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF29233B),
      appBar: AppBar(
        title: const Text('Daftar Riwayat'),
        backgroundColor: const Color(0xFF110925),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('payments')
            .where('paymentStatus', isEqualTo: 'Selesai')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text(
              'Tidak ada data tersedia',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ));
          }

          var payments = snapshot.data!.docs
              .map((doc) => PaymentModel.fromSnapshot(doc))
              .toList();
          var carIds =
              payments.map((payment) => payment.carId).toSet().toList();

          return FutureBuilder(
            future: _fetchCarNames(carIds),
            builder:
                (context, AsyncSnapshot<Map<String, String>> carNamesSnapshot) {
              if (carNamesSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (carNamesSnapshot.hasError || !carNamesSnapshot.hasData) {
                return const Text('Failed to load car names');
              }

              var carNames = carNamesSnapshot.data!;

              return ListView.builder(
                itemCount: payments.length,
                itemBuilder: (context, index) {
                  var payment = payments[index];
                  var carName = carNames[payment.carId] ?? 'Unknown Car';

                  return ListTile(
                    title: Text(
                      carName,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                    subtitle: Text(
                      payment.isWithDriver == true
                          ? 'Dengan Supir'
                          : 'Tanpa Supir',
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('dd MMMM yyyy')
                              .format(DateTime.parse(payment.dateRent)),
                          style: const TextStyle(color: Colors.white),
                        ),
                        Text(
                          '${payment.datePickUp} WIB',
                          style: const TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            DetailNotificationScreen(dataPayment: payment),
                      ));
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
