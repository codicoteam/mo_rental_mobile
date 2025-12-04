import 'package:flutter/material.dart';

class OnboardPage extends StatelessWidget {
  final String title, subtitle, image;
  const OnboardPage(
      {super.key, required this.title, required this.subtitle, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(image),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 10),
            Text(subtitle,
                style: TextStyle(fontSize: 18, color: Colors.grey.shade300)),
            const SizedBox(height: 150),
          ],
        ),
      ),
    );
  }
}