// features/auth/screens/agent_auth_screen.dart
import 'package:flutter/material.dart';

class AgentAuthScreen extends StatefulWidget {
  const AgentAuthScreen({super.key});

  @override
  _AgentAuthScreenState createState() => _AgentAuthScreenState();
}

class _AgentAuthScreenState extends State<AgentAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _branchController = TextEditingController();
  bool _isLoading = false;

  // Mock branches data
  final List<String> _branches = [
    'Harare Central',
    'Bulawayo Main',
    'Mutare Branch',
    'Bindura Office',
    'Gweru Station'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Agent Login", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Text(
                "Welcome Back, Agent!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue[800]),
              ),
              SizedBox(height: 8),
              Text("Sign in to manage rentals and assist customers", style: TextStyle(color: Colors.grey[600])),
              SizedBox(height: 32),
              
              // Branch Selection
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Select Branch",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on, color: Colors.blue),
                ),
                items: _branches.map((branch) {
                  return DropdownMenuItem(
                    value: branch,
                    child: Text(branch),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _branchController.text = value!;
                  });
                },
                validator: (value) => value == null ? 'Please select your branch' : null,
              ),
              SizedBox(height: 16),

              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Agent Email",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email, color: Colors.blue),
                ),
                validator: (value) => value!.isEmpty ? 'Please enter your email' : null,
              ),
              SizedBox(height: 16),

              // Password Field
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock, color: Colors.blue),
                ),
                validator: (value) => value!.isEmpty ? 'Please enter your password' : null,
              ),
              SizedBox(height: 24),

              // Login Button
              _isLoading 
                  ? Center(child: CircularProgressIndicator(color: Colors.blue))
                  : ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text("Sign In as Agent", style: TextStyle(color: Colors.white)),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      // Simulate API call
      await Future.delayed(Duration(seconds: 2));
      
      // Authentication logic would go here
      bool success = await _authenticateAgent(
        _emailController.text,
        _passwordController.text,
        _branchController.text,
      );

      setState(() => _isLoading = false);

      if (success) {
        Navigator.pushReplacementNamed(context, '/agent-dashboard');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Invalid credentials. Please try again.")),
        );
      }
    }
  }

  Future<bool> _authenticateAgent(String email, String password, String branch) async {
    // Mock authentication - replace with actual API call
    return email.isNotEmpty && password.isNotEmpty && branch.isNotEmpty;
  }
}