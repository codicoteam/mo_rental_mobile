import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VehicleSelectionScreen extends StatefulWidget {
  final bool isSelectionMode;

  const VehicleSelectionScreen({
    super.key,
    this.isSelectionMode = true,
  });

  @override
  State<VehicleSelectionScreen> createState() => _VehicleSelectionScreenState();
}

class _VehicleSelectionScreenState extends State<VehicleSelectionScreen> {
  final GetStorage storage = GetStorage();
  List<dynamic> _vehicles = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      // Get auth token
      final token = storage.read('auth_token');
      if (token == null) {
        throw Exception('Please login first');
      }

      // Get base URL
      final baseUrl = storage.read('api_base_url') ?? 'http://13.61.185.238:5050';

      // Fetch vehicles using http package
      final url = Uri.parse('$baseUrl/api/v1/vehicles?limit=100');
      
      print('🚗 Loading vehicles from: $url');
      
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print('📊 Response status: ${response.statusCode}');
      print('📄 Response length: ${response.body.length}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print('📦 API Response structure: ${jsonResponse.keys}');
        
        if (jsonResponse['success'] == true) {
          // Check if data is a List or contains a List
          if (jsonResponse['data'] is List) {
            // Data is already a List
            setState(() {
              _vehicles = jsonResponse['data'] ?? [];
              _isLoading = false;
            });
          } else if (jsonResponse['data'] is Map) {
            // Data is a Map, check for common keys that might contain the list
            final dataMap = jsonResponse['data'] as Map<String, dynamic>;
            
            // Try different possible keys that might contain vehicles
            if (dataMap.containsKey('vehicles') && dataMap['vehicles'] is List) {
              setState(() {
                _vehicles = dataMap['vehicles'];
                _isLoading = false;
              });
            } else if (dataMap.containsKey('items') && dataMap['items'] is List) {
              setState(() {
                _vehicles = dataMap['items'];
                _isLoading = false;
              });
            } else if (dataMap.containsKey('results') && dataMap['results'] is List) {
              setState(() {
                _vehicles = dataMap['results'];
                _isLoading = false;
              });
            } else if (dataMap.containsKey('docs') && dataMap['docs'] is List) {
              setState(() {
                _vehicles = dataMap['docs'];
                _isLoading = false;
              });
            } else {
              // Try to extract any List from the data Map
              final List<dynamic> foundList = [];
              dataMap.forEach((key, value) {
                if (value is List) {
                  foundList.addAll(value);
                }
              });
              
              if (foundList.isNotEmpty) {
                setState(() {
                  _vehicles = foundList;
                  _isLoading = false;
                });
              } else {
                // Check if the Map contains vehicle data directly (single vehicle)
                if (dataMap.isNotEmpty) {
                  setState(() {
                    _vehicles = [dataMap]; // Wrap single vehicle in a list
                    _isLoading = false;
                  });
                } else {
                  throw Exception('No vehicle data found in response');
                }
              }
            }
          } else {
            throw Exception('Unexpected data format: ${jsonResponse['data']?.runtimeType}');
          }

          print('✅ Loaded ${_vehicles.length} vehicles for selection');
          if (_vehicles.isNotEmpty) {
            print('📋 First vehicle keys: ${_vehicles[0].keys}');
          }
        } else {
          throw Exception('API returned success: false - ${jsonResponse['message']}');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      print('❌ Error loading vehicles: $e');
    }
  }

  void _selectVehicle(Map<String, dynamic> vehicle) {
    if (widget.isSelectionMode) {
      // Extract vehicle_model_id from vehicle or vehicle_model
      String? vehicleModelId;
      
      if (vehicle['vehicle_model_id'] != null) {
        vehicleModelId = vehicle['vehicle_model_id'].toString();
      } else if (vehicle['vehicle_model'] != null) {
        vehicleModelId = vehicle['vehicle_model']['_id']?.toString() ?? 
                        vehicle['vehicle_model']['id']?.toString();
      }
      
      // Return selected vehicle data
      Get.back(result: {
        'vehicleId': vehicle['_id'] ?? vehicle['id'],
        'vehicleName': _getVehicleName(vehicle),
        'dailyRate': _getDailyRate(vehicle),
        'vehicleModelId': vehicleModelId ?? 'unknown',
      });
    } else {
      // Show vehicle details
      Get.toNamed(
        '/vehicle-detail',
        arguments: vehicle,
      );
    }
  }

