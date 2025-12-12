import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import '../../../../core/utils/validators.dart';
import '../../../widgets/custom_text_field.dart/custom_text_field.dart';
import '../controllers/auth_controller.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthController _authController = Get.find<AuthController>();

  final RxString _localError = ''.obs;
  final RxBool _showPassword = false.obs;
  final RxBool _showConfirmPassword = false.obs;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    _localError.value = '';

    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        _localError.value = 'Passwords do not match';
        Get.snackbar(
          'Error',
          'Passwords do not match',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      _authController.isLoading.value = true;

      try {
        final response = await _authController.register(
          fullName: _fullNameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
        );

        if (response.success && response.data != null) {
          Get.offNamed(
            '/verify-email',
            arguments: {'email': _emailController.text.trim()},
          );
          Get.snackbar(
            'Success',
            'Registration successful! Please check your email for OTP.',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          _localError.value = response.message;
          Get.snackbar(
            'Registration Failed',
            response.message,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
          );
        }
      } catch (e) {
        _localError.value = e.toString();
        Get.snackbar(
          'Registration Error',
          e.toString(),
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      } finally {
        _authController.isLoading.value = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background gradient
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF047BC1), Color(0xFF4F46E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Background elements
          Positioned(
            top: -size.width * 0.3,
            right: -size.width * 0.2,
            child: Container(
              width: size.width * 0.8,
              height: size.width * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF047BC1).withOpacity(0.15),
                    const Color(0xFF047BC1).withOpacity(0.05),
                    Colors.transparent,
                  ],
                  stops: const [0.1, 0.3, 1.0],
                ),
              ),
            ),
          ),
          
          Positioned(
            bottom: -size.width * 0.25,
            left: -size.width * 0.2,
            child: Container(
              width: size.width * 0.7,
              height: size.width * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF4F46E5).withOpacity(0.15),
                    const Color(0xFF4F46E5).withOpacity(0.05),
                    Colors.transparent,
                  ],
                  stops: const [0.1, 0.3, 1.0],
                ),
              ),
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      
                      // Header with back button
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                              ),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                              onPressed: () => Get.back(),
                              splashRadius: 20,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Create Account',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                            ),
                          ),
                          const Spacer(),
                          const SizedBox(width: 48), // For balance
                        ],
                      ),

                      const SizedBox(height: 40),

                      // Title section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Join the Future",
                            style: theme.textTheme.displaySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 36,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Create your account to get started",
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 48),

                      // Glassmorphism Form Card
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1.5,
                              ),
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  // Full Name Field
                                  _buildTextField(
                                    controller: _fullNameController,
                                    labelText: 'Full Name',
                                    hintText: 'Enter your full name',
                                    icon: Icons.person_outline_rounded,
                                    validator: Validators.validateFullName,
                                  ),
                                  const SizedBox(height: 24),

                                  // Email Field
                                  _buildTextField(
                                    controller: _emailController,
                                    labelText: 'Email Address',
                                    hintText: 'Enter your email',
                                    icon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: Validators.validateEmail,
                                  ),
                                  const SizedBox(height: 24),

                                  // Phone Field
                                  _buildTextField(
                                    controller: _phoneController,
                                    labelText: 'Phone Number',
                                    hintText: 'Enter phone number',
                                    icon: Icons.phone_outlined,
                                    keyboardType: TextInputType.phone,
                                    validator: Validators.validatePhone,
                                    maxLength: 15,
                                  ),
                                  const SizedBox(height: 24),

                                  // Password Field
                                  Obx(() => _buildTextField(
                                        controller: _passwordController,
                                        labelText: 'Password',
                                        hintText: 'Enter your password',
                                        icon: Icons.lock_outline_rounded,
                                        obscureText: !_showPassword.value,
                                        validator: Validators.validatePassword,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _showPassword.value
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                            color: Colors.white.withOpacity(0.6),
                                            size: 22,
                                          ),
                                          onPressed: () =>
                                              _showPassword.value = !_showPassword.value,
                                          splashRadius: 20,
                                        ),
                                      )),
                                  const SizedBox(height: 24),

                                  // Confirm Password Field
                                  Obx(() => _buildTextField(
                                        controller: _confirmPasswordController,
                                        labelText: 'Confirm Password',
                                        hintText: 'Re-enter your password',
                                        icon: Icons.lock_outline_rounded,
                                        obscureText: !_showConfirmPassword.value,
                                        validator: (v) => v == null || v.isEmpty
                                            ? 'Please confirm your password'
                                            : null,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _showConfirmPassword.value
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                            color: Colors.white.withOpacity(0.6),
                                            size: 22,
                                          ),
                                          onPressed: () => _showConfirmPassword.value =
                                              !_showConfirmPassword.value,
                                          splashRadius: 20,
                                        ),
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Error Display
                      Obx(() {
                        if (_localError.value.isNotEmpty) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFEF4444).withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEF4444).withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.error_outline_rounded,
                                    color: Color(0xFFEF4444),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _localError.value,
                                    style: const TextStyle(
                                      color: Color(0xFFEF4444),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }),

                      const SizedBox(height: 32),

                      // Register Button
                      Obx(() => Container(
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF047BC1),
                                  const Color(0xFF4F46E5),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF4F46E5).withOpacity(0.4),
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
                                onTap: _authController.isLoading.value ? null : _register,
                                borderRadius: BorderRadius.circular(16),
                                child: Center(
                                  child: _authController.isLoading.value
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 3,
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Create Account',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Icon(
                                              Icons.arrow_forward_rounded,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          )),

                      const SizedBox(height: 24),

                      // Sign In Link
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 24,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white.withOpacity(0.08),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account?',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => Get.back(),
                              child: Text(
                                'Sign In',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffixIcon,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8),
          child: Text(
            labelText,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  color: Colors.white.withOpacity(0.7),
                  size: 22,
                ),
              ),
              Expanded(
                child: CustomTextField(
                  controller: controller,
                  labelText: labelText,
                  hintText: hintText,
                  obscureText: obscureText,
                  keyboardType: keyboardType,
                  validator: validator,
                  maxLength: maxLength,
                  prefixIcon: null, // We're handling the icon separately
                  suffixIcon: null, // We're handling the suffix separately in the Row
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (suffixIcon != null)
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  child: suffixIcon,
                ),
            ],
          ),
        ),
      ],
    );
  }
}