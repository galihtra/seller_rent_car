import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:seller_rent_car/pages/car/add_car.dart';
import 'package:seller_rent_car/pages/driver/drivers_screen.dart';
import 'package:seller_rent_car/pages/promo/promo_screen.dart';
import 'package:seller_rent_car/pages/home/widgets/status_card_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seller_rent_car/utils/price_ext.dart';

import '../../model/car_model.dart';
import '../car/detail_car.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<CarModel> allCars = [];
  List<CarModel> filteredCars = [];
  String selectedPassengerCount = '';
  HashSet<CarModel> selectedCars = HashSet();
  bool isMultiSelectionEnabled = false;

  @override
  void initState() {
    super.initState();

    FirebaseFirestore.instance.collection('cars').get().then((querySnapshot) {
      allCars =
          querySnapshot.docs.map((car) => CarModel.fromSnapshot(car)).toList();
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

  void enableMultiSelection() {
    isMultiSelectionEnabled = true;
    setState(() {});
  }

  void toggleCarSelection(CarModel carData) {
    if (selectedCars.contains(carData)) {
      selectedCars.remove(carData);
    } else {
      selectedCars.add(carData);
    }
    setState(() {});
  }

  void navigateToCarDetail(CarModel carData) {
    if (!isMultiSelectionEnabled) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CarDetailScreen(carData: carData),
        ),
      );
    }
  }

  void deleteSelectedCars() async {
    try {
      final List<String> carIdsToDelete =
          selectedCars.map((car) => car.id).toList();

      // Debug: Print carIdsToDelete to verify the list of car IDs
      print('Car IDs to delete: $carIdsToDelete');

      for (final carId in carIdsToDelete) {
        await FirebaseFirestore.instance.collection('cars').doc(carId).delete();
      }

      allCars.removeWhere((car) => selectedCars.contains(car));
      filteredCars = List.from(allCars);
      selectedCars.clear();
      isMultiSelectionEnabled = false;
      setState(() {});
    } catch (e) {
      print('Error deleting car: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFF110925),
        appBar: AppBar(
          backgroundColor: const Color(0xFF110925),
          title: const Text(
            "Beranda Admin",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          flexibleSpace: Container(),
          actions: [
            Visibility(
              visible: isMultiSelectionEnabled,
              child: IconButton(
                icon: const Icon(
                  Icons.delete,
                  color: Colors.yellow,
                ),
                onPressed: () {
                  deleteSelectedCars();
                },
              ),
            ),
          ],
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
                                  _searchController.clear();
                                  updateFilteredCars('');
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              filled: true,
                              fillColor: Colors.white,
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
                                    filterCarsByPassengerCount('2-5');
                                    Navigator.pop(context); // Close the dialog
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Text('2-5 Orang'),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    filterCarsByPassengerCount('6-9');
                                    Navigator.pop(context); // Close the dialog
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Text('6-9 Orang'),
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
                        Icon(
                          Icons.filter_list,
                          color: Colors.white,
                        ),
                        Text(
                          "Filter",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DriversScreen(),
                              ),
                            );
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
                  final bool isSelected = selectedCars.contains(carData);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10.0),
                    child: InkWell(
                      onTap: () {
                        if (isMultiSelectionEnabled) {
                          toggleCarSelection(carData);
                        } else {
                          navigateToCarDetail(carData);
                        }
                      },
                      onLongPress: () {
                        enableMultiSelection();
                        toggleCarSelection(carData);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color.fromARGB(255, 196, 228, 255)
                              : Colors.grey.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Row(
                          children: <Widget>[
                            Container(
                              margin: const EdgeInsets.only(top: 10.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: Container(
                                  height: 120.0,
                                  width: 185.0,
                                  child: Image.network(
                                    carData.imageUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                                width:
                                    16.0), // Add spacing between image and text
                            Expanded(
                              child: ListTile(
                                contentPadding: const EdgeInsets.only(
                                  right: 35.0,
                                ),
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      carData.name,
                                      style: const TextStyle(
                                        fontSize: 16.5,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      carData.type,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color:
                                            Color.fromARGB(255, 161, 161, 161),
                                      ),
                                    ),
                                    const SizedBox(
                                        height:
                                            6.0), // Add spacing between type and price
                                    const Text(
                                      "Harga Mulai Dari",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      '${carData.price.toString().formatPrice()} /Hari',
                                      style: const TextStyle(
                                        fontSize: 15.7,
                                        fontWeight: FontWeight.w500,
                                        color: Color.fromARGB(255, 123, 230, 2),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Checkbox untuk multi selection
                            Visibility(
                              visible: isMultiSelectionEnabled,
                              child: Checkbox(
                                value: isSelected,
                                onChanged: (bool? value) {
                                  toggleCarSelection(carData);
                                },
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
