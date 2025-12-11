import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/validators.dart';
import '../../../widgets/custom_text_field.dart/custom_text_field.dart';
import '../controllers/auth_controller.dart';
import '../../../../core/themes/app_palette.dart';

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

  @override
  void initState() {
    super.initState();
    _authController.errorMessage.value = '';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    _authController.errorMessage.value = '';

    if (_formKey.currentState!.validate()) {
      await _authController.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
  }

void _forgotPassword() {
  _authController.showForgotPasswordDialog();
}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Login"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // BACKGROUND GRADIENT
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0A0F29),
                  Color(0xFF091324),
                  Color(0xFF050714),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // NEON BALL 1
          Positioned(
            top: -40,
            right: -30,
            child: _neonBlob(AppPalette.primaryBlue.withOpacity(0.25)),
          ),

          // NEON BALL 2
          Positioned(
            bottom: -40,
            left: -30,
            child: _neonBlob(AppPalette.indigo.withOpacity(0.3)),
          ),

          // CONTENT
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // LOGO BLOB
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppPalette.primaryBlue.withOpacity(0.8),
                        AppPalette.deepIndigo.withOpacity(0.2)
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppPalette.primaryBlue.withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 10,
                      )
                    ],
                  ),
                  child: const Icon(
                    Icons.car_rental,
                    size: 70,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 35),

                Text(
                  "Welcome Back",
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "Login to continue",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 45),

                // FUTURISTIC GLASS CARD
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: AppPalette.glassDecoration.copyWith(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        CustomTextField(
                          controller: _emailController,
                          labelText: 'Email',
                          hintText: 'Enter email',
                          validator: Validators.validateEmail,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.email, color: Colors.white70),
                          style: const TextStyle(color: Colors.white),
                        ),

                        const SizedBox(height: 20),

                        Obx(() => CustomTextField(
                              controller: _passwordController,
                              labelText: 'Password',
                              hintText: 'Enter password',
                              obscureText: !_showPassword.value,
                              validator: (value) =>
                                  value == null || value.isEmpty ? 'Required' : null,
                              prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                              style: const TextStyle(color: Colors.white),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _showPassword.value
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.white70,
                                ),
                                onPressed: () =>
                                    _showPassword.value = !_showPassword.value,
                              ),
                            )),
                      ],
                    ),
                  ),
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _forgotPassword,
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // ERROR DISPLAY
                Obx(() {
                  if (_authController.errorMessage.value.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return _errorMessage(_authController.errorMessage.value);
                }),

                const SizedBox(height: 20),

                // LOGIN BUTTON
                Obx(() => SizedBox(
                      height: 55,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            _authController.isLoading.value ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppPalette.primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _authController.isLoading.value
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                "Login",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    )),

                const SizedBox(height: 25),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(color: Colors.white70),
                    ),
                    TextButton(
                      onPressed: () => Get.toNamed('/register'),
                      child: const Text(
                        "Register",
                        style: TextStyle(
                          color: AppPalette.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _neonBlob(Color color) {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 80,
            spreadRadius: 40,
          )
        ],
      ),
    );
  }

  Widget _errorMessage(String msg) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              msg,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
