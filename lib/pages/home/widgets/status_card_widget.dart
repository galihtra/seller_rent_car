import 'package:flutter/material.dart';

class FiturCard extends StatelessWidget {
  final String title;
  final IconData iconData;
  final Color iconColor;
  final VoidCallback? onTap;

  const FiturCard({super.key, 
    required this.title,
    required this.iconData,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Expanded(
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
      ),
    );
  }
}
