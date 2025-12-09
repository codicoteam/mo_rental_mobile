// lib/features/modules/drivers/views/driver_profile_form_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/models/drivers_models/driver_profile.dart';
import '../controllers/driver_profile_controller.dart';

class DriverProfileFormScreen extends StatefulWidget {
  final bool isEditMode;

  const DriverProfileFormScreen({super.key, this.isEditMode = false});

  @override
  State<DriverProfileFormScreen> createState() => _DriverProfileFormScreenState();
}

class _DriverProfileFormScreenState extends State<DriverProfileFormScreen> {
  final DriverProfileController controller = Get.find<DriverProfileController>();
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _baseCityController = TextEditingController();
  final TextEditingController _baseRegionController = TextEditingController();
  final TextEditingController _baseCountryController = TextEditingController();
  final TextEditingController _hourlyRateController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _yearsExperienceController = TextEditingController();
  final TextEditingController _languagesController = TextEditingController();
  final TextEditingController _idTypeController = TextEditingController(text: 'national_id');
  final TextEditingController _idImageUrlController = TextEditingController();
  final TextEditingController _licenseNumberController = TextEditingController();
  final TextEditingController _licenseImageUrlController = TextEditingController();
  final TextEditingController _licenseCountryController = TextEditingController();
  final TextEditingController _licenseClassController = TextEditingController();
  final TextEditingController _licenseExpiryController = TextEditingController();
  
  List<String> _selectedLanguages = ['English'];
  DateTime? _licenseExpiryDate;

  @override
  void initState() {
    super.initState();
    print('📝 DriverProfileFormScreen initialized');
    print('📝 Mode: ${widget.isEditMode ? 'Edit' : 'Create'}');
    
    if (widget.isEditMode && controller.myDriverProfile.value != null) {
      _loadProfileData();
    }
  }

  void _loadProfileData() {
    final profile = controller.myDriverProfile.value!;
    
    _displayNameController.text = profile.displayName;
    _baseCityController.text = profile.baseCity;
    _baseRegionController.text = profile.baseRegion;
    _baseCountryController.text = profile.baseCountry;
    _hourlyRateController.text = profile.hourlyRate.toString();
    _bioController.text = profile.bio;
    _yearsExperienceController.text = profile.yearsExperience.toString();
    _selectedLanguages = List.from(profile.languages);
    _languagesController.text = profile.languages.join(', ');
    
    _idTypeController.text = profile.identityDocument.type;
    _idImageUrlController.text = profile.identityDocument.imageUrl;
    
    _licenseNumberController.text = profile.driverLicense.number;
    _licenseImageUrlController.text = profile.driverLicense.imageUrl;
    _licenseCountryController.text = profile.driverLicense.country;
    _licenseClassController.text = profile.driverLicense.licenseClass;
    _licenseExpiryDate = profile.driverLicense.expiresAt;
    _licenseExpiryController.text = DateFormat('yyyy-MM-dd').format(profile.driverLicense.expiresAt);
  }

