import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../routes/app_routes.dart';
import '../../auth/controllers/auth_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final AuthController authController = Get.find<AuthController>();
  final GetStorage storage = GetStorage();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authController.isAuthenticated) {
        authController.getUserProfile();
      }
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _refreshProfile() async {
    if (authController.isAuthenticated) {
      await authController.getUserProfile();
      Get.snackbar(
        'Profile Updated',
        'Your information has been refreshed',
        backgroundColor: const Color(0xFF047BC1),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        borderRadius: 12,
        margin: const EdgeInsets.all(20),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (authController.isLoading.value) {
          return Center(
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
                  'Loading profile...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        final userProfile = authController.currentUserProfile.value;
        final storedUserData = storage.read('user_data') ?? {};

        final userData = userProfile != null
            ? {
                '_id': userProfile.id,
                'email': userProfile.email,
                'phone': userProfile.phone,
                'full_name': userProfile.fullName,
                'roles': userProfile.roles,
                'status': userProfile.status,
                'email_verified': userProfile.emailVerified,
                'created_at': userProfile.createdAt,
                'updated_at': userProfile.updatedAt,
              }
            : storedUserData;

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            );
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Glassmorphism Header
              SliverAppBar(
                expandedHeight: 160,
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
                      padding: const EdgeInsets.only(
                        top: 70,
                        left: 24,
                        right: 24,
                        bottom: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'My Profile',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Manage your account',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          Container(
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
                                size: 24,
                              ),
                              onPressed: _refreshProfile,
                              tooltip: 'Refresh Profile',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Profile Avatar with Gradient Border
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF047BC1), Color(0xFF4F46E5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4F46E5).withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 2,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                Icons.person_rounded,
                                size: 48,
                                color: const Color(0xFF047BC1),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Name and Email
                      Text(
                        userData['full_name'] ?? 'Guest User',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        userData['email'] ?? 'No email',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),

                      // Live Data Badge
                      if (userProfile != null)
                        Container(
                          margin: const EdgeInsets.only(top: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF4CAF50).withOpacity(0.15),
                                const Color(0xFF4CAF50).withOpacity(0.05),
                              ],
                            ),
                            border: Border.all(
                              color: const Color(0xFF4CAF50).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 16,
                                color: const Color(0xFF4CAF50),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Live Data • Synced',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF4CAF50),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 32),

                      // Account Information Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF047BC1).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    Icons.account_circle_rounded,
                                    color: const Color(0xFF047BC1),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Account Information',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.verified_rounded,
                                  color: (userData['email_verified'] ?? false)
                                      ? const Color(0xFF4CAF50)
                                      : const Color(0xFFFF9800),
                                  size: 24,
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _buildInfoRow(
                              Icons.phone_rounded,
                              'Phone',
                              userData['phone'] ?? 'Not set',
                            ),
                            _buildInfoRow(
                              Icons.fingerprint_rounded,
                              'User ID',
                              userData['_id']?.toString().substring(0, 8) ?? 'N/A',
                            ),
                            _buildInfoRow(
                              Icons.circle_rounded,
                              'Status',
                              (userData['status'] ?? 'Unknown').toString().toUpperCase(),
                            ),
                            _buildInfoRow(
                              Icons.verified_user_rounded,
                              'Email Verified',
                              (userData['email_verified'] ?? false)
                                  ? 'VERIFIED'
                                  : 'NOT VERIFIED',
                              isVerified: (userData['email_verified'] ?? false),
                            ),
                            _buildInfoRow(
                              Icons.workspace_premium_rounded,
                              'Roles',
                              (userData['roles'] as List<dynamic>?)?.join(', ') ?? 'No roles',
                            ),
                            _buildInfoRow(
                              Icons.calendar_month_rounded,
                              'Member Since',
                              userData['created_at']?.toString().split('T').first ?? 'N/A',
                            ),
                            _buildInfoRow(
                              Icons.update_rounded,
                              'Last Updated',
                              userData['updated_at']?.toString().split('T').first ?? 'N/A',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Quick Actions
                      const Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _buildActionCard(
                            icon: Icons.edit_rounded,
                            label: 'Edit Profile',
                            color: const Color(0xFF047BC1),
                            onTap: () {
                              Get.toNamed(AppRoutes.editProfile);
                            },
                          ),
                          _buildActionCard(
                            icon: Icons.lock_rounded,
                            label: 'Security',
                            color: const Color(0xFF4F46E5),
                            onTap: () {
                              Get.snackbar(
                                'Coming Soon',
                                'Password change feature',
                                backgroundColor: const Color(0xFFFF9800),
                                colorText: Colors.white,
                              );
                            },
                          ),
                          _buildActionCard(
                            icon: Icons.history_rounded,
                            label: 'History',
                            color: const Color(0xFF4CAF50),
                            onTap: () {
                              Get.snackbar(
                                'Coming Soon',
                                'Booking history feature',
                                backgroundColor: const Color(0xFF047BC1),
                                colorText: Colors.white,
                              );
                            },
                          ),
                          _buildActionCard(
                            icon: Icons.help_rounded,
                            label: 'Support',
                            color: const Color(0xFFFF9800),
                            onTap: () {
                              Get.snackbar(
                                'Coming Soon',
                                'Support feature',
                                backgroundColor: const Color(0xFF4F46E5),
                                colorText: Colors.white,
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Danger Zone
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.red.shade50,
                              Colors.red.shade100.withOpacity(0.3),
                            ],
                          ),
                          border: Border.all(
                            color: Colors.red.shade200,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Danger Zone',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildDangerAction(
                              icon: Icons.delete_forever_rounded,
                              label: 'Delete Account',
                              onTap: () {
                                authController.showDeleteAccountDialog();
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildDangerAction(
                              icon: Icons.logout_rounded,
                              label: 'Logout',
                              onTap: () {
                                authController.logout();
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Session Info Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          color: Colors.grey.shade50,
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Session Information',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildSessionInfo(
                              'Token Status',
                              storage.read('auth_token') != null ? 'ACTIVE' : 'INACTIVE',
                              isActive: storage.read('auth_token') != null,
                            ),
                            _buildSessionInfo(
                              'Data Source',
                              userProfile != null ? 'API • LIVE' : 'STORAGE • CACHED',
                              isActive: userProfile != null,
                            ),
                            _buildSessionInfo(
                              'Last Updated',
                              userData['updated_at']?.toString() ?? 'UNKNOWN',
                            ),
                          ],
                        ),
                      ),

                      // Error Message
                      if (authController.errorMessage.value.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 24),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              colors: [
                                Colors.red.shade100,
                                Colors.red.shade50,
                              ],
                            ),
                            border: Border.all(
                              color: Colors.red.shade200,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red.shade200,
                                ),
                                child: const Icon(
                                  Icons.error_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  authController.errorMessage.value,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    bool isVerified = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 20,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isVerified ? const Color(0xFF4CAF50) : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 150,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: color.withOpacity(0.1),
          highlightColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.1),
                  color.withOpacity(0.05),
                ],
              ),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.2),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDangerAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.red.withOpacity(0.1),
        highlightColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.red.shade200,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.shade100,
                ),
                child: Icon(
                  icon,
                  color: Colors.red,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.red.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionInfo(String label, String value, {bool isActive = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isActive
                  ? const Color(0xFF4CAF50).withOpacity(0.1)
                  : Colors.grey.shade200,
              border: Border.all(
                color: isActive
                    ? const Color(0xFF4CAF50).withOpacity(0.3)
                    : Colors.grey.shade300,
              ),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive ? const Color(0xFF4CAF50) : Colors.grey.shade700,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}