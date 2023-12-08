import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:seller_rent_car/pages/driver/add_driver.dart';
import 'package:seller_rent_car/pages/driver/detail_driver.dart';

import '../../model/driver_model.dart';

class DriversScreen extends StatefulWidget {
  const DriversScreen({Key? key}) : super(key: key);

  @override
  State<DriversScreen> createState() => _DriversScreenState();
}

class _DriversScreenState extends State<DriversScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF29233B),
      appBar: AppBar(
        title: const Text("Kelola Pengemudi"),
        backgroundColor: const Color(0xFF110925),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF9588F9),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddDriver()),
          );
        },
      ),
      body: const DriverList(),
    );
  }
}

class DriverList extends StatelessWidget {
  const DriverList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('drivers').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final documents = snapshot.data?.docs;
        return ListView.builder(
          itemCount: documents!.length,
          itemBuilder: (context, index) {
            final document = documents[index];
            final driver = DriverModel.fromSnapshot(document);
            final imageUrl = driver.imageUrl;
            final name = driver.name;
            final noTelp = driver.noTelp;
            final noSim = driver.noSim;
            final alamat = driver.alamat;
            final docId = document.id;

            final driverData = DriverModel(
                id: docId,
                name: name,
                imageUrl: imageUrl,
                noTelp: noTelp,
                noSim: noSim,
                alamat: alamat);

            return Card(
              margin: const EdgeInsets.only(top: 16.0),
              child: Container(
                height: 100,
                color: const Color(0xFF110925),
                child: Center(
                  child: ListTile(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              DetailDriverScreen(driverData: driverData),
                        ),
                      );
                    },
                    leading: Image.network(
                      imageUrl,
                      width: 100,
                      height: 300,
                      fit: BoxFit.cover,
                    ),
                    title: Text(
                      'Nama : ${driver.name}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      'Alamat: ${driver.alamat}',
                      style: const TextStyle(color: Colors.white60),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.yellow,
                      ),
                      onPressed: () {
                        deleteDriver(docId);
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void deleteDriver(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('drivers')
          .doc(docId)
          .delete();
    } catch (e) {
      print('Error deleting driver: $e');
    }
  }
}
