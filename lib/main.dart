import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/core/themes/app_theme.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';

void main() async {
  // Initialize GetStorage
  await GetStorage.init();
  
  runApp(const MoRentalApp());
}

class MoRentalApp extends StatelessWidget {
  const MoRentalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "MoRental",
      
      // Theme setup
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,

      // Navigation setup
      initialRoute: AppRoutes.login,
      getPages: AppPages.pages,
      
      // Enable GetX logging in debug mode
      enableLog: true,
      logWriterCallback: (String text, {bool isError = false}) {
        if (isError || Get.isLogEnable) print(text);
      },
      
      // REMOVE THIS for now
      // onInit: () {
      //   WidgetsBinding.instance.addPostFrameCallback((_) async {
      //     await Future.delayed(Duration(seconds: 2));
      //     Get.toNamed(
      //       AppRoutes.createReservation,
      //       arguments: {
      //         'vehicleId': 'test_vehicle_123',
      //         'vehicleName': 'Toyota Camry 2023',
      //         'dailyRate': 75.0,
      //         'startDate': DateTime.now(),
      //         'endDate': DateTime.now().add(Duration(days: 3)),
      //       },
      //     );
      //   });
      // },
    );
  }
}