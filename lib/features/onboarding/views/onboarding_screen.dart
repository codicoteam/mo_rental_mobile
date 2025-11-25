// features/onboarding/screens/onboarding_screen.dart
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: "Welcome to Mo_Rental",
      description: "Your trusted car rental partner across Zimbabwe",
      image: "assets/images/onboarding1.jpeg",
    ),
    OnboardingPage(
      title: "Multiple Branches",
      description: "Available in Harare, Bulawayo, Mutare, Bindura and more",
      image: "assets/images/onboarding2.jpeg",
    ),
    OnboardingPage(
      title: "Choose Your Role",
      description: "Are you a customer or an agent?",
      image: "assets/images/onboarding3.jpeg",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: _pages.length,
              onPageChanged: (int page) {
                setState(() => _currentPage = page);
              },
              itemBuilder: (_, index) => _buildPage(_pages[index]),
            ),
          ),
          _buildIndicator(),
          _buildNavigation(),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(page.image, height: 250),
          SizedBox(height: 40),
          Text(
            page.title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            page.description,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _pages.asMap().entries.map((entry) {
        return Container(
          width: 8,
          height: 8,
          margin: EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == entry.key ? Colors.blue : Colors.grey[300],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNavigation() {
    return Padding(
      padding: EdgeInsets.all(24.0),
      child: _currentPage == _pages.length - 1
          ? _buildRoleSelection()
          : ElevatedButton(
              onPressed: () => _controller.nextPage(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeIn,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text("Next", style: TextStyle(color: Colors.white)),
            ),
    );
  }

  Widget _buildRoleSelection() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => Navigator.pushReplacementNamed(context, '/agent-auth'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            minimumSize: Size(double.infinity, 50),
          ),
          child: Text("I'm an Agent", style: TextStyle(color: Colors.white)),
        ),
        SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => Navigator.pushReplacementNamed(context, '/customer-auth'),
          style: OutlinedButton.styleFrom(
            minimumSize: Size(double.infinity, 50),
            side: BorderSide(color: Colors.blue),
          ),
          child: Text("I'm a Customer", style: TextStyle(color: Colors.blue)),
        ),
      ],
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final String image;

  OnboardingPage({required this.title, required this.description, required this.image});
}