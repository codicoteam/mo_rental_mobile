// features/agent/checkout/checkout_screen.dart
import 'package:flutter/material.dart';


class CheckoutScreen extends StatefulWidget {
  final String bookingId;
  final String customerName;
  final String vehicleInfo;

  const CheckoutScreen({super.key, 
    required this.bookingId,
    required this.customerName,
    required this.vehicleInfo,
  });

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mileageController = TextEditingController();
  final _fuelController = TextEditingController();
  
  final List<String> _damagePhotos = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Vehicle Check-out", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Booking Info
              _buildInfoCard(),
              SizedBox(height: 20),

              // Mileage
              TextFormField(
                controller: _mileageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Current Mileage (km)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.speed, color: Colors.blue),
                ),
                validator: (value) => value!.isEmpty ? 'Enter current mileage' : null,
              ),
              SizedBox(height: 16),

              // Fuel Level
              TextFormField(
                controller: _fuelController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Fuel Level (%)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_gas_station, color: Colors.blue),
                ),
                validator: (value) => value!.isEmpty ? 'Enter fuel level' : null,
              ),
              SizedBox(height: 20),

              // Damage Photos Section
              _buildDamageSection(),
              SizedBox(height: 30),

              // Additional Notes
              TextFormField(
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Additional Notes",
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              SizedBox(height: 20),

              // Complete Checkout Button
              ElevatedButton(
                onPressed: _completeCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text("Complete Check-out", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Booking Details", 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[800])),
            SizedBox(height: 12),
            _buildInfoRow(Icons.confirmation_number, "Booking ID:", widget.bookingId),
            _buildInfoRow(Icons.person, "Customer:", widget.customerName),
            _buildInfoRow(Icons.directions_car, "Vehicle:", widget.vehicleInfo),
            _buildInfoRow(Icons.access_time, "Check-out Time:", _getCurrentTime()),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 16),
          SizedBox(width: 8),
          Text("$label ", style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildDamageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Damage Documentation", 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[800])),
        SizedBox(height: 12),
        Text("Take photos of any existing damage:", style: TextStyle(color: Colors.grey[600])),
        SizedBox(height: 12),
        
        // Photo Grid
        _damagePhotos.isEmpty 
            ? _buildEmptyPhotosState()
            : _buildPhotosGrid(),
        
        SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _simulateTakePhoto, // Replace with actual camera functionality
          icon: Icon(Icons.camera_alt, color: Colors.white),
          label: Text("Take Photo", style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyPhotosState() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_camera, color: Colors.grey, size: 40),
          SizedBox(height: 8),
          Text("No photos added", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildPhotosGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _damagePhotos.length,
      itemBuilder: (context, index) {
        return _buildPhotoThumbnail(_damagePhotos[index], index);
      },
    );
  }

  Widget _buildPhotoThumbnail(String photoPath, int index) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[200],
            image: DecorationImage(
              image: AssetImage(photoPath), // Using asset images for demo
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removePhoto(index),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              padding: EdgeInsets.all(2),
              child: Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }

  void _simulateTakePhoto() {
    // Simulate taking a photo - in real app, use image_picker
    setState(() {
      _damagePhotos.add('assets/car_damage_${_damagePhotos.length + 1}.png');
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Photo added successfully")),
    );
  }

  void _removePhoto(int index) {
    setState(() {
      _damagePhotos.removeAt(index);
    });
  }

  String _getCurrentTime() {
    return "${DateTime.now().hour}:${DateTime.now().minute}";
  }

  void _completeCheckout() {
    if (_formKey.currentState!.validate()) {
      // Process checkout
      final checkoutData = {
        'bookingId': widget.bookingId,
        'mileage': int.parse(_mileageController.text),
        'fuelLevel': int.parse(_fuelController.text),
        'damagePhotos': _damagePhotos,
        'timestamp': DateTime.now(),
      };
      
      // Show success dialog
      _showSuccessDialog(checkoutData);
    }
  }

  void _showSuccessDialog(Map<String, dynamic> checkoutData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Check-out Complete", style: TextStyle(color: Colors.green)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Vehicle check-out completed successfully!"),
              SizedBox(height: 16),
              Text("Booking: ${checkoutData['bookingId']}"),
              Text("Mileage: ${checkoutData['mileage']} km"),
              Text("Fuel Level: ${checkoutData['fuelLevel']}%"),
              Text("Photos: ${checkoutData['damagePhotos'].length} taken"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(checkoutData);
              },
              child: Text("OK", style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }
}