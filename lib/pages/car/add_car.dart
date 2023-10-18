import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import '../../model/car_model.dart';

class AddCar extends StatefulWidget {
  const AddCar({Key? key}) : super(key: key);

  @override
  _AddCarState createState() => _AddCarState();
}

class _AddCarState extends State<AddCar> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  String? imageUrl; // Menyimpan URL gambar

  Future<void> _addCar() async {
    final name = nameController.text;
    final type = typeController.text;

    if (imageUrl != null && name.isNotEmpty && type.isNotEmpty) {
      final car = CarModel(name, type, imageUrl!);

      await FirebaseFirestore.instance.collection('cars').add(car.toMap());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mobil telah ditambahkan ke Firestore'),
        ),
      );

      nameController.clear();
      typeController.clear();
      setState(() {
        imageUrl = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Harap isi semua field dan pilih gambar terlebih dahulu'),
        ),
      );
    }
  }

  Future<void> _getImage(bool isFromGallery) async {
    final source = isFromGallery ? ImageSource.gallery : ImageSource.camera;
    final pickedFile = await ImagePicker().getImage(source: source);

    if (pickedFile != null) {
      setState(() {
        imageUrl = pickedFile.path;
      });
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Pilih Sumber Gambar"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.photo),
                  title: const Text("Pilih dari Galeri"),
                  onTap: () {
                    Navigator.of(context).pop();
                    _getImage(true); // Pilih gambar dari galeri
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera),
                  title: const Text("Ambil Foto dari Kamera"),
                  onTap: () {
                    Navigator.of(context).pop();
                    _getImage(false); // Ambil foto dari kamera
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Mobil Sewa"),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (imageUrl != null)
              GestureDetector(
                onTap: _showImageSourceDialog,
                child: Image.file(
                  File(imageUrl!),
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              )
            else
              GestureDetector(
                onTap: _showImageSourceDialog,
                child: Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 200,
                    width: 200,
                    color: Colors.white60,
                    child: const Icon(
                      Icons.image,
                      size: 60,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16.0),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nama Mobil'),
            ),
            TextField(
              controller: typeController,
              decoration: const InputDecoration(labelText: 'Tipe Mobil'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _addCar,
              child: const Text('Tambah Mobil'),
            ),
          ],
        ),
      ),
    );
  }
}
