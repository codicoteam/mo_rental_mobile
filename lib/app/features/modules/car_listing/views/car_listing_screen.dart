import 'package:flutter/material.dart';

import '../../car_details/views/car_detail_screen.dart';

class CarListingScreen extends StatelessWidget {
  const CarListingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Available Cars")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          carTile(context, "assets/images/campbell-3ZUsNJhi_Ik-unsplash.jpg", "BMW M4", "R1500/day"),
          carTile(context, "assets/images/joshua-koblin-eqW1MPinEV4-unsplash.jpg", "Mercedes AMG", "R1800/day"),
          carTile(context, "assets/images/peter-broomfield-m3m-lnR90uM-unsplash.jpg", "Audi R8", "R2500/day"),
        ],
      ),
    );
  }

  Widget carTile(BuildContext context, String img, String name, String price) {
    return ListTile(
      leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(img, width: 60, fit: BoxFit.cover)),
      title: Text(name),
      subtitle: Text(price, style: const TextStyle(color: Colors.grey)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => CarDetailsScreen(carName: name, image: img)));
      },
    );
  }
}