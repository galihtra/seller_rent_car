import 'package:flutter/material.dart';
import 'package:seller_rent_car/pages/car/add_car.dart';
import 'package:seller_rent_car/pages/promo/promo_screen.dart';
import 'package:seller_rent_car/pages/home/widgets/status_card_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

import '../../model/car_model.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<CarModel> filteredCars = [];
  List<CarModel> allCars = [];

  @override
  void initState() {
    super.initState();

    // Load all cars from Firestore and set them to allCars list
    FirebaseFirestore.instance.collection('cars').get().then((querySnapshot) {
      allCars = querySnapshot.docs
          .map((car) => CarModel.fromMap(car.data() as Map<String, dynamic>))
          .toList();
      // Initially, set filteredCars to allCars
      filteredCars = List.from(allCars);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('cars').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Terjadi kesalahan: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final cars = snapshot.data!.docs
              .map((car) => CarModel.fromMap(car.data() as Map<String, dynamic>))
              .toList();

          if (cars.isEmpty) {
            return Center(
              child: Text('Belum ada mobil yang ditambahkan.'),
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: Text("Beranda Admin"),
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.redAccent, Colors.pinkAccent],
                  ),
                ),
              ),
            ),
            body: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (searchText) {
                            filteredCars = cars
                                .where((car) =>
                                    car.name
                                        .toLowerCase()
                                        .contains(searchText.toLowerCase()))
                                .toList();
                            setState(() {});
                          },
                          decoration: InputDecoration(
                            hintText: 'Cari nama dan seri mobil...',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: () {
                          // Implement filter action here
                        },
                        child: Column(
                          children: [
                            Icon(Icons.filter_list),
                            Text("Filter"),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: 15.0),
                    clipBehavior: Clip.antiAlias,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 5.0,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20.0, top: 20.0),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            FiturCard(
                              title: "Tambahkan\nMobil",
                              iconData: Icons.drive_eta,
                              iconColor: Colors.red,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddCar(),
                                  ),
                                );
                              },
                            ),
                            FiturCard(
                              title: "Kelola\nPengemudi",
                              iconData: Icons.manage_search,
                              iconColor: Colors.blue,
                              onTap: () {
                                // Implement driver management
                              },
                            ),
                            FiturCard(
                              title: "Tambahkan\nPromo",
                              iconData: Icons.discount,
                              iconColor: Colors.green,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PromoScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredCars.length,
                    itemBuilder: (context, index) {
                      final carData = filteredCars[index];
                      final imageFile = File(carData.imageUrl);

                      return Container(
                        margin: EdgeInsets.only(bottom: 10.0),
                        child: InkWell(
                          onTap: () {
                            // Handle the car item tap here
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Column(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(top: 20.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: Container(
                                      height: 150.0,
                                      width: 320.0,
                                      child: Image.file(
                                        imageFile,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                ListTile(
                                  contentPadding: EdgeInsets.only(
                                    left: 20.0,
                                    right: 20.0,
                                    bottom: 20.0,
                                    top: 15.0,
                                  ),
                                  title: Text(
                                    carData.name,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    carData.type,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        });
  }
}
