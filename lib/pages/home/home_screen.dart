import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:seller_rent_car/pages/auth/login_screen.dart';
import 'package:seller_rent_car/pages/car/add_car.dart';
import 'package:seller_rent_car/pages/promo/promo_screen.dart';
import 'package:seller_rent_car/pages/home/widgets/status_card_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    String? userEmail = _auth.currentUser!.email;
    return Scaffold(
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
        body: SingleChildScrollView(
          child: // Kartu Status
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
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment
                            .spaceBetween, // Menambahkan space di antara elemen-elemen
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
                            onTap: () {},
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
                    const SizedBox(
                      height: 30,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 40.0, right: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment
                            .spaceBetween, // Menambahkan space di antara elemen-elemen
                        children: <Widget>[
                          FiturCard(
                            title: "Edit",
                            iconData: Icons.edit_document,
                            iconColor: Colors.red,
                            onTap: () {},
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 35.0),
                            child: FiturCard(
                              title: "Hapus",
                              iconData: Icons.delete,
                              iconColor: Colors.blue,
                              onTap: () {},
                            ),
                          ),
                          FiturCard(
                            title: "Sembunyikan",
                            iconData: Icons.visibility_off,
                            iconColor: Colors.green,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
