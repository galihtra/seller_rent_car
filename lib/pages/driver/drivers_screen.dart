import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:seller_rent_car/pages/driver/add_driver.dart';

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
      appBar: AppBar(
        title: const Text("Kelola Supir"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.redAccent, Colors.pinkAccent],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pinkAccent,
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
            final docId = document.id; 

            return Card(
              margin: const EdgeInsets.only(top: 16.0),
              child: Container(
                height: 100,
                child: Center(
                  child: ListTile(
                    leading: Image.network(
                      imageUrl,
                      width: 100,
                      height: 300,
                      fit: BoxFit.cover,
                    ),
                    title: Text(driver.name), 
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
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
      // Hapus dokumen driver dari Firestore
      await FirebaseFirestore.instance.collection('drivers').doc(docId).delete();
    } catch (e) {
      print('Error deleting driver: $e');
      // Tambahkan penanganan kesalahan jika diperlukan
    }
  }
}
