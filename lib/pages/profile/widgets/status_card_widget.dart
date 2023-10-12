import 'package:flutter/material.dart';

class StatusCard extends StatelessWidget {
  final String title;
  final IconData iconData;
  final Color iconColor;

  StatusCard({required this.title, required this.iconData, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Icon(
            iconData,
            size: 30,
            color: iconColor,
          ),
          SizedBox(height: 5.0),
          Text(
            title,
            style: TextStyle(
              fontSize: 18.0,
            ),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}