import 'package:flutter/material.dart';
import 'package:seller_rent_car/model/driver_model.dart';

class DetailDriverScreen extends StatelessWidget {
  final DriverModel driverData;

  const DetailDriverScreen({required this.driverData});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF110925),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Detail Pengemudi',
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: size.height,
          child: Stack(
            children: [
              Container(
                height: size.height * 0.35,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(driverData.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: size.height * 4.5,
                  width: size.width * 1.5,
                  margin: EdgeInsets.only(top: size.height * 0.3),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF29233B),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 10,
                        blurRadius: 10,
                        offset: const Offset(0, 0),
                      ),
                    ],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildDetailItem('1. Nama Lengkap:', driverData.name),
                        buildDetailItem('2. No Telepon:', driverData.noTelp),
                        buildDetailItem(
                            '3. Alamat Domisili:', driverData.alamat),
                        buildDetailItem('4. No Sim:', driverData.noSim),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDetailItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Color(0xFF9588F9),
          ),
        ),
        const SizedBox(height: 8.0),
        Row(
          children: [
            const Icon(
              Icons.people,
              color: Colors.white,
            ),
            const SizedBox(width: 8.0),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }
}
