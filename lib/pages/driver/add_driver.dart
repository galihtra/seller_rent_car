import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:seller_rent_car/model/driver_model.dart';

class AddDriver extends StatefulWidget {
  const AddDriver({super.key});

  @override
  State<AddDriver> createState() => _AddDriverState();
}

class _AddDriverState extends State<AddDriver> {

  final TextEditingController nameController = TextEditingController();

  String? imageUrl;
  String? _uid;

  @override
  void initState() {
    super.initState();
    // Get the user's UID during initialization
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _uid = user.uid;
    }
  }

  Future<void> _addDriver() async {
    final name = nameController.text;

    if (imageUrl != null && name.isNotEmpty) {
      final driver = DriverModel(
        id: '',
        name: name,
        imageUrl: '', 
      );

      // Generate nama file unik dengan timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueImageName = 'driver_images/$_uid/$timestamp.jpg';

      // Upload gambar ke Firebase Storage dengan nama file yang unik
      final Reference storageReference =
          FirebaseStorage.instance.ref().child(uniqueImageName);
      final UploadTask uploadTask = storageReference.putFile(File(imageUrl!));
      final TaskSnapshot taskSnapshot =
          await uploadTask.whenComplete(() => null);

      if (taskSnapshot.state == TaskState.success) {
        final String downloadURL = await storageReference.getDownloadURL();

  
        driver.imageUrl = downloadURL;

        final CollectionReference driverRef =
            FirebaseFirestore.instance.collection('drivers');

        final DocumentReference docRef =
            await driverRef.add(driver.toJson());
        final String driverId = docRef.id;

        driver.id = driverId;
        await docRef.update({'id': driverId});

        // Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Supir telah ditambahkan ke Firestore'),
          ),
        );

        nameController.clear();
        setState(() {
          imageUrl = null;
        });

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Supir telah ditambahkan!'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mengunggah gambar. Silakan coba lagi.'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Harap isi semua field dan pilih gambar terlebih dahulu'),
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
        title: const Text("Tambah Supir"),
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
          child: Column(
            children: [
              if (imageUrl != null)
                GestureDetector(
                  onTap: _showImageSourceDialog,
                  child: Image.file(
                    File(imageUrl!),
                    width: 400,
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
                      width: 400,
                      color: Colors.grey,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image,
                              size: 60, color: Color.fromARGB(125, 0, 0, 0)),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            "Tambahkan Gambar",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(125, 0, 0, 0)),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 10.0),
              TextField(
                controller: nameController,
                decoration:
                    const InputDecoration(labelText: 'Nama Lengkap'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _addDriver,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  minimumSize: const Size(350, 50),
                ),
                child: const Text(
                  'Tambah Supir',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
