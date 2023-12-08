import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:seller_rent_car/pages/auth/signup_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../dashboard/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passController = TextEditingController();

  String _email = "";
  String _password = "";
  bool _isPasswordVisible = true; // Untuk mengontrol tampilan kata sandi

  void _handleLogin() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _email,
        password: _password,
      );
      // Dapatkan data pengguna dari Firestore berdasarkan UID
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final isAdmin = userData['isAdmin'] as bool;

        if (isAdmin) {
          // Jika isAdmin adalah true, izinkan login
          Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (context) {
            return const DashboardScreen();
          }), (route) => false);
          print("Admin Logged In: ${userCredential.user!.email}");
        } else {
          // Jika isAdmin adalah false, tampilkan pesan kesalahan
          print("User is not an admin.");
        }
      } else {
        // Jika data pengguna tidak ditemukan, tampilkan pesan kesalahan
        print("User data not found.");
      }
    } catch (e) {
      print("Error During Logged In: $e");
    }
  }

  void _showErrorAlert(String errorMessage) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Login Gagal"),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF110925),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 100),
                const Text(
                  "ONICARS", // Tambahkan teks ONICARS di sini
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF9588F9),
                  ),
                ),
                const SizedBox(
                  height: 200,
                ),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Alamat Email",
                    filled:
                        true, // Mengatur background menjadi filled (dengan warna putih)
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Masukkan Alamat Email Anda";
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _email = value;
                    });
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _passController,
                  obscureText:
                      !_isPasswordVisible, // Mengontrol tampilan kata sandi
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: "Kata Sandi",
                    filled:
                        true, // Mengatur background menjadi filled (dengan warna putih)
                    fillColor: Colors.white,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Masukkan Kata Sandi Anda";
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _password = value;
                    });
                  },
                ),
                const SizedBox(
                  height: 100,
                ),
                Container(
                  width: 260,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _handleLogin();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      primary:
                          Color(0xFF9588F9), // Ubah warna latar belakang tombol
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Text(
                      "Masuk",
                      style: TextStyle(
                        fontSize: 18, // Ubah ukuran teks sesuai keinginan Anda
                        fontWeight: FontWeight.bold,
                      ), // Menjadikan teks tebal
                    ),
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Belum punya akun? ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontFamily: 'Inter',
                        ),
                      ),
                      TextSpan(
                        text: 'Daftar',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.green,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushAndRemoveUntil(context,
                                MaterialPageRoute(builder: (context) {
                              return const SignUpScreen();
                            }), (route) => false);
                          },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
