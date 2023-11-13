import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:seller_rent_car/pages/promo/add_image_promo.dart';

class PromoScreen extends StatelessWidget {
  PromoScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Semua Promo"),
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
            MaterialPageRoute(builder: (context) => const AddImagePromo()),
          );
        },
      ),
      body: PromoImageList(),
    );
  }
}

class PromoImageList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('promo').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final documents = snapshot.data?.docs;
        return ListView.builder(
          itemCount: documents!.length,
          itemBuilder: (context, index) {
            final document = documents[index];
            final imageUrl = document['url'] as String;
            final docId = document.id; 

            return Card(
              margin: const EdgeInsets.only(
                  top: 16.0), 
              child: Container(
                height: 100,
                child: Center(
                  child: ListTile(
                    leading: Image.network(
                      imageUrl,
                      width: 150, 
                      height:
                          280,
                      fit: BoxFit
                          .cover, 
                    ),
                    title: Text('Gambar ${index + 1}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        deleteImage(docId, imageUrl);
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

  void deleteImage(String docId, String imageUrl) async {
    if (imageUrl.isNotEmpty) {
      try {
        final storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
        await storageRef.delete();
      } catch (e) {
        print('Error deleting image from Firebase Storage: $e');
      }
    }

    await FirebaseFirestore.instance.collection('promo').doc(docId).delete();
  }
}
