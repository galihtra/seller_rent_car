import 'package:cloud_firestore/cloud_firestore.dart';

class DriverModel {
  String id;
  String name;
  String imageUrl;
  String noTelp;
  String noSim;
  String alamat;

  DriverModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.noTelp,
    required this.noSim,
    required this.alamat,
  });

  DriverModel.fromSnapshot(DocumentSnapshot snapshot)
      : id = snapshot.id,
        name = snapshot['name'],
        imageUrl = snapshot['imageUrl'],
        noTelp = snapshot['noTelp'],
        noSim = snapshot['noSim'],
        alamat = snapshot['alamat'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'imageUrl': imageUrl,
        'noTelp': noTelp,
        'noSim': noSim,
        'alamat': alamat,
      };
}
