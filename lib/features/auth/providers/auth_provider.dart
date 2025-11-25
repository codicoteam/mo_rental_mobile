// features/auth/providers/auth_provider.dart
import 'package:flutter/foundation.dart';

class AuthProvider with ChangeNotifier {
  String? _agentId;
  String? _branch;
  bool _isAuthenticated = false;

  String? get agentId => _agentId;
  String? get branch => _branch;
  bool get isAuthenticated => _isAuthenticated;

  Future<bool> loginAgent(String email, String password, String branch) async {
    // Implement actual authentication logic
    await Future.delayed(Duration(seconds: 2));
    
    // Mock successful login
    _agentId = 'agent_${DateTime.now().millisecondsSinceEpoch}';
    _branch = branch;
    _isAuthenticated = true;
    
    notifyListeners();
    return true;
  }

  void logout() {
    _agentId = null;
    _branch = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}