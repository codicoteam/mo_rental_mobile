import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/themes/app_palette.dart';
import '../../auth/controllers/auth_controller.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final AuthController _authController = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with current user data
    final userProfile = _authController.currentUserProfile.value;
    
    _fullNameController = TextEditingController(
      text: userProfile?.fullName ?? '',
    );
    
    _phoneController = TextEditingController(
      text: userProfile?.phone ?? '',
    );
    
    _emailController = TextEditingController(
      text: userProfile?.email ?? '',
    );
    // REMOVED: _emailController.dispose(); // DON'T DISPOSE HERE!
  }
  
  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose(); // DISPOSE ALL CONTROLLERS HERE
    super.dispose();
  }
  
  Future<void> _updateProfile() async {
    print('🚀 STARTING PROFILE UPDATE');
    
    if (_formKey.currentState!.validate()) {
      try {
        print('✅ FORM VALIDATION PASSED');
        print('📝 Full Name: ${_fullNameController.text.trim()}');
        print('📱 Phone: ${_phoneController.text.trim()}');
        
        final result = await _authController.updateProfile(
          fullName: _fullNameController.text.trim(),
          phone: _phoneController.text.trim(),
        );
        
        print('📊 UPDATE RESULT: ${result.success}');
        print('📨 MESSAGE: ${result.message}');
        
        if (result.success) {
          print('✅ PROFILE UPDATE SUCCESSFUL');
          // Wait a bit before going back to show the success message
          await Future.delayed(const Duration(milliseconds: 500));
          Get.back();
        } else {
          print('❌ PROFILE UPDATE FAILED: ${result.message}');
          // Error will be shown through authController.errorMessage
        }
      } catch (e) {
        print('🔥 EXCEPTION IN _updateProfile: $e');
        print('📋 Stack trace: ${e.toString()}');
        rethrow;
      }
    } else {
      print('❌ FORM VALIDATION FAILED');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
        actions: [
          Obx(() {
            if (_authController.isUpdatingProfile.value) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            }
            return IconButton(
              icon: const Icon(Icons.save),
              onPressed: _updateProfile,
              tooltip: 'Save Changes',
            );
          }),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture Section
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: AppPalette.primaryBlue.withOpacity(0.1),
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: AppPalette.primaryBlue,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: AppPalette.primaryBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to change photo',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Form Fields
              Text(
                'Personal Information',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Full Name Field
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'Enter your full name',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  print('🔍 Validating Full Name: $value');
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  if (_authController.isValidName(value)) {
                    return null;
                  } else {
                    return 'Name must be 2-50 characters';
                  }
                },
              ),
              
              const SizedBox(height: 20),
              
              // Email Field (Read-only)
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Your email address',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                readOnly: true,
                enabled: false,
              ),
              const SizedBox(height: 8),
              Text(
                'Email cannot be changed',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Phone Field
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter your phone number',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  print('🔍 Validating Phone: $value');
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (_authController.isValidPhone(value)) {
                    return null;
                  } else {
                    return 'Please enter a valid phone number';
                  }
                },
              ),
              
              const SizedBox(height: 30),
              
              // Save Button
              Obx(() {
                print('🔄 Rebuilding Save Button - Loading: ${_authController.isUpdatingProfile.value}');
                return SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _authController.isUpdatingProfile.value ? null : _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppPalette.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _authController.isUpdatingProfile.value
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Updating...'),
                            ],
                          )
                        : const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                );
              }),
              
              const SizedBox(height: 20),
              
              // Cancel Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    print('❌ Cancelling edit profile');
                    Get.back();
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              
              // Error Message
              Obx(() {
                final error = _authController.errorMessage.value;
                print('🔍 Error Message Status: ${error.isEmpty ? "No error" : "Error: $error"}');
                if (error.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Container(
                  margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          error,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              
              const SizedBox(height: 20),
              
              // Info Card
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your email cannot be changed for security reasons. '
                          'Contact support if you need to update your email address.',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}