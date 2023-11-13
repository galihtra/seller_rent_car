import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:seller_rent_car/pages/auth/login_screen.dart';
import 'package:seller_rent_car/pages/profile/edit_profile_screen.dart';
import 'package:seller_rent_car/pages/profile/widgets/profile_card_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<DocumentSnapshot> getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    } else {
      throw ("No user logged in");
    }
  }

  String? userName = "";
  String? userEmail = "";
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    getUserData().then((userData) {
      if (userData.data() != null) {
        Map<String, dynamic?> data = userData.data() as Map<String, dynamic?>;
        setState(() {
          userName = data['name'] as String? ?? "";
          userEmail = data['email'] as String? ?? "";
          profileImageUrl = data['imageURL'] as String? ?? "";
        });
      }
    });
  }

  Future<void> _updateUserData() async {
    getUserData().then((userData) {
      if (userData.data() != null) {
        Map<String, dynamic?> data = userData.data() as Map<String, dynamic?>;
        setState(() {
          userName = data['name'] as String? ?? "";
          userEmail = data['email'] as String? ?? "";
          profileImageUrl = data['imageURL'] as String? ?? "";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            width: double.infinity,
            height: 150.0,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.redAccent, Colors.pinkAccent],
              ),
            ),
          ),

          // Konten Profil
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 100.0),
                Container(
                  width: 340.0, // Lebar Kartu
                  height: 85.0, // Tinggi Kartu
                  child: Card(
                    margin: const EdgeInsets.all(0.0),
                    clipBehavior: Clip.antiAlias,
                    color: Colors.white,
                    elevation: 5.0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15.0, vertical: 12.0),
                      child: Row(
                        children: <Widget>[
                          const SizedBox(width: 15.0),
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: profileImageUrl != null &&
                                    profileImageUrl!.isNotEmpty
                                ? NetworkImage(profileImageUrl!)
                                : const AssetImage(
                                        'assets/images/default_avatar.jpg')
                                    as ImageProvider<Object>,
                          ),
                          const SizedBox(width: 20.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  userName ??
                                      "", 
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                  height: 5.0,
                                ),
                                Text(
                                  userEmail ??
                                      "",
                                  style: const TextStyle(
                                    fontSize: 20.0,
                                    color: Colors.pinkAccent,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: 220.0,
            left: 5.0,
            right: 5.0,
            child: Card(
              margin:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
              clipBehavior: Clip.antiAlias,
              color: Colors.white,
              elevation: 5.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 22.0),
                child: Column(
                  children: [
                    buildProfileCard(
                      'Pengaturan Akun',
                      Icons.account_circle,
                      () {
                        print("Pengaturan Akun");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfileScreen(),
                          ),
                        ).then((result) {
                          if (result != null && result) {
                            
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Profil Diperbarui"),
                                  content:
                                      const Text("Data profil berhasil diperbarui."),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                     
                                        Navigator.of(context).pop();
                                        _updateUserData();
                                      },
                                      child: const Text("OK"),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 20.0),
                    buildProfileCard(
                      'Panduan Rental',
                      Icons.book,
                      () {
                        print("Panduan Rental");
                      },
                    ),
                    const SizedBox(height: 20.0),
                    buildProfileCard(
                      'Keluar Akun',
                      Icons.exit_to_app,
                      () {
                        print("Keluar Akun");
                        _auth.signOut();
                        Navigator.pushAndRemoveUntil(context,
                            MaterialPageRoute(builder: (context) {
                          return const LoginScreen();
                        }), (route) => false);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
