// features/agent/vehicles/vehicle_assignment_screen.dart
import 'package:flutter/material.dart';

class VehicleAssignmentScreen extends StatefulWidget {
  final String bookingId;
  final String customerName;

  const VehicleAssignmentScreen({super.key, required this.bookingId, required this.customerName});

  @override
  _VehicleAssignmentScreenState createState() => _VehicleAssignmentScreenState();
}

class _VehicleAssignmentScreenState extends State<VehicleAssignmentScreen> {
  List<Vehicle> _availableVehicles = [];
  Vehicle? _selectedVehicle;

  @override
  void initState() {
    super.initState();
    _loadAvailableVehicles();
  }

  Future<void> _loadAvailableVehicles() async {
    // Mock data - replace with API call
    setState(() {
      _availableVehicles = [
        Vehicle(
          id: '1',
          make: 'Toyota',
          model: 'Corolla',
          year: 2023,
          plate: 'ABC1234',
          branch: 'Harare Central',
          fuelLevel: 85,
          mileage: 15000,
          status: VehicleStatus.available,
        ),
        Vehicle(
          id: '2',
          make: 'Honda',
          model: 'CR-V',
          year: 2022,
          plate: 'DEF5678',
          branch: 'Harare Central',
          fuelLevel: 90,
          mileage: 12000,
          status: VehicleStatus.available,
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Assign Vehicle", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Booking Info
          Card(
            margin: EdgeInsets.all(16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Booking #${widget.bookingId}", 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text("Customer: ${widget.customerName}"),
                ],
              ),
            ),
          ),

          // Available Vehicles
          Expanded(
            child: ListView.builder(
              itemCount: _availableVehicles.length,
              itemBuilder: (context, index) {
                final vehicle = _availableVehicles[index];
                return _buildVehicleCard(vehicle);
              },
            ),
          ),

          // Assign Button
          Padding(
            padding: EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _selectedVehicle != null ? _assignVehicle : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text("Assign Vehicle", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCard(Vehicle vehicle) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(Icons.directions_car, color: Colors.blue, size: 40),
        title: Text("${vehicle.make} ${vehicle.model} (${vehicle.year})"),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Plate: ${vehicle.plate}"),
            Text("Mileage: ${vehicle.mileage} km"),
            Text("Fuel: ${vehicle.fuelLevel}%"),
          ],
        ),
        trailing: Radio<Vehicle>(
          value: vehicle,
          groupValue: _selectedVehicle,
          onChanged: (Vehicle? value) {
            setState(() => _selectedVehicle = value);
          },
        ),
        onTap: () {
          setState(() => _selectedVehicle = vehicle);
        },
      ),
    );
  }

  void _assignVehicle() {
    if (_selectedVehicle != null) {
      // Implement assignment logic
      Navigator.pop(context, _selectedVehicle);
    }
  }
}

class Vehicle {
  final String id;
  final String make;
  final String model;
  final int year;
  final String plate;
  final String branch;
  final int fuelLevel;
  final int mileage;
  final VehicleStatus status;

  Vehicle({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.plate,
    required this.branch,
    required this.fuelLevel,
    required this.mileage,
    required this.status,
  });
}

enum VehicleStatus { available, rented, maintenance, reserved }