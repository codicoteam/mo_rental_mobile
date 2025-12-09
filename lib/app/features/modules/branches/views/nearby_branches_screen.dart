import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../controllers/branch_controller.dart';

class NearbyBranchesScreen extends StatefulWidget {
  const NearbyBranchesScreen({super.key});

  @override
  State<NearbyBranchesScreen> createState() => _NearbyBranchesScreenState();
}

class _NearbyBranchesScreenState extends State<NearbyBranchesScreen> {
  final BranchController _controller = Get.find<BranchController>();
  bool _locationPermissionGranted = false;
  bool _isGettingLocation = false;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

 Future<void> _checkLocationPermission() async {
  try {
    final status = await Permission.location.status;
    
    if (status.isDenied) {
      final result = await Permission.location.request();
      
      if (result.isPermanentlyDenied) {
        setState(() {
          _locationPermissionGranted = false;
        });
        
        // Show dialog to open app settings
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Location Permission Required'),
            content: const Text(
              'This app needs location access to find nearby branches. '
              'Please enable location permissions in app settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Get.back();
                  openAppSettings();
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
        return;
      }
      
      setState(() {
        _locationPermissionGranted = result.isGranted;
      });
    } else if (status.isGranted) {
      setState(() {
        _locationPermissionGranted = true;
      });
    }
    
    if (_locationPermissionGranted) {
      await _getCurrentLocation();
    }
  } catch (e) {
    print('❌ Error checking location permission: $e');
    Get.snackbar(
      'Location Error',
      'Unable to access location services.',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}
  Future<void> _getCurrentLocation() async {
    try {
      setState(() {
        _isGettingLocation = true;
      });

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      _controller.updateUserLocation(
        position.latitude,
        position.longitude,
      );

      // Find nearby branches
      await _controller.findNearbyBranches();

      Get.snackbar(
        'Location Found',
        'Found ${_controller.nearbyBranches.length} branches nearby',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ Error getting location: $e');
      Get.snackbar(
        'Location Error',
        'Unable to get current location. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isGettingLocation = false;
      });
    }
  }

  Future<void> _refreshNearbyBranches() async {
    if (_locationPermissionGranted) {
      await _getCurrentLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Branches'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshNearbyBranches,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showRadiusSettings(),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location Status Card
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          _locationPermissionGranted
                              ? Icons.location_on
                              : Icons.location_off,
                          color: _locationPermissionGranted
                              ? Colors.green
                              : Colors.red,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _locationPermissionGranted
                                    ? 'Location Access Granted'
                                    : 'Location Access Required',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _locationPermissionGranted
                                    ? 'Searching within ${_controller.searchRadius.value ~/ 1000}km radius'
                                    : 'Enable location to find nearby branches',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (!_locationPermissionGranted) ...[
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _checkLocationPermission,
                        icon: const Icon(Icons.location_on),
                        label: const Text('Enable Location Access'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Radius Selector
            Obx(() {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Search Radius',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Slider(
                        value: _controller.searchRadius.value.toDouble(),
                        min: 1000,
                        max: 20000,
                        divisions: 19,
                        label: '${_controller.searchRadius.value ~/ 1000}km',
                        onChanged: (value) {
                          _controller.setSearchRadius(value.toInt());
                        },
                        onChangeEnd: (value) async {
                          if (_locationPermissionGranted) {
                            await _controller.findNearbyBranches();
                          }
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('1km'),
                          Text('5km'),
                          Text('10km'),
                          Text('15km'),
                          Text('20km'),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),

            // Nearby Branches List
            Expanded(
              child: Obx(() {
                if (_isGettingLocation) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Finding your location...'),
                      ],
                    ),
                  );
                }

                if (!_locationPermissionGranted) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_off, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'Location Access Required',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Enable location services to find branches near you',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _checkLocationPermission,
                          icon: const Icon(Icons.location_on),
                          label: const Text('Enable Location'),
                        ),
                      ],
                    ),
                  );
                }

                if (_controller.isLoadingNearby.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (_controller.nearbyError.value.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        const Text(
                          'Error Finding Nearby Branches',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _controller.nearbyError.value,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _refreshNearbyBranches,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try Again'),
                        ),
                      ],
                    ),
                  );
                }

                if (_controller.nearbyBranches.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_searching, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'No Branches Nearby',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No branches found within ${_controller.searchRadius.value ~/ 1000}km radius',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _refreshNearbyBranches,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Search Again'),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _refreshNearbyBranches,
                  child: ListView.builder(
                    itemCount: _controller.nearbyBranches.length,
                    itemBuilder: (context, index) {
                      final branch = _controller.nearbyBranches[index];
                      final distance = _controller.getDistanceToBranch(branch);
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () {
                            _controller.selectBranch(branch);
                            Get.toNamed(
                              '/branches/detail',
                              arguments: branch,
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Distance Indicator
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          size: 20,
                                          color: Colors.blue,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          distance.contains('km')
                                              ? distance.split(' ')[0]
                                              : distance.split(' ')[0],
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        branch.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        branch.code,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        branch.address.shortAddress,
                                        style: const TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right, color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: _locationPermissionGranted
          ? FloatingActionButton.extended(
              onPressed: _refreshNearbyBranches,
              icon: const Icon(Icons.my_location),
              label: const Text('Refresh'),
              backgroundColor: Colors.blue,
            )
          : null,
    );
  }

  void _showRadiusSettings() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Search Settings'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(() {
                  return Column(
                    children: [
                      const Text('Search Radius (kilometers):'),
                      const SizedBox(height: 16),
                      Slider(
                        value: _controller.searchRadius.value / 1000,
                        min: 1,
                        max: 20,
                        divisions: 19,
                        label: '${_controller.searchRadius.value ~/ 1000}km',
                        onChanged: (value) {
                          _controller.setSearchRadius((value * 1000).toInt());
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_controller.searchRadius.value ~/ 1000} kilometers',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _controller.setSearchRadius(5000); // Reset to 5km
                Get.back();
              },
              child: const Text('Reset'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_locationPermissionGranted) {
                  _controller.findNearbyBranches();
                }
                Get.back();
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }
}

