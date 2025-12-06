class AppRoutes {
  // Welcome screens
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  
  // Auth screens
  static const login = '/login';
  static const register = '/register';
  static const verifyEmail = '/verify-email'; 
  
  // Main app screens
  static const home = '/home';
  static const main = '/main';
  static const ratePlans = '/rate-plans';
  static const promoCodes = '/promo-codes';
  
  // Chat screens
  static const chatConversations = '/chat/conversations';
  static const chatDetail = '/chat/detail';
  static const createChat = '/chat/create';
  
  // Helper method to get chat detail with parameters
  static String chatDetailWithId(String conversationId) {
    return '$chatDetail?id=$conversationId';
  }
}