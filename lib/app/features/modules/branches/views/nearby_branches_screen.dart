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

class _NearbyBranchesScreenState extends State<NearbyBranchesScreen>
    with TickerProviderStateMixin {
  final BranchController _controller = Get.find<BranchController>();
  bool _locationPermissionGranted = false;
  bool _isGettingLocation = false;
  bool _initialized = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;

  // Add this helper method to the STATE class
  bool _isBranchWithinRadius(String distance) {
    if (!distance.contains('km')) return false;
    
    try {
      final distanceValue = double.tryParse(distance.split(' ')[0]);
      if (distanceValue == null) return false;
      
      final radiusInKm = _controller.searchRadius.value / 1000;
      return distanceValue <= radiusInKm;
    } catch (e) {
      return false;
    }
  }

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

    _slideAnimation = Tween<double>(begin: -30.0, end: 0.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _checkLocationPermission();
      setState(() {
        _initialized = true;
      });
      _fadeController.forward();
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
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
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
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
      _showSnackBar(
        'Location Error',
        'Unable to access location services.',
        Colors.red,
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

      await _controller.findNearbyBranches();

      // Show branches even if far away (show all branches with distance)
      if (_controller.nearbyBranches.isEmpty && _controller.branches.isNotEmpty) {
        // Calculate distance for all branches and sort by distance
        await _controller.calculateDistanceForAllBranches();
      }

      final nearbyCount = _controller.nearbyBranches.length;
      final totalCount = _controller.branches.length;
      
      if (nearbyCount > 0) {
        _showSnackBar(
          'Location Found',
          'Found $nearbyCount branches within ${_controller.searchRadius.value ~/ 1000}km',
          const Color(0xFF4CAF50),
        );
      } else if (totalCount > 0) {
        _showSnackBar(
          'Location Found',
          'Showing $totalCount branches sorted by distance',
          const Color(0xFFFF9800),
        );
      }
    } catch (e) {
      print('❌ Error getting location: $e');
      _showSnackBar(
        'Location Error',
        'Unable to get current location. Please try again.',
        Colors.red,
      );
    } finally {
      setState(() {
        _isGettingLocation = false;
      });
    }
  }

  void _showSnackBar(String title, String message, Color backgroundColor) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _refreshNearbyBranches() async {
    if (_locationPermissionGranted) {
      await _getCurrentLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nearby Branches',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            if (_initialized && _locationPermissionGranted)
              Obx(() => Text(
                    'Searching within ${_controller.searchRadius.value ~/ 1000}km radius',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ))
            else if (_initialized)
              Text(
                'Enable location to begin',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
        actions: [
          if (_initialized && _locationPermissionGranted) ...[
            _buildActionButton(
              icon: Icons.refresh_rounded,
              onPressed: _refreshNearbyBranches,
              tooltip: 'Refresh',
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              icon: Icons.tune_rounded,
              onPressed: _showRadiusSettings,
              tooltip: 'Settings',
            ),
          ],
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshNearbyBranches,
          backgroundColor: Colors.white,
          color: const Color(0xFF047BC1),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location Status Card with Glassmorphism
                  if (_initialized)
                    AnimatedBuilder(
                      animation: _slideController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(_slideAnimation.value, 0),
                          child: child,
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white,
                              const Color(0xFF047BC1).withOpacity(0.03),
                            ],
                          ),
                          border: Border.all(
                            color: Colors.grey[100]!,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey[200]!.withOpacity(0.6),
                              blurRadius: 20,
                              spreadRadius: 2,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: _locationPermissionGranted
                                          ? [
                                              const Color(0xFF4CAF50)
                                                  .withOpacity(0.15),
                                              const Color(0xFF4CAF50)
                                                  .withOpacity(0.05),
                                            ]
                                          : [
                                              Colors.red.withOpacity(0.15),
                                              Colors.red.withOpacity(0.05),
                                            ],
                                    ),
                                    border: Border.all(
                                      color: _locationPermissionGranted
                                          ? const Color(0xFF4CAF50)
                                              .withOpacity(0.3)
                                          : Colors.red.withOpacity(0.3),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      _locationPermissionGranted
                                          ? Icons.location_on_rounded
                                          : Icons.location_off_rounded,
                                      color: _locationPermissionGranted
                                          ? const Color(0xFF4CAF50)
                                          : Colors.red,
                                      size: 28,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _locationPermissionGranted
                                            ? 'Location Access Granted'
                                            : 'Location Access Required',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        _locationPermissionGranted
                                            ? 'Ready to find nearby branches'
                                            : 'Enable location to find branches near you',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (!_locationPermissionGranted) ...[
                              const SizedBox(height: 20),
                              Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF047BC1), Color(0xFF4F46E5)],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          const Color(0xFF4F46E5).withOpacity(0.3),
                                      blurRadius: 16,
                                      spreadRadius: 0,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                  child: InkWell(
                                    onTap: _checkLocationPermission,
                                    borderRadius: BorderRadius.circular(16),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Icon(
                                          Icons.location_on_rounded,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          'Enable Location Access',
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
                            ],
                          ],
                        ),
                      ),
                    ),

                  // Radius Selector with Modern Design
                  if (_initialized && _locationPermissionGranted)
                    Obx(() {
                      return AnimatedBuilder(
                        animation: _fadeController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _fadeAnimation.value,
                            child: child,
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white,
                                Colors.grey[50]!,
                              ],
                            ),
                            border: Border.all(
                              color: Colors.grey[100]!,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey[200]!.withOpacity(0.5),
                                blurRadius: 15,
                                spreadRadius: 1,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color:
                                          const Color(0xFF047BC1).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.track_changes_rounded,
                                      size: 20,
                                      color: Color(0xFF047BC1),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Search Radius',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF047BC1)
                                            .withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${_controller.searchRadius.value ~/ 1000} km',
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF047BC1),
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    SliderTheme(
                                      data: SliderThemeData(
                                        trackHeight: 6,
                                        thumbShape: const RoundSliderThumbShape(
                                          enabledThumbRadius: 12,
                                          elevation: 4,
                                        ),
                                        overlayShape:
                                            const RoundSliderOverlayShape(
                                          overlayRadius: 20,
                                        ),
                                        activeTrackColor: const Color(0xFF047BC1),
                                        inactiveTrackColor: Colors.grey[200],
                                        thumbColor: const Color(0xFF047BC1),
                                        overlayColor: const Color(0xFF047BC1)
                                            .withOpacity(0.2),
                                      ),
                                      child: Slider(
                                        value:
                                            _controller.searchRadius.value.toDouble(),
                                        min: 1000,
                                        max: 20000,
                                        divisions: 19,
                                        label:
                                            '${_controller.searchRadius.value ~/ 1000}km',
                                        onChanged: (value) {
                                          _controller
                                              .setSearchRadius(value.toInt());
                                        },
                                        onChangeEnd: (value) async {
                                          if (_locationPermissionGranted) {
                                            await _controller.findNearbyBranches();
                                          }
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        _RadiusLabel(text: '1km'),
                                        _RadiusLabel(text: '5km'),
                                        _RadiusLabel(text: '10km'),
                                        _RadiusLabel(text: '15km'),
                                        _RadiusLabel(text: '20km'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                  // Nearby Branches List Header
                  if (_initialized && _locationPermissionGranted) ...[
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                      child: Text(
                        'Available Branches',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],

                  // Branches List - Fixed with GetBuilder
                  if (_initialized)
                    GetBuilder<BranchController>(
                      builder: (controller) {
                        return _buildBranchesContent();
                      },
                    )
                  else
                    _buildInitializingState(),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: _initialized && _locationPermissionGranted
          ? FloatingActionButton.extended(
              onPressed: _refreshNearbyBranches,
              icon: const Icon(Icons.my_location_rounded),
              label: const Text('Refresh'),
              backgroundColor: const Color(0xFF047BC1),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            )
          : null,
    );
  }

  Widget _buildInitializingState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 100),
      child: Column(
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(const Color(0xFF047BC1)),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Initializing...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchesContent() {
    if (_isGettingLocation) {
      return _buildLoadingState();
    }

    if (!_locationPermissionGranted) {
      return _buildPermissionRequiredState();
    }

    if (_controller.isLoadingNearby.value) {
      return _buildLoadingState();
    }

    if (_controller.nearbyError.value.isNotEmpty) {
      return _buildErrorState();
    }

    // Get branches to display - either nearby or all sorted by distance
    final branchesToShow = _controller.nearbyBranches.isNotEmpty
        ? _controller.nearbyBranches
        : _controller.branches;

    if (branchesToShow.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Show info message if no nearby branches but showing all
        if (_controller.nearbyBranches.isEmpty && _controller.branches.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: const Color(0xFFFF9800).withOpacity(0.1),
              border: Border.all(
                color: const Color(0xFFFF9800).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: const Color(0xFFFF9800),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No branches found within ${_controller.searchRadius.value ~/ 1000}km. Showing all branches sorted by distance.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Branches list
        ...branchesToShow.asMap().entries.map((entry) {
          final index = entry.key;
          final branch = entry.value;
          final distance = _controller.getDistanceToBranch(branch);

          return Padding(
            padding: EdgeInsets.only(bottom: 12, top: index == 0 ? 0 : 12),
            child: AnimatedBuilder(
              animation: _fadeController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                      0,
                      _slideAnimation.value *
                          (1 - (index * 0.1).clamp(0.0, 1.0))),
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: child,
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      const Color(0xFF047BC1).withOpacity(0.02),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.grey[100]!,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey[200]!.withOpacity(0.8),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.grey[100]!.withOpacity(0.5),
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
                    onTap: () {
                      _controller.selectBranch(branch);
                      Navigator.pushNamed(
                        context,
                        '/branches/detail',
                        arguments: branch,
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    splashColor: const Color(0xFF047BC1).withOpacity(0.1),
                    highlightColor: Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Distance Circle
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: _isBranchWithinRadius(distance)
                                    ? const [Color(0xFF047BC1), Color(0xFF4F46E5)]
                                    : const [Color(0xFFFF9800), Color(0xFFFF5722)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (_isBranchWithinRadius(distance)
                                          ? const Color(0xFF4F46E5)
                                          : const Color(0xFFFF5722))
                                      .withOpacity(0.3),
                                  blurRadius: 12,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.location_on_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    distance.contains('km')
                                        ? distance.split(' ')[0]
                                        : distance.split(' ')[0],
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    distance.contains('km') ? 'km' : 'm',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),

                          // Branch Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        branch.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                        maxLines: 2,
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
                                        color: Colors.grey[100],
                                      ),
                                      child: Text(
                                        branch.code,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF047BC1),
                                          fontFamily: 'monospace',
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
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.place_rounded,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        branch.address.shortAddress,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFF047BC1)
                                            .withOpacity(0.1),
                                        const Color(0xFF4F46E5)
                                            .withOpacity(0.05),
                                      ],
                                    ),
                                    border: Border.all(
                                      color: const Color(0xFF047BC1)
                                          .withOpacity(0.2),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.directions_rounded,
                                        size: 14,
                                        color: const Color(0xFF047BC1),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'View Details',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF047BC1),
                                        ),
                                      ),
                                    ],
                                  ),
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
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation(const Color(0xFF047BC1)),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Finding nearby branches...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Searching within ${_controller.searchRadius.value ~/ 1000}km radius',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionRequiredState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.grey[100]!,
                  Colors.grey[50]!,
                ],
              ),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 2,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.location_off_rounded,
                size: 56,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Location Access Required',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Enable location services to discover branches near you',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Container(
            height: 56,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
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
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: _checkLocationPermission,
                borderRadius: BorderRadius.circular(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.location_on_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Enable Location Services',
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
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.red.shade100,
                  Colors.red.shade50,
                ],
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.error_outline_rounded,
                size: 56,
                color: Colors.red,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Error Finding Nearby Branches',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              _controller.nearbyError.value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 56,
                width: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF047BC1), Color(0xFF4F46E5)],
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: _refreshNearbyBranches,
                    borderRadius: BorderRadius.circular(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Try Again',
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
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.grey[100]!,
                  Colors.grey[50]!,
                ],
              ),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 2,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.location_searching_rounded,
                size: 56,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Branches Available',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'No branches found in the database',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Container(
            height: 56,
            width: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFF047BC1), Color(0xFF4F46E5)],
              ),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: _refreshNearbyBranches,
                borderRadius: BorderRadius.circular(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.search_rounded,
                      color: Colors.white,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Search Again',
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
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Container(
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
          icon,
          color: const Color(0xFF047BC1),
          size: 24,
        ),
        onPressed: onPressed,
        tooltip: tooltip,
      ),
    );
  }

  void _showRadiusSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.only(top: 60),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Search Settings',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      Colors.grey[50]!,
                      Colors.white,
                    ],
                  ),
                  border: Border.all(
                    color: Colors.grey[100]!,
                    width: 1.5,
                  ),
                ),
                child: Obx(() {
                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF047BC1).withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            '${_controller.searchRadius.value ~/ 1000} kilometers',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF047BC1),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 6,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 14,
                            elevation: 4,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 24,
                          ),
                          activeTrackColor: const Color(0xFF047BC1),
                          inactiveTrackColor: Colors.grey[200],
                          thumbColor: const Color(0xFF047BC1),
                          overlayColor:
                              const Color(0xFF047BC1).withOpacity(0.2),
                        ),
                        child: Slider(
                          value: _controller.searchRadius.value / 1000,
                          min: 1,
                          max: 20,
                          divisions: 19,
                          label: '${_controller.searchRadius.value ~/ 1000}km',
                          onChanged: (value) {
                            _controller.setSearchRadius((value * 1000).toInt());
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _RadiusLabel(text: '1km'),
                          _RadiusLabel(text: '5km'),
                          _RadiusLabel(text: '10km'),
                          _RadiusLabel(text: '15km'),
                          _RadiusLabel(text: '20km'),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 56,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                  width: 1.5,
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(14),
                                child: InkWell(
                                  onTap: () => Navigator.pop(context),
                                  borderRadius: BorderRadius.circular(14),
                                  child: const Center(
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              height: 56,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF047BC1),
                                    Color(0xFF4F46E5)
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF4F46E5)
                                        .withOpacity(0.3),
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
                                  onTap: () {
                                    if (_locationPermissionGranted) {
                                      _controller.findNearbyBranches();
                                    }
                                    Navigator.pop(context);
                                  },
                                  borderRadius: BorderRadius.circular(14),
                                  child: const Center(
                                    child: Text(
                                      'Apply',
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
                          ),
                        ],
                      ),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

class _RadiusLabel extends StatelessWidget {
  final String text;

  const _RadiusLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.grey[600],
      ),
    );
  }
}