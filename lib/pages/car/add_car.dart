import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../model/car_model.dart';
import '../home/home_screen.dart';

class AddCar extends StatefulWidget {
  const AddCar({Key? key}) : super(key: key);

  @override
  _AddCarState createState() => _AddCarState();
}

class _AddCarState extends State<AddCar> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController maksPassengerController = TextEditingController();
  final TextEditingController createdYearController = TextEditingController();
  final TextEditingController maksTrunkController = TextEditingController();
  final TextEditingController detailController = TextEditingController();

  String? imageUrl;
  String passengerCategory = '2-4';
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

  Future<void> _addCar() async {
    final name = nameController.text;
    final type = typeController.text;
    final price = int.parse(priceController.text.replaceAll('.', ''));
    final maksPassenger = int.parse(maksPassengerController.text);
    final createdYear = int.parse(createdYearController.text);
    final maksTrunk = int.parse(maksTrunkController.text);
    final detail = detailController.text;

    if (imageUrl != null && name.isNotEmpty && type.isNotEmpty) {
      final car = CarModel(
        id: '',
        name: name,
        type: type,
        imageUrl: '', // Biarkan kosong karena URL gambar akan diisi nanti
        passengerCount: passengerCategory,
        price: price,
        maksPassenger: maksPassenger,
        createdYear: createdYear,
        maksTrunk: maksTrunk,
        detail: detail,
      );


      // Generate nama file unik dengan timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueImageName = 'car_images/$_uid/$timestamp.jpg';

      // Upload gambar ke Firebase Storage dengan nama file yang unik
      final Reference storageReference =
          FirebaseStorage.instance.ref().child(uniqueImageName);
      final UploadTask uploadTask = storageReference.putFile(File(imageUrl!));
      final TaskSnapshot taskSnapshot =
          await uploadTask.whenComplete(() => null);

      if (taskSnapshot.state == TaskState.success) {
        final String downloadURL = await storageReference.getDownloadURL();

        // Setel URL gambar yang diunduh ke objek mobil
        car.imageUrl = downloadURL;

        final CollectionReference carRef =
            FirebaseFirestore.instance.collection('cars');

        final DocumentReference docRef =
            await carRef.add(car.toJson());
        final String carId = docRef.id;

        car.id = carId;
        await docRef.update({'id': carId});

        // Navigator.pop(context);

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

        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mobil telah ditambahkan!'),
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
                    const InputDecoration(labelText: 'Nama dan Seri Mobil'),
              ),
              TextField(
                controller: typeController,
                decoration:
                    const InputDecoration(labelText: 'Tipe atau Gaya Mobil'),
              ),
              const SizedBox(height: 16.0),
              const Text(
                "Pilih Batas Jumlah Penumpang",
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10.0),
              ToggleSwitch(
                minWidth: 150.0,
                initialLabelIndex: 0,
                cornerRadius: 20.0,
                activeBgColor: const [Colors.pinkAccent],
                activeFgColor: Colors.white,
                inactiveBgColor: Colors.grey,
                inactiveFgColor: Colors.white,
                totalSwitches: 2,
                labels: const ['2-4', '5-6'],
                icons: const [Icons.people, Icons.people],
                onToggle: (index) {
                  passengerCategory = index == 0 ? '2-4' : '5-6';
                },
              ),
              TextField(
                keyboardType: TextInputType.number,
                controller: priceController,
                decoration: const InputDecoration(
                    labelText: 'Harga Sewa Mobil Per Hari'),
              ),
              const SizedBox(height: 16.0),
              const Text(
                textAlign: TextAlign.start,
                "Tambah Data Baru ( Untuk Tampilan Detail )",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextField(
                keyboardType: TextInputType.number,
                controller: maksPassengerController,
                decoration:
                    const InputDecoration(labelText: 'Maks. Jumlah Penumpang'),
              ),
              TextField(
                keyboardType: TextInputType.number,
                controller: createdYearController,
                decoration:
                    const InputDecoration(labelText: 'Keluaran Tahun 20xx'),
              ),
              TextField(
                keyboardType: TextInputType.number,
                controller: maksTrunkController,
                decoration:
                    const InputDecoration(labelText: 'Maks. Jumlah Koper'),
              ),
              TextField(
                controller: detailController,
                maxLines: null,
                decoration: const InputDecoration(
                  labelText: 'Isi Detail Lainnya',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _addCar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  minimumSize: const Size(350, 50),
                ),
                child: const Text(
                  'Tambah Mobil',
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