  String _getVehicleName(Map<String, dynamic> vehicle) {
    final vehicleModel = vehicle['vehicle_model'] ?? {};
    final make = vehicleModel['make'] ?? '';
    final model = vehicleModel['model'] ?? '';
    final year = vehicleModel['year']?.toString() ?? '';

    if (make.isNotEmpty && model.isNotEmpty) {
      return '$year $make $model'.trim();
    }

    // Fallback to plate number or other identifiers
    return vehicle['plate_number'] ?? 
           vehicle['vin'] ?? 
           'Vehicle ${vehicle['_id']?.substring(0, 8)}';
  }

  double _getDailyRate(Map<String, dynamic> vehicle) {
    final vehicleModel = vehicle['vehicle_model'] ?? {};
    
    // Try different possible rate fields
    if (vehicleModel['daily_rate'] is num) {
      return vehicleModel['daily_rate'].toDouble();
    }
    
    if (vehicle['daily_rate'] is num) {
      return vehicle['daily_rate'].toDouble();
    }
    
    if (vehicle['rate_per_day'] is num) {
      return vehicle['rate_per_day'].toDouble();
    }
    
    if (vehicle['price_per_day'] is num) {
      return vehicle['price_per_day'].toDouble();
    }

    // Default rates based on vehicle class
    final vehicleClass = (vehicleModel['class'] ?? 
                         vehicle['vehicle_class'] ?? 
                         '').toString().toLowerCase();

    switch (vehicleClass) {
      case 'economy':
        return 30.0;
      case 'compact':
        return 40.0;
      case 'standard':
        return 50.0;
      case 'luxury':
        return 80.0;
      case 'suv':
        return 70.0;
      default:
        return 50.0;
    }
  }

  Widget _buildVehicleCard(int index) {
    final vehicle = _vehicles[index] as Map<String, dynamic>;
    final vehicleName = _getVehicleName(vehicle);
    final plateNumber = vehicle['plate_number'] ?? 'No Plate';
    final dailyRate = _getDailyRate(vehicle);
    final isAvailable = vehicle['is_available'] ?? true;
    final status = vehicle['status'] ?? 'active';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isAvailable ? Colors.green.shade50 : Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.directions_car,
            size: 30,
            color: isAvailable ? Colors.green : Colors.orange,
          ),
        ),
        title: Text(
          vehicleName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text('Plate: $plateNumber'),
            SizedBox(height: 2),
            Text(
              'Status: ${status.toUpperCase()}',
              style: TextStyle(
                fontSize: 12,
                color: status == 'active' ? Colors.green : Colors.orange,
              ),
            ),
            SizedBox(height: 2),
            Text(
              '\$${dailyRate.toStringAsFixed(2)}/day',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isAvailable ? Colors.green.shade50 : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isAvailable ? 'Available' : 'Unavailable',
                style: TextStyle(
                  color: isAvailable ? Colors.green : Colors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
        onTap: () => _selectVehicle(vehicle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isSelectionMode ? 'Select a Vehicle' : 'Browse Vehicles',
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadVehicles,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading vehicles...'),
                ],
              ),
            )
          : _error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, color: Colors.red, size: 48),
                      SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _error,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadVehicles,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _vehicles.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.directions_car, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No vehicles available',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Please check back later',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadVehicles,
                            child: Text('Refresh'),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        // Summary card
                        Container(
                          padding: EdgeInsets.all(12),
                          color: Colors.blue.shade50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    '${_vehicles.length}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  Text(
                                    'Total',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    '${_vehicles.where((v) => (v as Map)['is_available'] == true).length}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  Text(
                                    'Available',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    '${_vehicles.where((v) => (v as Map)['status'] == 'active').length}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  Text(
                                    'Active',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _vehicles.length,
                            itemBuilder: (context, index) => _buildVehicleCard(index),
                          ),
                        ),
                      ],
                    ),
    );
  }
}