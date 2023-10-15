import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as Path;
import 'package:cloud_firestore/cloud_firestore.dart';

class AddImagePromo extends StatefulWidget {
  const AddImagePromo({Key? key}) : super(key: key);

  @override
  _AddImagePromoState createState() => _AddImagePromoState();
}

class _AddImagePromoState extends State<AddImagePromo> {
  bool uploading = false;
  double val = 0;
  late List<File> _image = [];
  final picker = ImagePicker();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambahkan Gambar"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              setState(() {
                uploading = true;
              });
              uploadFile().whenComplete(() => Navigator.of(context).pop());
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GridView.builder(
            itemCount: _image.length + 1,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3),
            itemBuilder: (context, index) {
              return index == 0
                  ? Center(
                      child: IconButton(
                        onPressed: () {
                          chooseImage();
                        },
                        icon: const Icon(Icons.add),
                      ),
                    )
                  : Container(
                      margin: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: FileImage(
                            _image[index - 1],
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
            },
          ),
          if (uploading)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('uploading', style: TextStyle(fontSize: 20)),
                  const SizedBox(height: 10),
                  CircularProgressIndicator(
                    value: val,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  chooseImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image.add(File(pickedFile.path));
      });
    } else {
      await retrieveLostData();
    }
  }

  Future<void> retrieveLostData() async {
    final LostData response = await picker.getLostData();
    if (!response.isEmpty) {
      if (response.file != null) {
        setState(() {
          _image.add(File(response.file!.path));
        });
      } else {
        print(response.file);
      }
    }
  }

  Future<void> uploadFile() async {
    final imgRef =
        firebase_storage.FirebaseStorage.instance.ref().child('promo_images').child(_uid!);

    int i = 1;
    for (var img in _image) {
      setState(() {
        val = i / _image.length;
      });

      final ref = imgRef.child(Path.basename(img.path));
      try {
        final uploadTask = ref.putFile(img);
        final TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
        final String url = await taskSnapshot.ref.getDownloadURL();

        await FirebaseFirestore.instance.collection('promo').add({
          'url': url,
          'timestamp': FieldValue.serverTimestamp(),
        });

        i++;
      } catch (e) {
        // Handle any potential errors here
        print("Error uploading file: $e");
      }
    }
  }
}