  Future<void> _selectLicenseExpiry() async {
    print('📅 Selecting license expiry date');
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _licenseExpiryDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    
    if (picked != null && picked != _licenseExpiryDate) {
      setState(() {
        _licenseExpiryDate = picked;
        _licenseExpiryController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _parseLanguages() {
    final text = _languagesController.text.trim();
    if (text.isNotEmpty) {
      _selectedLanguages = text.split(',').map((lang) => lang.trim()).toList();
    }
  }

  Future<void> _submitForm() async {
    print('🚀 Submitting driver profile form');
    
    if (!_formKey.currentState!.validate()) {
      print('❌ Form validation failed');
      return;
    }
    
    _parseLanguages();
    
    // Validate license expiry
    if (_licenseExpiryDate == null) {
      Get.snackbar(
        'Error',
        'Please select a license expiry date',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    try {
      print('📋 Creating driver profile request...');
      
      final success = await controller.createDriverProfile(
        displayName: _displayNameController.text,
        baseCity: _baseCityController.text,
        baseRegion: _baseRegionController.text,
        baseCountry: _baseCountryController.text,
        hourlyRate: double.parse(_hourlyRateController.text),
        bio: _bioController.text,
        yearsExperience: int.parse(_yearsExperienceController.text),
        languages: _selectedLanguages,
        identityDocument: IdentityDocument(
          type: _idTypeController.text,
          imageUrl: _idImageUrlController.text,
        ),
        driverLicense: DriverLicense(
          number: _licenseNumberController.text,
          imageUrl: _licenseImageUrlController.text,
          country: _licenseCountryController.text,
          licenseClass: _licenseClassController.text,
          expiresAt: _licenseExpiryDate!,
          verified: false,
        ),
      );
      
      if (success) {
        print('✅ Profile creation successful, navigating back');
        Get.back();
      }
    } catch (e) {
      print('❌ Form submission error: $e');
    }
  }

  Future<void> _updateProfile() async {
    print('🔄 Updating driver profile');
    
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    _parseLanguages();
    
    final success = await controller.updateDriverProfile(
      displayName: _displayNameController.text,
      baseCity: _baseCityController.text,
      baseRegion: _baseRegionController.text,
      baseCountry: _baseCountryController.text,
      hourlyRate: double.parse(_hourlyRateController.text),
      bio: _bioController.text,
      yearsExperience: int.parse(_yearsExperienceController.text),
      languages: _selectedLanguages,
      identityDocument: IdentityDocument(
        type: _idTypeController.text,
        imageUrl: _idImageUrlController.text,
      ),
      driverLicense: DriverLicense(
        number: _licenseNumberController.text,
        imageUrl: _licenseImageUrlController.text,
        country: _licenseCountryController.text,
        licenseClass: _licenseClassController.text,
        expiresAt: _licenseExpiryDate ?? DateTime.now().add(Duration(days: 365)),
        verified: false,
      ),
    );
    
    if (success) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditMode ? 'Edit Driver Profile' : 'Become a Driver'),
        actions: [
          if (widget.isEditMode)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _updateProfile,
              tooltip: 'Save Changes',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Driver Role Warning
              if (!controller.hasDriverRole)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.warning, color: Colors.orange),
                          const SizedBox(width: 8),
                          const Text(
                            'Driver Role Required',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'You need the "driver" role to create a driver profile. Regular users cannot become drivers without admin approval.',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () {
                          Get.snackbar(
                            'Contact Support',
                            'Please contact support to request driver access',
                            backgroundColor: Colors.blue,
                            colorText: Colors.white,
                          );
                        },
                        child: const Text('Request Driver Access'),
                      ),
                    ],
                  ),
                ),

              // Basic Information
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Basic Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _displayNameController,
                        decoration: const InputDecoration(
                          labelText: 'Display Name*',
                          hintText: 'John D. - Harare Driver',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a display name';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _baseCityController,
                              decoration: const InputDecoration(
                                labelText: 'City*',
                                hintText: 'Harare',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your city';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _baseRegionController,
                              decoration: const InputDecoration(
                                labelText: 'Region*',
                                hintText: 'Harare Province',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your region';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _baseCountryController,
                        decoration: const InputDecoration(
                          labelText: 'Country*',
                          hintText: 'Zimbabwe',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your country';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Professional Details
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Professional Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _hourlyRateController,
                        decoration: const InputDecoration(
                          labelText: 'Hourly Rate (USD)*',
                          hintText: '15.00',
                          border: OutlineInputBorder(),
                          prefixText: '\$',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your hourly rate';
                          }
                          final rate = double.tryParse(value);
                          if (rate == null || rate <= 0) {
                            return 'Please enter a valid rate';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _yearsExperienceController,
                        decoration: const InputDecoration(
                          labelText: 'Years of Experience*',
                          hintText: '5',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter years of experience';
                          }
                          final years = int.tryParse(value);
                          if (years == null || years < 0) {
                            return 'Please enter valid years';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _languagesController,
                        decoration: const InputDecoration(
                          labelText: 'Languages (comma separated)*',
                          hintText: 'English, Shona, Ndebele',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter languages you speak';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _bioController,
                        decoration: const InputDecoration(
                          labelText: 'Bio/Description*',
                          hintText: 'Professional driver with 8 years experience...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a bio';
                          }
                          if (value.length < 50) {
                            return 'Please write a more detailed bio (min 50 characters)';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Identity Document
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Identity Document',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _idTypeController,
                        decoration: const InputDecoration(
                          labelText: 'Document Type*',
                          hintText: 'national_id, passport, etc.',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter document type';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _idImageUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Document Image URL*',
                          hintText: 'https://example.com/id-front.jpg',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter document image URL';
                          }
                          if (!Uri.parse(value).isAbsolute) {
                            return 'Please enter a valid URL';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Driver License
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Driver License',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _licenseNumberController,
                        decoration: const InputDecoration(
                          labelText: 'License Number*',
                          hintText: 'DL1234567',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter license number';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _licenseCountryController,
                              decoration: const InputDecoration(
                                labelText: 'Country Code*',
                                hintText: 'ZW, ZA, etc.',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter country code';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _licenseClassController,
                              decoration: const InputDecoration(
                                labelText: 'License Class*',
                                hintText: 'Class 4, Code B, etc.',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter license class';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _licenseImageUrlController,
                        decoration: const InputDecoration(
                          labelText: 'License Image URL*',
                          hintText: 'https://example.com/license.jpg',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter license image URL';
                          }
                          if (!Uri.parse(value).isAbsolute) {
                            return 'Please enter a valid URL';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _licenseExpiryController,
                        decoration: InputDecoration(
                          labelText: 'License Expiry Date*',
                          hintText: 'YYYY-MM-DD',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: _selectLicenseExpiry,
                          ),
                        ),
                        readOnly: true,
                        onTap: _selectLicenseExpiry,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select expiry date';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Submit Button
              Obx(() {
                if (controller.isCreatingProfile.value) {
                  return const Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Creating driver profile...'),
                      ],
                    ),
                  );
                }
                
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: controller.hasDriverRole ? _submitForm : null,
                    icon: const Icon(Icons.drive_eta),
                    label: Text(widget.isEditMode ? 'Update Profile' : 'Create Driver Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: controller.hasDriverRole ? Colors.green : Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      disabledBackgroundColor: Colors.grey,
                    ),
                  ),
                );
              }),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}