import 'package:flutter/material.dart';
import 'package:seller_rent_car/pages/car/add_car.dart';
import 'package:seller_rent_car/pages/promo/promo_screen.dart';
import 'package:seller_rent_car/pages/home/widgets/status_card_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../model/car_model.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<CarModel> allCars = [];
  List<CarModel> filteredCars = [];
  String selectedPassengerCount = '';

  @override
  void initState() {
    super.initState();

    FirebaseFirestore.instance.collection('cars').get().then((querySnapshot) {
      allCars = querySnapshot.docs
          .map((car) => CarModel.fromMap(car.data() as Map<String, dynamic>))
          .toList();
      filteredCars = List.from(allCars);
      setState(() {});
    });
  }

  void updateFilteredCars(String searchText) {
    filteredCars = allCars.where((car) {
      final carName = car.name.toLowerCase();
      final searchWords = searchText.toLowerCase().split(' ');
      return searchWords.every((word) => carName.contains(word));
    }).toList();
    setState(() {});
  }

  void filterCarsByPassengerCount(String passengerCount) {
    // Update the filtered cars based on selected passenger count
    filteredCars =
        allCars.where((car) => car.passengerCount == passengerCount).toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Beranda Admin"),
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
        body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (searchText) {
                              updateFilteredCars(searchText);
                            },
                            decoration: InputDecoration(
                              hintText: 'Cari nama dan seri mobil...',
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  // Clear the search text and update the filtered cars
                                  _searchController.clear();
                                  updateFilteredCars('');
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Filter Jumlah Kursi"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () {
                                    filterCarsByPassengerCount('2-4');
                                    Navigator.pop(context); // Close the dialog
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Text('2-4 Orang'),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    filterCarsByPassengerCount('5-6');
                                    Navigator.pop(context); // Close the dialog
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Text('5-6 Orang'),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: const Column(
                      children: [
                        Icon(Icons.filter_list),
                        Text("Filter"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              child: Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
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
                                builder: (context) => const AddCar(),
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
    
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10.0),
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
                              margin: const EdgeInsets.only(top: 20.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: Container(
                                  height: 150.0,
                                  width: 320.0,
                                  child: Image.network(
                                    carData.imageUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            ListTile(
                              contentPadding: const EdgeInsets.only(
                                left: 20.0,
                                right: 20.0,
                                bottom: 20.0,
                                top: 15.0,
                              ),
                              title: Text(
                                carData.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                carData.type,
                                style: const TextStyle(
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
      ),
    );
  }
}
