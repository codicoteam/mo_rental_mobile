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

class _VehicleSelectionScreenState extends State<VehicleSelectionScreen>
    with TickerProviderStateMixin {  
  final GetStorage storage = GetStorage();
  List<dynamic> _vehicles = [];
  bool _isLoading = true;
  String _error = '';
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    
    _slideAnimation = Tween<double>(begin: -50.0, end: 0.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
    );
    
    _loadVehicles();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
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
      
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        if (jsonResponse['success'] == true) {
          if (jsonResponse['data'] is List) {
            setState(() {
              _vehicles = jsonResponse['data'] ?? [];
              _isLoading = false;
            });
          } else if (jsonResponse['data'] is Map) {
            final dataMap = jsonResponse['data'] as Map<String, dynamic>;
            
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
                if (dataMap.isNotEmpty) {
                  setState(() {
                    _vehicles = [dataMap];
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
    } finally {
      _fadeController.forward();
      _slideController.forward();
    }
  }

  void _selectVehicle(Map<String, dynamic> vehicle) {
    if (widget.isSelectionMode) {
      String? vehicleModelId;
      
      if (vehicle['vehicle_model_id'] != null) {
        if (vehicle['vehicle_model_id'] is String) {
          vehicleModelId = vehicle['vehicle_model_id'].toString();
        } else if (vehicle['vehicle_model_id'] is Map) {
          final modelObj = vehicle['vehicle_model_id'] as Map<String, dynamic>;
          vehicleModelId = modelObj['_id']?.toString();
        }
      } else if (vehicle['vehicle_model'] != null) {
        final modelObj = vehicle['vehicle_model'] as Map<String, dynamic>;
        vehicleModelId = modelObj['_id']?.toString() ?? modelObj['id']?.toString();
      }
      
      Get.back(result: {
        'vehicleId': vehicle['_id'] ?? vehicle['id'],
        'vehicleName': _getVehicleName(vehicle),
        'dailyRate': _getDailyRate(vehicle),
        'vehicleModelId': vehicleModelId ?? 'unknown',
      });
    } else {
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

    return vehicle['plate_number'] ?? 
           vehicle['vin'] ?? 
           'Vehicle ${vehicle['_id']?.substring(0, 8)}';
  }

  double _getDailyRate(Map<String, dynamic> vehicle) {
    dynamic vehicleModel;
    
    if (vehicle['vehicle_model'] != null) {
      vehicleModel = vehicle['vehicle_model'];
    } else if (vehicle['vehicle_model_id'] != null && vehicle['vehicle_model_id'] is Map) {
      vehicleModel = vehicle['vehicle_model_id'];
    }
    
    if (vehicleModel is Map<String, dynamic>) {
      if (vehicleModel['daily_rate'] is num) {
        return vehicleModel['daily_rate'].toDouble();
      }
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

    String vehicleClass = '';
    if (vehicleModel is Map<String, dynamic>) {
      vehicleClass = (vehicleModel['class'] ?? '').toString().toLowerCase();
    } else {
      vehicleClass = (vehicle['vehicle_class'] ?? '').toString().toLowerCase();
    }

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

  Widget _buildVehicleCard(Map<String, dynamic> vehicle, int index) {
    final vehicleName = _getVehicleName(vehicle);
    final plateNumber = vehicle['plate_number'] ?? 'No Plate';
    final dailyRate = _getDailyRate(vehicle);
    final isAvailable = vehicle['is_available'] ?? true;
    // ignore: unused_local_variable
    final status = vehicle['status'] ?? 'active';

    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * (1 - (index * 0.1).clamp(0.0, 1.0))),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
          border: Border.all(
            color: Colors.grey.shade100,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200.withOpacity(0.8),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.grey.shade100.withOpacity(0.5),
              blurRadius: 5,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: () => _selectVehicle(vehicle),
            borderRadius: BorderRadius.circular(20),
            splashColor: const Color(0xFF047BC1).withOpacity(0.1),
            highlightColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Vehicle Icon with Status
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: isAvailable
                            ? [
                                const Color(0xFF4CAF50).withOpacity(0.15),
                                const Color(0xFF4CAF50).withOpacity(0.05),
                              ]
                            : [
                                const Color(0xFFFF9800).withOpacity(0.15),
                                const Color(0xFFFF9800).withOpacity(0.05),
                              ],
                      ),
                      border: Border.all(
                        color: isAvailable
                            ? const Color(0xFF4CAF50).withOpacity(0.3)
                            : const Color(0xFFFF9800).withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.directions_car_rounded,
                        size: 32,
                        color: isAvailable ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Vehicle Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                vehicleName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: isAvailable
                                    ? LinearGradient(
                                        colors: [
                                          const Color(0xFF4CAF50).withOpacity(0.1),
                                          const Color(0xFF4CAF50).withOpacity(0.05),
                                        ],
                                      )
                                    : LinearGradient(
                                        colors: [
                                          const Color(0xFFFF9800).withOpacity(0.1),
                                          const Color(0xFFFF9800).withOpacity(0.05),
                                        ],
                                      ),
                                border: Border.all(
                                  color: isAvailable
                                      ? const Color(0xFF4CAF50).withOpacity(0.2)
                                      : const Color(0xFFFF9800).withOpacity(0.2),
                                ),
                              ),
                              child: Text(
                                isAvailable ? 'Available' : 'Unavailable',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isAvailable ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.badge_rounded,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Plate: $plateNumber',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 8),
                        
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.attach_money_rounded,
                                size: 16,
                                color: const Color(0xFF047BC1),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '\$${dailyRate.toStringAsFixed(2)} / day',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF047BC1),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.grey.shade100,
                                    Colors.grey.shade50,
                                  ],
                                ),
                              ),
                              child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    final totalVehicles = _vehicles.length;
    final availableVehicles = _vehicles.where((v) => (v as Map)['is_available'] == true).length;
    final activeVehicles = _vehicles.where((v) => (v as Map)['status'] == 'active').length;

    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_slideAnimation.value, 0),
          child: child,
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF047BC1),
              Color(0xFF4F46E5),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4F46E5).withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              value: totalVehicles,
              label: 'Total',
              icon: Icons.directions_car_rounded,
              color: Colors.white,
            ),
            _buildStatItem(
              value: availableVehicles,
              label: 'Available',
              icon: Icons.check_circle_rounded,
              color: const Color(0xFF4CAF50),
            ),
            _buildStatItem(
              value: activeVehicles,
              label: 'Active',
              icon: Icons.power_settings_new_rounded,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required int value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.2),
          ),
          child: Icon(
            icon,
            color: color,
            size: 22,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$value',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
        // AppBar with glassmorphism effect
SliverAppBar(
  expandedHeight: 140,
  floating: false,
  pinned: true,
  backgroundColor: Colors.white,
  surfaceTintColor: Colors.white,
  elevation: 0,
  flexibleSpace: FlexibleSpaceBar(
    collapseMode: CollapseMode.pin,
    background: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 70, left: 24, right: 24, bottom: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start, // CHANGED
          children: [
            Expanded( // ADDED
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // CHANGED
                children: [
                  Text(
                    widget.isSelectionMode ? 'Select Vehicle' : 'Browse Vehicles',
                    style: const TextStyle(
                      fontSize: 24, // REDUCED
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      letterSpacing: -0.5,
                    ),
                    maxLines: 1, // ADDED
                    overflow: TextOverflow.ellipsis, // ADDED
                  ),
                  const SizedBox(height: 2), // REDUCED
                  Text( // CHANGED: Removed Obx()
                    '${_vehicles.length} vehicles found',
                    style: TextStyle(
                      fontSize: 12, // REDUCED
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1, // ADDED
                    overflow: TextOverflow.ellipsis, // ADDED
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16), // ADDED
            Container(
              width: 40, // ADDED
              height: 40, // ADDED
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF047BC1).withOpacity(0.1),
                    const Color(0xFF4F46E5).withOpacity(0.1),
                  ],
                ),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.refresh_rounded,
                  color: const Color(0xFF047BC1),
                  size: 20, // REDUCED
                ),
                onPressed: _loadVehicles,
                tooltip: 'Refresh',
                padding: EdgeInsets.zero, // ADDED
              ),
            ),
          ],
        ),
      ),
    ),
  ),
),

        SliverToBoxAdapter(
  child: SingleChildScrollView( // ADDED
    child: _isLoading
        ? SizedBox(
            height: 400,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation(
                        const Color(0xFF047BC1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Loading vehicles...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          )
        : _error.isNotEmpty
            ? SizedBox(
                height: 400,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red.shade50,
                          gradient: LinearGradient(
                            colors: [
                              Colors.red.shade100,
                              Colors.red.shade50,
                            ],
                          ),
                        ),
                        child: const Icon(
                          Icons.error_outline_rounded,
                          color: Colors.red,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _error,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF047BC1), Color(0xFF4F46E5)],
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            onTap: _loadVehicles,
                            borderRadius: BorderRadius.circular(14),
                            child: const Center(
                              child: Text(
                                'Try Again',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : _vehicles.isEmpty
                ? SizedBox(
                    height: 400,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.grey.shade100,
                                  Colors.grey.shade50,
                                ],
                              ),
                            ),
                            child: const Icon(
                              Icons.directions_car_rounded,
                              size: 64,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'No Vehicles Available',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Please check back later',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            height: 52,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF047BC1), Color(0xFF4F46E5)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF4F46E5).withOpacity(0.3),
                                  blurRadius: 16,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                              child: InkWell(
                                onTap: _loadVehicles,
                                borderRadius: BorderRadius.circular(14),
                                child: const Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.refresh_rounded,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Refresh',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: [
                      _buildStatsCard(),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 100),
                        itemCount: _vehicles.length,
                        itemBuilder: (context, index) => 
                            _buildVehicleCard(_vehicles[index] as Map<String, dynamic>, index),
                      ),
                    ],
                  ),
  ),
),
        ],
      ),
    );
  }
}