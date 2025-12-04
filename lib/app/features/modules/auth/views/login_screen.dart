import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/validators.dart';
import '../../../widgets/custom_text_field.dart/custom_text_field.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthController _authController = Get.find<AuthController>();
  
  final RxBool _showPassword = false.obs;
  final RxString _debugInfo = ''.obs;

  @override
  void initState() {
    super.initState();
    // Clear any previous errors
    _authController.errorMessage.value = '';
    
    // Print debug info
    print('\n📱 LOGIN SCREEN INITIALIZED');
    print('📱 Screen size: ${Get.size}');
    print('📱 Theme: ${Get.theme.brightness}');
    print('📱 Authenticated: ${_authController.isAuthenticated}');
    print('📱 Pending verification: ${_authController.pendingVerificationEmail}');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    _authController.errorMessage.value = '';
    _debugInfo.value = '';

    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      // Update debug info
      _debugInfo.value = '''
🔵 LOGIN ATTEMPT:
📧 Email: $email
🔑 Password: ${'*' * password.length}
⏰ Time: ${DateTime.now()}
      ''';

      print('\n👤 USER LOGIN ATTEMPT:');
      print('📧 Email: $email');
      print('🔑 Password length: ${password.length}');
      print('📱 Device: ${GetPlatform.isMobile ? 'Mobile' : 'Web'}');

      final response = await _authController.login(
        email: email,
        password: password,
      );

      // Update debug info with response
      _debugInfo.value += '''
      
🟡 LOGIN RESPONSE:
✅ Success: ${response.success}
📝 Message: ${response.message}
📊 Data: ${response.data != null ? 'Received' : 'None'}
❌ Error: ${response.error ?? 'None'}
      ''';
    }
  }

  void _forgotPassword() {
    print('🔗 Forgot password clicked');
    Get.snackbar(
      'Forgot Password',
      'Password reset functionality coming soon',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            // Logo/Icon
            Icon(
              Icons.car_rental,
              size: 80,
              color: Get.theme.primaryColor,
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome Back',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Login to your account',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 40),
            
            // Login Form
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomTextField(
                    controller: _emailController,
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                    prefixIcon: const Icon(Icons.email_outlined),
                    onChanged: (value) {
                      _debugInfo.value = 'Email changed: $value';
                    },
                  ),
                  const SizedBox(height: 20),
                  Obx(() => CustomTextField(
                    controller: _passwordController,
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    obscureText: !_showPassword.value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      return null;
                    },
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword.value 
                            ? Icons.visibility_off 
                            : Icons.visibility,
                      ),
                      onPressed: () => _showPassword.value = !_showPassword.value,
                    ),
                    onChanged: (value) {
                      _debugInfo.value = 'Password changed: ${'*' * value.length}';
                    },
                  )),
                  
                  const SizedBox(height: 10),
                  
                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _forgotPassword,
                      child: const Text('Forgot Password?'),
                    ),
                  ),
                  
                  // Error Display
                  Obx(() {
                    if (_authController.errorMessage.value.isNotEmpty) {
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Error',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    _authController.errorMessage.value,
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  }),
                  
                  // Debug Info Display (Collapsible)
                  Obx(() {
                    if (_debugInfo.value.isNotEmpty) {
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: ExpansionTile(
                          title: Row(
                            children: [
                              Icon(Icons.bug_report, color: Colors.blue, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Debug Information',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          children: [
                            Divider(color: Colors.blue.shade200),
                            SizedBox(height: 8),
                            SelectableText(
                              _debugInfo.value,
                              style: TextStyle(
                                color: Colors.blue.shade800,
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  }),
                  
                  // Controller Loading State
                  Obx(() {
                    if (_authController.isLoading.value) {
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.orange,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Processing...',
                              style: TextStyle(
                                color: Colors.orange.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  }),
                  
                  const SizedBox(height: 20),
                  
                  // Login Button
                  Obx(() => SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _authController.isLoading.value ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Get.theme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _authController.isLoading.value
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  )),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Register Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account?"),
                TextButton(
                  onPressed: () {
                    print('🔗 Navigating to Register screen');
                    Get.toNamed('/register');
                  },
                  child: const Text(
                    'Register',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            // App Info
            const SizedBox(height: 40),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'App Information',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Base URL: http://13.61.185.238:5050',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Obx(() => Text(
                    'Authenticated: ${_authController.isAuthenticated}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  )),
                  SizedBox(height: 4),
                                   Text(
                    'Platform: ${GetPlatform.isMobile ? 'Mobile' : GetPlatform.isWeb ? 'Web' : 'Desktop'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}