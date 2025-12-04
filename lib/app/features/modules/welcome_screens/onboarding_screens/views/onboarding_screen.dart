import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../widgets/onboardpage_widget/onboardpage_widget.dart';
import 'final_onboarding_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController controller = PageController();
  int currentPage = 0;

  final pages = [
    OnboardPage(
        title: "Welcome to MO_RENTAL",
        subtitle: "Rent any car fast and easy",
        image: "assets/images/campbell-3ZUsNJhi_Ik-unsplash.jpg"),
    OnboardPage(
        title: "Affordable Prices",
        subtitle: "Best rental prices in your area",
        image: "assets/images/joshua-koblin-eqW1MPinEV4-unsplash.jpg"),
    OnboardPage(
        title: "Choose Any Car",
        subtitle: "Luxury, sport, family — we got you",
        image: "assets/images/peter-broomfield-m3m-lnR90uM-unsplash.jpg"),
    OnboardPage(
        title: "Let's Get Started",
        subtitle: "Create your account now",
        image: "assets/images/peter-broomfield-m3m-lnR90uM-unsplash.jpg"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: controller,
            itemCount: pages.length,
            onPageChanged: (index) {
              setState(() => currentPage = index);
            },
            itemBuilder: (context, i) => pages[i],
          ),

          // DOT INDICATORS
          Positioned(
            bottom: 90,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 10,
                  width: currentPage == i ? 25 : 10,
                  decoration: BoxDecoration(
                    color: currentPage == i ? Colors.white : Colors.grey,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ),

          // NEXT / GET STARTED BUTTON
          Positioned(
            bottom: 25,
            left: 30,
            right: 30,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14))),
              onPressed: () {
                if (currentPage == pages.length - 1) {
                  // Navigate to FinalOnboardPage instead of Home
                  Get.off(() => const FinalOnboardPage());
                } else {
                  controller.nextPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOut);
                }
              },
              child: Text(currentPage == pages.length - 1
                  ? "Get Started"
                  : "Next"),
            ),
          )
        ],
      ),
    );
  }
}
