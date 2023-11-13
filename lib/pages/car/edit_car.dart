import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../model/car_model.dart';
import '../home/home_screen.dart';

class EditCarScreen extends StatefulWidget {
  final CarModel carData;

  EditCarScreen({required this.carData});

  @override
  _EditCarScreenState createState() => _EditCarScreenState();
}

class _EditCarScreenState extends State<EditCarScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController typeController;
  late TextEditingController priceController;
  late TextEditingController passengerCountController;
  late TextEditingController createdYearController;
  late TextEditingController maksTrunkController;
  late TextEditingController detailController;

  String? _uid;
  String? imageUrl;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _uid = user.uid;
    }
    nameController = TextEditingController(text: widget.carData.name);
    typeController = TextEditingController(text: widget.carData.type);
    priceController =
        TextEditingController(text: widget.carData.price.toString());
    passengerCountController =
        TextEditingController(text: widget.carData.passengerCount);
    createdYearController =
        TextEditingController(text: widget.carData.createdYear.toString());
    maksTrunkController =
        TextEditingController(text: widget.carData.maksTrunk.toString());
    detailController = TextEditingController(text: widget.carData.detail);
  }

  Future<void> _uploadImage() async {
    final imageFile = await _picker.pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      // Jika gambar berhasil dipilih, unggah ke Firebase Storage
      final Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('car_images/$_uid/${DateTime.now()}.jpg');
      final UploadTask uploadTask =
          storageReference.putFile(File(imageFile.path));
      final TaskSnapshot taskSnapshot = await uploadTask;
      if (taskSnapshot.state == TaskState.success) {
        imageUrl = await storageReference.getDownloadURL();
      }
    }
  }

  void updateData() async {
    if (_formKey.currentState!.validate()) {
      try {
        final String name = nameController.text;
        final String type = typeController.text;
        final int price = int.parse(priceController.text);
        final String passengerCount = passengerCountController.text;
        final int createdYear = int.parse(createdYearController.text);
        final int maksTrunk = int.parse(maksTrunkController.text);
        final String detail = detailController.text;

        final CollectionReference carsCollection =
            FirebaseFirestore.instance.collection('cars');

        final DocumentReference carDocRef =
            carsCollection.doc(widget.carData.id);

        final CarModel updatedCarData = CarModel(
          id: widget.carData.id,
          name: name,
          type: type,
          imageUrl: imageUrl ?? widget.carData.imageUrl,
          passengerCount: passengerCount,
          price: price,
          maksPassenger: widget.carData.maksPassenger,
          createdYear: createdYear,
          maksTrunk: maksTrunk,
          detail: detail,
        );

        await carDocRef.update(updatedCarData.toJson());

        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) =>
              HomeScreen(), 
        ));
      } catch (e) {
        print('Error updating car: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan perubahan. Silakan coba lagi.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Mobil'),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nama Mobil'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Nama Mobil harus diisi';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: typeController,
                  decoration: const InputDecoration(labelText: 'Tipe Mobil'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Tipe Mobil harus diisi';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: priceController,
                  decoration:
                      const InputDecoration(labelText: 'Harga Sewa per Hari'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Harga harus diisi';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: passengerCountController,
                  decoration:
                      const InputDecoration(labelText: 'Jumlah Penumpang'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Jumlah penumpang harus diisi';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: createdYearController,
                  decoration:
                      const InputDecoration(labelText: 'Tahun Pembuatan'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Tahun pembuatan harus diisi';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: maksTrunkController,
                  decoration:
                      const InputDecoration(labelText: 'Maksimal Jumlah Koper'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Maksimal jumlah koper harus diisi';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: detailController,
                  decoration: const InputDecoration(labelText: 'Detail Mobil'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Detail mobil harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    _uploadImage();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent
                  ),
                  child: const Text('Unggah Gambar Mobil Baru'),
                ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    updateData();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    minimumSize: const Size(350, 50),
                  ),
                  child: const Text(
                    'Simpan Perubahan',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
