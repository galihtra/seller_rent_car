import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seller_rent_car/pages/notification/detail_notification.dart';
import '../../../model/payment_model.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String? _currentFilter = 'Diproses';

  Future<Map<String, String>> _fetchCarNames(List<String> carIds) async {
    var carNames = <String, String>{};
    for (var carId in carIds) {
      var carSnapshot =
          await FirebaseFirestore.instance.collection('cars').doc(carId).get();
      carNames[carId] = carSnapshot.data()?['name'] ?? 'Unknown Car';
    }
    return carNames;
  }

  void _setFilter(String filter) {
    setState(() {
      _currentFilter = filter;
    });
  }

  Stream<QuerySnapshot> _paymentStream() {
    var collection = FirebaseFirestore.instance.collection('payments');
    if (_currentFilter != null) {
      return collection
          .where('paymentStatus', isEqualTo: _currentFilter)
          .snapshots();
    }
    return collection.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF29233B),
      appBar: AppBar(
        title: Text('Daftar Pengajuan $_currentFilter'),
        backgroundColor: const Color(0xFF110925),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _paymentStream(),
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
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      payment.isWithDriver == true
                          ? 'Dengan Supir'
                          : 'Tanpa Supir',
                      style: const TextStyle(
                        color: Colors.white,
                      ),
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

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Filter Status"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _filterOption('Ditolak'),
              _filterOption('Diproses'),
              _filterOption('Disiapkan'),
              _filterOption('Menuju Lokasi'),
            ],
          ),
        );
      },
    );
  }

  InkWell _filterOption(String status) {
    return InkWell(
      onTap: () {
        _setFilter(status);
        Navigator.pop(context); // Close the dialog
      },
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Text(status),
      ),
    );
  }
}
