// lib/app/routes/app_routes.dart
abstract class AppRoutes {
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

  // Reservation screens - ADD THESE
  static const checkAvailability = '/reservations/availability';
  static const createReservation = '/reservations/create';
  static const reservationList = '/reservations/list';
  static const reservationDetail = '/reservations/detail';

  // Chat screens
  static const chatConversations = '/chat/conversations';
  static const chatDetail = '/chat/detail';
  static const createChat = '/chat/create';

  // Branch screens
  static const branches = '/branches'; // Changed from branchesList
  static const branchDetail = '/branches/detail';
  static const nearbyBranches = '/branches/nearby';

  // Vehicle routes
  static const vehicleModels = '/vehicles/models';
  static const vehicleFleet = '/vehicles/fleet';
  static const vehicleSelection = '/vehicles/selection';

  // Driver routes
  static const publicDrivers = '/drivers/public';
  static const myDriverProfile = '/drivers/my-profile';  // ADD THIS
  static const createDriverProfile = '/drivers/create-profile';  // ADD THIS
  static const editDriverProfile = '/drivers/edit-profile';  //

  // Helper method to get chat detail with parameters
  static String chatDetailWithId(String conversationId) {
    return '$chatDetail?id=$conversationId';
  }

  // Helper method to get reservation detail with parameters
  static String reservationDetailWithId(String reservationId) {
    return '$reservationDetail?id=$reservationId';
  }
}
